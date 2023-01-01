---
title: "2022 Recapped"
description: "A look back at another year of progress."
tags: ["Year Recap"]
keywords: ["2022", "Recap"]
date: 2023-01-01T13:20:00+02:00
draft: false
---

## Introduction

Early this year I [tweeted](https://twitter.com/Tony_Barotsis/status/1478046558490927112)
the following;

{{< tweet user="Tony_Barotsis" id="1478046558490927112" >}}

I listed a few things I wanted to work towards over this now past year. I had this tweet pinned
to remind myself of these goals, to reflect on them once the year was past and to come up with
new goals for the next year, so time to do just that!

A *lot* has changed over this last year when it comes to my views and approach to software &
programming as a whole (which is always a good thing) so let's talk about that!

## Code Complexity

I came across the following image through a retweet (which got deleted for some reason) which I
feel perfectly summarizes this past year for me.

{{< image src="/img/2022-recapped/progress.jpg" href="https://twitter.com/flaviocopes/status/1417007331930423298" >}}

I spent most of the first half of 2022 looking into "enterprise software development" or in other
words, learning a bunch of design patterns and different abstractions in Java and C#. 

Now don't get me wrong, all these have some value to them, especially when working with a lot of
people. Design patterns are great in the sense that they are standard solutions to common problems.
I can see their value if you are part of a big team developing software that you know
is going to be actively worked on many years from now where the level of decoupling many of these
design patterns offer is great for avoiding breaking changes. Not to mention that a lot of
programmers will instantly recognize a lot of the more commonly used patterns and understand
the intent of the programmer that added it to the codebase which is also useful.

Of course, thought must still be put into them as an inappropriate pattern can cause issues and make
the code harder to work with, as can the overuse of such patterns when they are not needed.

Looking back at the earliest personal project I worked on this year
([Rember](https://github.com/AntoniosBarotsis/Rember)), I cannot say I like the code I wrote as I
now find it unreasonably complicated on so many levels. For the simple job of essentially
writing some text to a file, I can very confidently say that I did not need to use abstract classes,
interfaces, builders, facades, singletons and other abstractions. Looking back, I could've
written the whole project in a fraction of the code using just one struct and a builder.

That said, however, I'm both glad that I went through that and that I now feel like I know better.
It is undoubtedly useful to know of these patterns and understand that they *can* be used in
certain scenarios but it is also useful (arguably even more so) to understand when and where you
*should* use them. At the end of the day, design patterns are another tool in your belt and I'm
glad I understand them a lot better than I did a year ago.

This whole idea of "simpler" code later pushed me to learn Rust which I'll come back to a bit later
as I'm taking stuff in chronological order :)

## Parallel Programming

I had been interested in parallel programming for a while and I finally got around to learning
some basics this year!

I read a bunch of stuff about parallel programming and especially its caveats and got to apply
most of that in 3 projects: [Veritas](/posts/posharp/), a university course titled "Computational
Intelligence" and a Game of Life implementation.

With Veritas I learned about thread pools (albeit with pretty messy code) and locking for
synchronization. I experimented a lot to find a more efficient way of spawning some external
processes used in testing a compiler.

For the university course, I got some experience in introducing parallelism to
existing code (of course making sure it was actually better) and making a neat, non-disruptive
interface for it, atomics and futures (which were not a new concept but learned some more about how
they work). I was implementing Ant Colony Optimization with 2 of my colleagues.

My game of life implementation was mostly about exploring numerous optimizations and
determining where the performance bottleneck lied (which was mostly memory related) and how to
plan around that.

There's definitely a *lot* more to learn and it's definitely one of the things I'll be trying to do
over the next year. I also purchased my first-ever [programming book](https://marabos.nl/atomics/)
on Rust low-level concurrency which I look forward to reading :)

## The last stretch of my abstraction obsession

I had a sudden interest in System Design and Software Architecture sometime roughly in the middle
of the year. 

I learned a lot about the bottlenecks in big systems (aka databases), application monitoring and
telemetry with tools like InfluxDB and Grafana, some basic load balancing and reverse proxying
with K6 and Nginx and a bunch of different ways of alleviating pressure from databases to make a
system faster and more responsive. I also learned a bunch more about Docker and some Kubernetes
basics.

A lot of my research into this came from speeches given or organized by AWS which eventually lead
me to want to find a project that used their platform (especially since Heroku dropped their free
tiers). I ended up suggesting to my dad that I built him an automated SMS service that sends
reminders to his patients when their bookings are near which (*~~just as Rember had too many design
patterns~~*) taught me a bunch about deployments with Docker (again) and testing as I needed to
have a certain quality standard since I was not going to be the one using it. Understanding the
value of proper logging and alerts was another benefit of working on this. I, unfortunately, had
to deal with parsing date times and phone numbers but at least I can now say that I have survived
that!

## Everything is overly complicated - burnout

I feel like, after learning a bunch of all this convoluted stuff about high-profile enterprise
software and good practices and fancy new stuff and whatnot, I ended up realizing that the vast
majority of people that use these ideas and concepts, do not operate at a scale that needs them.

I had also started to dislike bloated software and software that would just not do the one thing
it was designed to do without crashing a few times here and there (looking at you NPM and PIP).
I stumbled upon some people like [Jonathan Blow](https://www.youtube.com/watch?v=FeAMiBKi_EM)
who have very vocal (although sometimes a bit extreme) opinions on this topic which really pushed
me to adopt this idea of "minimal and working" software, both in the software that I use
(as in the form of libraries) in my projects and in the software that I make.

These ideas pushed me to start learning Rust as it embraces and often encourages this idea of
correctness, simplicity and efficiency.

## Rust 🦀

I worked on [Rss2Email](https://github.com/AntoniosBarotsis/Rss2Email) in the last few months of
2022 (also wrote a [blog post](/posts/rss2email) on it) which was both a ton of fun and a great
learning experience. I have a few ideas of stuff that I would like to build with Rust next but
nothing too concrete yet so we'll see what's next I guess.

Rust to me is more than just the programming language, it's a collection of tools and software
that prioritize the ideals that I mentioned earlier. Learning more about it has been a blast and
I don't think I've ever been more passionate about a specific tool before. I will definitely
focus most of my time in 2023 on learning more about it.

There are way too many great things about Rust to list in one paragraph so if anyone is actually
reading this and you haven't tried it, please do! Take your time to learn the basics and I'm sure
you'll come to appreciate it immensely just as I  did :) 

I am in fact so passionate about Rust that I am having my first-ever live talk/workshop on it at my
[University's Google Student Developer Club](https://gdsc.community.dev/delft-university-of-technology/)
sometime in January which I'm super excited about!

## Reviewing my goals from last year

After having talked about all this stuff, I want to come back to these goals again and talk about
them a little bit.

{{< tweet user="Tony_Barotsis" id="1478046558490927112" >}}

- ❌ `finish Demeter`: Demeter was this toy project I started to get some more experience with C#
  and enterprise-ish concepts which I ended up dropping pretty soon. I got my experience from
  Rember and that SMS service I built for my dad which was both a lot more fun (and realistic)
  and I generally drifted away from that type of software. The stuff that I was going to try and
  do in the project was nothing new to me (which is also why I got bored of it pretty
  quickly) so I'm not really sad that I didn't end up finishing it.
- 🤷‍♀️ `.NET IoT`: I don't recall having anything particular in mind when I wrote this. I think I may
  have thought of this because I bought a Raspberry Pi, not really sure. In any case, it's not
  something I am really interested in anymore although I guess if that suddenly changes, I am
  probably better equipped for it seeing as how I am somewhat familiar with Rust.
- ✅ `Nuget package`: I did do this with `Rember` so that's nice. This was not really about
  `Nuget` in particular, just generally publishing something. I also published `Rss2Email` which
  had a much more complicated deployment pipeline which I'm proud of and unlike `Rember`, I am
  actually using it! 
- ✅ `ORM`: I am realizing that I am bad at setting goals, not because this was too hard or vague
  but because it is not *exactly* what I wanted to do. I was interested in some of the stuff that
  made ORMs work in languages like Java and C# such as reflection and code generation, both of which
  I explored in at least one project so while I technically did not do this, I satisfied my
  curiosity on the topics that made me write it down, which is why I consider this "*technically*"
  complete :)
- ✅ `student team` I guess the Google Student Developer Club isn't exactly a "research" team but
  it works for me. I have the chance to interact with a bunch of cool people and also share my
  passion for software through talks and workshops which is what I was going for
- ✅ `kubernetes`: I did do quite a bit of reading up (and a bit of playing around) with Kubernetes
  when I was looking into system design. I definitely went over the stuff that I had in mind
  so I guess I also consider this one complete.

I actually did better than I thought which is nice!

One takeaway I have from these goals is that I need to actually understand what it is that I want
to learn as, more often than not, I am more interested in exploring specific concepts that may or
may not appear in certain types of projects instead of those projects themselves. Can't wait to
make the same mistake for the next year's goals!

## The state of this website

I haven't really mentioned anything about this so I just felt like writing some stuff here cause
why not.

I quite like how it looks for one, the theme is great and simplistic (fitting!).

The look and feel of the website plus the ability to mess around with it and try new things are
the main reasons why I'm glad I went for the custom approach instead of using existing platforms,
would definitely recommend anyone reading this to do the same if you're interested in blogging or
just making a landing page for yourself on the interweb.

I also feel somewhat comfortable with Hugo and messing around with its templating which was really
confusing to me a year ago for some reason.

I think that my blog posts are getting better over time although I have different goals for each
post so that progress might not be apparent to third parties but I feel good about it yup 👍

I do kind of wanna go over my about page and rewrite some parts but other than that, everything
is nice.

I also played around with analytics services for a bit, switched from Google analytics because
every browser and browser plugin blocks that to [Umami](https://umami.is/) which was cool but
I couldn't host it for free indefinitely so I switched again to [Posthog](https://posthog.com/)
which provides a free tier. In case anyone is reading this and is willing to pay, 
[Plausible](https://plausible.io/) seems pretty good and I've been hearing nice stuff about it.

I'm also happy with the number of posts I made. I made a post each time I worked on something
interesting, will definitely try to keep this up for the upcoming year!

## My 2023 goals

I was vaguely interested in this idea of zero-copy deserialization ever since I made a few 
contributions to [this](https://github.com/google/zerocopy) repository and at some point, I found
[this](https://youtu.be/DM2DI3ZI_BQ) great talk on it which made me really interested in the
concept. Zero-copy deserialization is definitely something I want to look into over the next year.

I already mentioned how I want to learn and practice more concurrent programming but I also want
to learn more about distributed computing which is somewhat, vaguely related to concurrent in some
ways? Some of the ideas between them are somewhat similar, do not question how my interests appear.

I've been interested in developer tooling and libraries for some time now and although I've already
put in some work for both of these, I would love to work on them some more, I like feeling like
I'm useful to other developers 👍

Lastly, I kinda wanna try and contribute to open-source projects a bit more. It is definitely not
an easy thing to do but you kind of have to start somewhere. I already found myself contributing
more than in previous years either by opening issues or with actual PRs, most of which were in Rust
projects! This is definitely the scariest to-do on the list but I know I'll be very proud to make it
work so, only time will tell!


Learning from the previous year, I tried **not** to include specific projects this year
although I do have some in mind already, some combine multiple items from my list which is nice.

{{< tweet user="Tony_Barotsis" id="1609131868984860673" >}}

Till next year by when I will have hopefully completed all of these!
