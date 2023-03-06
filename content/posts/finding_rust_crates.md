---
title: "Finding Rust crates"
description: "A beginner's guide on discovering the right Rust crates for the job."
tags: ["Rust", "No Coding"]
keywords: ["Crate", "Discover", "Ecosystem", "crates.io"]
date: 2023-03-06T23:42:39+01:00
draft: false
---

## Introduction

A common complaint from Rust beginners is:

> "*The main issue is just communicating currently suggested libraries.*"

I feel like most people that have been actively using Rust for a few months likely don't suffer from
this as they learn their way around the ecosystem but I also feel like most people would agree that
this is a problem for beginners. This is more so the case in Rust than most other languages because
the standard library does not implement a lot of the things that you'd expect it to, coming from
other languages. While this does have very valid reasons to be the case, it just makes the life
of a beginner harder.

## The Basics

I am going to mention a few crates that are so "*basic/common sense*" if I can call it that, that
you might have issues looking for with the methods I'll list later. By "*basic/common sense*"
I definitely do not mean *simple to implement* as you'll see soon, just things that you would most
likely not *look* for in a different language.

### Async Runtimes

Yes, that's right, Rust does not come with its own async runtime! There are multiple reasons for
this, the simplest being that not all runtime strategies are created equal; 

Some are great for high-performance file I/O, some are focused on distributed systems, some are
targeting embedded devices and some are built to be as general-purpose as possible.

For the vast majority of cases, you'll want to use [`Tokio`](https://tokio.rs/). Some other available
options include [`Bastion`](https://www.bastion-rs.com/), [`async-std`](https://async.rs/),
[`Embassy`](https://embassy.dev/) and [`Glommio`](https://github.com/DataDog/glommio).

You can read more
[here](https://rust-lang.github.io/wg-async/vision/shiny_future/users_manual.html).

### Error Handling

Rust's error handling can get verbose sometimes, which is exactly why there are a bunch of crates
that can help you with that.

For library code, [`thiserror`](https://github.com/dtolnay/thiserror) is often used whilst for
user-friendly errors, [`anyhow`](https://github.com/dtolnay/anyhow) and
[`miette`](https://github.com/zkat/miette) are common. Of course, if you are working on a project
that has both a library component as well as a binary one, you can definitely use both `anyhow` and
`thiserror`/`miette` very easily.

### Testing

While Rust does provide you with a few ways to write assertions (you can write just about anything
with a combination of [`assert!`](https://doc.rust-lang.org/std/macro.assert.html),
[`assert_eq!`](https://doc.rust-lang.org/std/macro.assert_eq.html) and 
[`matches!`](https://doc.rust-lang.org/std/macro.matches.html)), people coming from languages
like Java or C# might find 
[`assertables`](https://github.com/sixarm/assertables-rust-crate/) or
[`spectral`](https://github.com/cfrancia/spectral) useful. 

There's also [`pretty-assertions`](https://github.com/rust-pretty-assertions/rust-pretty-assertions)
for more readable outputs and [`static-assertions`](https://github.com/nvzqz/static-assertions-rs)
for compile-time assertions.

## Finding Crates

If you already vaguely know what you're looking for, I'd recommend the following steps in order:

1. Try and search for the thing you are looking for on GitHub (remember to filter by programming
   language!). I find GitHub's search to be quite good at this and I usually find what I need
   rather quickly. I also like checking the number of stars the project has along with the number
   of issues and when the last commits were made before using a crate which I can of course see
   immediately this way. 
2. Take a look at [crates.io](https://crates.io/) (or [lib.rs](https://lib.rs/)) and try to make
   use of the crate categories. For instance, say you are looking for parsers, you can query
   [this](https://crates.io/keywords/parser) (or [this](https://lib.rs/parser-implementations))
   to find the most commonly used crates of that category.
3. Just google it. If you haven't found what you need yet (and hopefully after you tried
   a few query variations already), you can try plain old Googling (or DuckDuckGoing I guess).
   This has the added benefit of going through blog and forum posts on top of GitHub, crates.io etc.
   Just prefix your search term with `rust` and see what you get.
4. If all else fails, just ask the community! I left this for last as it usually takes more time
   than typing 4 words in a search bar but it definitely works! There's 
   [Discord servers](https://discord.gg/rust-lang-community)
   [forums](https://users.rust-lang.org/),
   [Subreddits](https://www.reddit.com/r/rust/) and
   [Zulip chats](https://rust-lang.zulipchat.com/) (again in the order I'd use them) where you can
   ask for help from other people.

> For example, recently I got a few ideas that required me to use a
> [Finite-state transducer](https://en.wikipedia.org/wiki/Finite-state_transducer) which I would say
> is relatively niche for Rust at least. I instinctively searched for `finite state transducer` on
> GitHub, filtered for Rust repositories and very quickly found
> [`fst`](https://github.com/BurntSushi/fst).

## Discovering Crates

There are a few ways to passively discover interesting crates without actively looking for them.
One that I enjoy a lot is [This week's in Rust](https://this-week-in-rust.org/)'s section called
"*Crate of the Week*". You can often find people making posts in the
[Rust subreddit](https://www.reddit.com/r/rust/) when they come up with cool ideas and the same goes
for channels like `#showcase` in the
[Rust community Discord server](https://discord.gg/rust-lang-community).

There's also [Rustacean Station](https://rustacean-station.org/) which is a nice podcast that often
features some very interesting people. You can find their episodes on Spotify for sure and likely
most other big podcast platforms.

## Closing

This is the first post I've made that is not just me walking through the last project I just
finished working on but hopefully, you still learned something from this! Learning your way around
Rust's complex ecosystem can be very challenging as a beginner but you should always remember that
the rest of the community is here, willing to help you!

Till next time!
