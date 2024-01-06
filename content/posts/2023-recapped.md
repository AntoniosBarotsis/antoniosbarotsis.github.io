---
title: "2023-recapped"
description: "This one had quite a bit of Rust!"
keywords: ["2023", "Recap"]
date: 2024-01-06T19:19:01+02:00
draft: false
taxonomies:
  tags: ["Year Recap"]
---

## Introduction

This year felt rather quick for some reason, I feel like I barely remember anything from before
summer.

Well anyway, earlier this year I set some goals to work towards throughout the year, just like
the year before;

{{ tweet(url="https://twitter.com/Tony_Barotsis/status/1609131868984860673") }}

It has been quite some time since and reflecting on stuff that happens over a year is something I
always find interesting. Also probably a good idea to come up and write down some goals for the
upcoming year, even if I'm a few days late.

## 2023 Goals Recap

### Learn more Rust

[Last year](../2022-recapped#rust-crab) I wrote that

> "*I will definitely focus most of my time in 2023 on learning more about it.*"

And I definitely did. The fact that [`rss2email`](../rss2email) was a whole year ago is crazy to me
because that's what kickstarted my Rust arc.

I already mentioned the individual projects I worked on [here](../../about#2023) and you can also see
the repositories 
[on my Github](https://github.com/AntoniosBarotsis?tab=repositories&q=created%3A2022-10-01..2024-01-01&type=source&language=rust&sort=)
although a few private ones are omitted. The 2 notable ones are the ones mentioned in
[this](../rewrite_cs_in_rust) and [this](../python_package_written_in_rust) blog posts.

I also read through a lot of articles and a couple of books on the language, both of which I
learned a lot from and will definitely continue to do next year. I still have a few books I have
bought but have yet to read so I need to try and stop impulsively buying new ones before those are
done 😅

I even attended a few [local conferences](https://www.meetup.com/rust-amsterdam-group/)!

### Build a decent TUI app

Never really came up with an idea for this, even though I always had it at the back of my mind. I
guess [I can say I finally did some UI](https://github.com/AntoniosBarotsis/controller-trigger-recorder)
at last but TUI specifically.

To be honest, I don't really mind not having done this as, again, I didn't have a good reason to
at any point but I'll be keeping it in mind throughout 2024 as well. I think some sort of
dashboard could be cool, I'll likely revisit this if I get around to doing anything related to
distributed systems stuff as it could be useful for debugging and observing what is going on.

### Learn (and apply?) distributed systems basics

Did not do quite as much as I had in mind but then again, I did not know too much about this to
set any sort of accurate goals for this anyway. 

I started reading ["Designing Data-Intensive Applications" by Martin Kleppmann](https://archive.org/details/designing-data-intensive-applications-the-big-ideas-behind-reliable-scalable-and)
which touches on quite a few interesting and relevant topics but I still have a decent chunk of the
book to finish. I also took a look and did ~half of the
[Fly.io distributed systems challenges](https://fly.io/dist-sys/3b/).

My main issue with distributed systems is that it is quite hard to find a problem that I have that
could be solved by distributed systems as usually the scale required for them is way bigger than
anything I am dealing with. I could build something arbitrarily like a distributed cache but I like
working on things that I will actually use or at least need once.

One idea that I have for this is perhaps looking into the
[Actor model](https://en.wikipedia.org/wiki/Actor_model) as that *should* share some of the same
philosophies of distributed systems. Of course, a lot of stuff will probably not overlap but it is
better than nothing.

<!-- https://fly.io/dist-sys/3b/ -->

### Look into zero-copy deserialization & parsing in general

Well, I did make an [ASCII Grid format](https://modis.ornl.gov/documentation/ascii_grid_format.html)
parser, as well as needed to do some parsing in
[Shuttle's Christmas Code Hunt](https://www.shuttle.rs/cch). The former used 
[`nom`](https://github.com/rust-bakery/nom) and a bunch of lifetimes that technically qualify
as zero-copy. I also used [`pest`](https://github.com/pest-parser/pest) in that project which I
found easier.

I definitely feel like I could use some more practice but when is that not the case {{ shrug() }}

### Apply concurrent programming

This went quite well!

I applied a lot of stuff from the [Rust Atomics and Locks](https://marabos.nl/atomics/) book in
my University software project (the one with the self driving robot), some of
[my solutions](https://github.com/AntoniosBarotsis/shuttle-cch23/blob/b4060ca2ffea30937319188b7160940d2c0effba/src/days/day_19.rs)
to Shuttle's Christmas Code Hunt (a previous iteration was quite a bit more complex but I ended up
scraping it), my [Mandelbrot set renderer](https://github.com/AntoniosBarotsis/mandelbrot) as well
as my [controller ui](https://github.com/AntoniosBarotsis/controller-trigger-recorder).

I ended up using some SIMD in my Mandelbrot renderer as well which was quite interesting and I also
ended up reading a lot about SIMD-able sorting algorithms for whatever reason which are
quite cool!

### Develop a general-purpose library for devs

I'm pretty happy with this as well. The two most notable ones have got to be my Software project
and the [`confusables`](https://github.com/AntoniosBarotsis/confusables) library.

In the Software project I worked on library functions that the students using our platform would use
as well as a testing framework for testing some of our ROS node code that we ourselves ended up using.

As for the `confusables` library, I stumbled upon the fantastic talk
["Plain Text" by Dylan Beattie](https://youtu.be/_mZBa3sqTrI?si=70dtSnU2HJ93nBnh) and ended up
reading up on random Unicode things, eventually coming across confusables and making a library
for detecting them. I experimented with creating JavaScript bindings for the crate as well as
compile-time code generation. It also ended up getting a
[surprising amount of downloads](https://crates.io/crates/confusables) although I can't be sure how
many of those are automated and how many are actual use cases. Still pretty cool though.

### Contribute more to Open Source

This was another good one, I feel like I made a
[decent amount](https://github.com/pulls?q=author%3A%40me+-user%3A%40me+sort%3Aupdated-desc+created%3A2022-10-01..2024-01-01+),
one of them was even towards the Rust compiler! (it was definitely not a typo in the docs somewhere
do not look it up)

I also made a [temporary bug fix](https://gitlab.com/veloren/veloren/-/merge_requests/3853) for an
open source game I was playing at the time with a couple of friends. It was quite funny knowing I
stopped dying to a bug that I myself had fixed once it was published.

## 2024 Goals

I think I want to shift my focus, at least partially, to reading more instead of building small
projects. Although they are fun, I feel like I am at a point where I've used Rust extensively and
doing more small projects won't teach me quite as much. I'll probably still build random stuff since
they're fun and often interesting/useful but I don't think there's a point in setting that as a
"goal" necessarily. I still have 3-4 books (none Rust specific) I've bought and haven't
finished/started so I definitely want to be done with those and there are always more books to read
if I'm done early.

I still want to learn more about distributed systems. As I mentioned earlier, I find it hard to find
some tangible project idea that makes use of them to anchor myself to and build towards but reading
more about them is a good starting point so I'll be doing some more of that. 

Lastly, and my main goal for the year, is to look into computational fluid dynamics and attempt to
build a simulation showcasing either something like the aerodynamic properties of a car or some sort
of water simulation. This is quite far outside the area of things I know so I really can't tell
now if the vague idea that I have of an end result is realistic to achieve over this year alone.
Roughly what I have in mind is something like a [wind tunnel](https://en.wikipedia.org/wiki/Wind_tunnel)
simulation where a car is placed in the middle of the frame and air is blown out of one side, allowing
you to see how it interacts with the various parts of the car. There are so many questions I need to
answer even before I start doing too much research on this such as:

- do I want this to be in 2d or 3d?
- what will the performance look like and will I have to use a GPU? Does that affect my algorithm
  choice?
- how easy do I want creating objects to test to be?
- should I aim to support importing objects via some standard format?
- how do I even get things to show up on screen? Should I use like a game engine or something?
- is something like this possible in real-time or should I aim for more of a record and playback method?

This probably comes off a bit out of the blue for the type of stuff I usually do. Truth is, I've
just been getting fascinated by the aerodynamics of (race)cars recently and I'm quite annoyed about
the fact that I don't understand how aerodynamics work at all. Unfortunately, I was never a physics
person so instead of reading a book about aerodynamics, I will instead simulate them as any
non-sensible software person would do.

I would also like to blog some more this year and this whole aerodynamics arc could make for a nice
little blog series.

## Closing

Overall, I'm pretty happy with how the year went actually. I think I overall managed to hit or at
least make good progress towards all of them. Let's see how far I get this time!

{{ tweet(url="https://twitter.com/Tony_Barotsis/status/1743687653386506460") }}

This is more or less fewer goals than last year but you know what they say, less is more and the
more the merrier.

Till next year!
