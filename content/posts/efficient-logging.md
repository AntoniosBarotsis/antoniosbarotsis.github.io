---
title: "Efficient Logging"
description: "Speeding up production code by 33% in my cherry-picked-definitely-representative benchmark!"
keywords: ["Rust", "Logging", "Performance", "Parallel", "Multi", "Threading", "Slow", "Thread", "Channel"]
date: 2024-08-01T02:24:51+03:00
draft: false
taxonomies:
  tags: ["Concurrency", "Performance", "No Coding"]
---

## Introduction

I've been using this neat command line tool called [ouch]. At its core, it doesn't do anything
groundbreaking but it is quite convenient; it gives you a unified and easy-to-use interface for
(de)compressing just about any format you (or at least I) can think of.

Here are some of the usage examples from the readme to get an idea of what it looks like:

```sh
# (or `ouch d` for short)
ouch decompress a.zip

# Decompress multiple files
ouch decompress a.zip b.tar.gz c.tar
```

And similarly for compressing:

```sh
# Compress two files into `archive.zip`
ouch compress one.txt two.txt archive.zip

# Compress file.txt using .lz4 and .zst
ouch compress file.txt file.txt.lz4.zst
```

As you can see, it *just works™* as you'd expect. The org does not have a sponsorship option so I
instead decided to keep an eye out for issues I could help with since I was using `ouch` on a
weekly basis anyway.

## The Problem

Soon enough, I came across the following issue:

{{ image(src="/img/efficient-logging/issue.webp", href="https://github.com/ouch-org/ouch/issues/77") }}

> All images of GitHub issues have hyperlinks to the actual issue so if you want to go ahead and
> read the issue on GitHub and escape my webp file compression, you can just click it!

You may notice that the issue is actually quite old by now. From what I understand in retrospect
(as I was not using the project at the time), it was deemed to be not too important back then.
The problem resurfaced later when
[parallelism was added to decompression](https://github.com/ouch-org/ouch/issues/510).

This caused 2 problems:

1. Performance: Having more than 1 thread fighting for printing info to the terminal caused dramatic
   slow-downs. In the example benchmark I used for my testing (more on this later), I found that in
   some cases, decompressing 2 files in parallel that individually took ~31 seconds each, took 
   49 seconds combined instead. That is an enormous increase as we'll see later.
2. Broke `ouch`'s questions about file overwriting: `ouch` would ask the user `y/n` questions when
   a file was about to be overwritten by the now decompressed file. The logs would come out of order
   and often, more than 1 question would be printed before waiting for user input. That would look
   something like this:

   ```sh
   <log 1>
   <log 2>
   <log 3>
   <QUESTION HERE>
   <QUESTION HERE> 
   # Execution stops here instead of the line above
   ```

   When obviously we would want to wait after each question individually. This happened because
   there was no synchronisation happening between threads and it was down to luck whether
   a 2nd thread would print anything between the first thread printing a question and locking stdout
   to wait for user input.

Both of these are quite common issues that arise when introducing parallelism as an afterthought to
a project. It is often very hard to anticipate what might go wrong when you make things run in
parallel.

> Just as a side note here. This blog post focuses on an interesting performance problem, and
> there's 2 groups of people that might come across this post:
>
> - those that have come across the problem before, to whom it must now feel quite trivial to
>   solve (at least in theory)
> - those that have not come across the problem before and are likely to be surprised by how much
>   of a speedup a different logging strategy can offer (as well as how complex it is actually
>   implementing it)
>
> If you are in the first category, you'll likely not find this too interesting as I am mostly
> writing this for the 2nd group.

## The Problem In More Detail

### Performance

The performance decrease is rather simple; when you print something out to your terminal, you must
lock [stdout (or stderr)](https://en.wikipedia.org/wiki/Standard_streams). This can cause various
problems

- For one, locking stdout (and later, flushing) is not instantaneous, they take time that adds up
- Locking stdout repeatedly (say in a for loop) can compound this effect
- Locking stdout repeatedly from different threads at the same time can further compound this effect
  (as well as mess with the order of prints as we'll talk about later). 
  
The last 2 points are the result of [lock contention].

How can we combat this? Simple! *Just don't lock stdout all the time! (duh?)*

But jokes aside that is how you actually combat this, this is formally called *IO Buffering*.
Instead of constantly locking stdout whenever you produce a log message, you could instead put that
log message in a vector for instance and only print the vector when it reaches a certain size, at
which point you clear the vector and repeat. 

This makes logging dramatically faster. You can play around with your buffer size to see what works
best for you, in my case I ended up using a size of 16.

This approach introduces another subtle problem however, what if you produce less logs in the
entire lifetime of your program than your buffer size? Well as of now, the logs would never be
printed! To fix that I took 2 approaches:

- The obvious one is to make sure you always flush your buffer just before exiting the program.
  This ensures that any remaining logs are always printed before your program terminates.
- Another idea (used in conjunction with the first one) is to *also* flush every *n* milliseconds.
  While this does not at first glance, achieve anything that the first point does not, we must
  remember that logs can often be useful as real-time feedback to users! If nothing is being logged
  while work is being done, the user might think that the program is stuck! For this reason, in my
  implementation, I also print the logs every 250ms, regardless of whether my buffer is full or not.

#### Blocking Work Is Bad Actually

Another interesting issue that arises is that, while significantly reduced by now, the time spent
locking stdout, flushing and clearing our buffer is time our main program completely halts all work
and does nothing until the logs are printed.

The solution to this is quite simple in principle but can be rather complicated and/or tedious at
best to implement given your programming language of choice: we need to run our log printing on a
separate thread! This makes it so our real work is no longer paused at all since buffering a log
message is just a vector insertion (which for all intents and purposes is instant) and printing it
now happens on a separate thread.

This can require a decent refactoring of your code and you must of course ensure that all prints
use your logger instead of interacting with stdout directly, otherwise, all of this is mostly
useless. 

> In Rust, you could use 
> [clippy lints](https://en.wikipedia.org/wiki/Lock_(computer_science)#Disadvantages) to deny usage
> of `println!`s!

Ensuring that data can be sent safely across threads is also crucial here, in Rust this is a
textbook application of [channels].

### Out-of-Order Issue

Because of the way that `ouch` works, we figured that simply locking stdout and stdin *in the
worker thread that needs to ask whether the user wants to overwrite the file* was a viable solution.

> We had briefly considered doing this blocking in the logger thread but the addition of bidirectional
> communication that would be needed for this between the logger thread and the worker thread (we
> would need to somehow tell the worker whether the user said yes or no) would significantly
> overcomplicate the code so we decided against it.

This is because the worker thread needs to pause its work to wait for user input anyway, we can't
keep working in the background while waiting for user input so this does not worsen performance.
While this is happening, other worker threads that do not require user input can keep sending their
logs to the logger thread undisturbed. The logging thread will of course be unable to interleave
its logs with our `y/n` overwrite question since we already took the stdout lock in the thread that
needed user input.

This part here deserves attention as, depending on the specifics of your implementation, it might
be that logs can be lost here; If you need to *be waiting* for a log message from other threads to
add to your buffer but your logger thread code is stuck trying to acquire the stdout lock, new
logs could be lost. With Rust channels, this is not a problem as messages are buffered internally
which means we can just receive them later.

This is a bit hard to convey with words so I'll try and clarify it with some pseudo-code.

```rs, linenos, hl_lines=10
Run in background (the logger thread):
  let buffer = [];

  loop {
    let message = channel.wait_receive_log_message();

    buffer.push(message);

    if buffer.is_full() {
      flush(buffer); // Needs to lock stdout
      buffer.clear();
    }
  }
```

Notice how there is a chance that `buffer.is_full()` is true but we can't execute `flush(buffer)`
if the lock for stdout is already held elsewhere. Depending on how your `channel` works, this can
disregard new messages so it is something to be aware of (again, with Rust channels this does not
happen).

## Putting It All Together

I ended up creating a ✨technical diagram✨ to convey the overall picture better than my writing
could.

{{ image(src="/img/efficient-logging/layout.svg") }}

As you can see, we have `n` worker threads spawned by main (1 for each input file in our case) as
well as a separate `logging` thread. All log messages produced by the worker threads are sent
to the logging thread which buffers them and prints them according to the approaches we mentioned
earlier. And any time we need user input, the worker thread locks stdin and stdout itself.

But how much faster was it really? Well here are the results of the benchmark I used in my pull
request:

- Before:

  | **_Files to extract_** | **_Time_** |
  |:---:|:---:|
  | both | 49.9s |
  | test1/test2 | 31.4s/31.2s |

- After:

  | **_Files to extract_** | **_Time_** |
  |:---:|:---:|
  | both | 16.7s |
  | test1/test2 | 12.9s/11.3s |

<!-- | **_Version_** | **_Files to extract_** | **_Time_** |
|:---:|:---:|:---:|
| ouch 0.5.1 | both | 49sec 942ms |
| ouch 0.5.1 | test1/test2 | 31sec 466ms/31sec 211ms |
| My fork | both | 16sec 795ms |
| My fork | test1/test2 | 12sec 975ms/11sec 381ms | -->

Quite the difference!

Just to explain the benchmark a bit more, as well as the "my cherry-picked-definitely-representative
benchmark!" comment from this post's description.

The benchmark from what I remember (I slacked for like 4 months before blogging about this) was as
follows:

- compress `ouch`'s repository into a zip `test1.zip`
- copy `test1.zip` into `test2.zip` to get 2 identical zip files
- decompress them both individually as well as in parallel and measure the time taken

"Well, how is this not representative!?!?!?" I hear you ask. Well, the majority of `ouch`s logs are
something like `file x has been extracted`. This means that decompressing a full repository
including `.git` and the `target` directory will produce *a lot* of logs since there are *a lot* of
files. 

For reference, after generating a debug and release build, I seem to have just shy of 3.5k files.

Of course, my comment about representativeness is rather exaggerated; it really depends on what
you use `ouch` for. If you decompress large, single files then these changes will likely make
no perceivable difference whatsoever to you. But if your archives have a decent amount of files
in them then this is quite the improvement.

> You can check the full PR [here](https://github.com/ouch-org/ouch/pull/642).

## Wrapping Up

Overall, this was my proudest OSS contribution so far. It was an interesting, performance problem in
a big (and daunting), unknown Rust code base of a tool that I use frequently, ticked a lot of boxes!

It was nice weighing the pros and cons of different approaches with [Marcos], the (main?) maintainer
of `ouch`. And even though he MISCREDITED the WRONG PERSON in
[his issue](https://github.com/ouch-org/ouch/issues/643) because I guess we have similar names?
or something??? (unforgivable), I forgive him because he was really nice to talk to while slamming
my head against a wall trying to work this stuff out (he was seriously nice, go give [ouch] a star
if it seems like something you'd use).

But yeah. It was a nice boost mentally to learn that I *can* just jump into an unfamiliar project
and solve non-trivial issues. 10/10 would recommend.

Till next time!

[ouch]: https://github.com/ouch-org/ouch
[lock contention]: https://en.wikipedia.org/wiki/Lock_(computer_science)#Disadvantages
[channels]: https://doc.rust-lang.org/std/sync/mpsc/fn.channel.html
[Marcos]: https://github.com/marcospb19