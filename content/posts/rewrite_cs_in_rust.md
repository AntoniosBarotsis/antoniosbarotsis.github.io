---
title: "Rewriting it in Rust"
description: "Like the joke but for real this time."
keywords: ["Rust"]
date: 2023-12-31T20:56:22+02:00
draft: true
taxonomies:
  tags: ["Coding", "Rust"]
---

## Introduction

A few years ago I worked on a notification service that would get upcoming appointments scheduled in
[Microsoft Bookings](https://www.microsoft.com/en-us/microsoft-365/business/scheduling-and-booking-app)
and send a text message reminder to the person who made the appointment a few days prior.
This was in an effort to reduce the amount of appointments that were cancelled too late for a new
one to be booked in their place as well as make it less likely for people to forget about their
appointment altogether. This was not too hard to make and it worked wonders! I recently ended up
rewriting it in Rust over two afternoons and I ended up reflecting on a few things that I found
myself wanting to write about so here we are!

> As a small note, I don't think I'll have too many useful things in here, mostly just my hindsight
> thoughts about stuff. I just haven't written anything in a while and wanted to get back into
> it again.

## What did the project look like?

The project was using AWS [Lambda](https://aws.amazon.com/lambda/) for hosting,
[SNS](https://docs.aws.amazon.com/sns/latest/dg/welcome.html) for sending text messages and
[SM's parameter store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
for storing an encrypted refresh token.

The appointment data was grabbed from
[Microsoft's Graph API](https://learn.microsoft.com/en-us/graph/use-the-api) which also meant
configuring some stuff on
[Azure Active Directory](https://azure.microsoft.com/en-us/products/active-directory-ds).


## What did I dislike about the old implementation?

As I mentioned though, I worked on this about two years ago and while that may not sound like much,
it feels like quite a long time ago if you were relatively new to programming at the time. I've since
changed the way I write code quite a bit and if you do not actively dislike code you wrote that long
ago you have got to be doing something wrong!

For starters, it was written in C# which I have not really used at all since and even though it is
a "simple" language, I would much rather have it written in something I actively use today.

As you may have noticed, there are _a lot_ of working parts and services involved in this project
(or at least for me, I don't know if this is more common to anyone reading this!), this means
handling a lot of potential errors even if my code does not actually do all that much. This was an
absolute breeze in Rust with its `Result`s and `Option`s while in C# I got caught off guard more than
once with something blowing up in production because it was not always obvious when something
might or might not explode.

A lot of the tooling I used was simply _a lot_ less convenient than what I am used to in Rust,
talking specifically about dates and JSON (de)serialization. Now, I am not saying that both of these
are necessarily substantially better in Rust, but they _are_ better than the ones I used. I simply
do not use C# enough to know the best tools for these things, there may have been (or since developed)
way better libraries, I just don't know about them. Rust's
[`serde_json`](https://crates.io/crates/serde_json) is great and
[`chrono`](https://crates.io/crates/chrono) is simply fantastic. I cannot stress how great it is to
express timezones in the type system, saved me so many headaches.

To run my code locally I had to use
[some official command line app](https://www.nuget.org/packages/Amazon.Lambda.TestTool-6.0/)
that was just annoying to use. I understand it is in preview but it has been in preview since at
least 2 years ago and it looks the same as it did back then. When I switched to Rust I used
[`cargo lamnda`](https://www.cargo-lambda.info) which was a lot better. 

### A small tangent (me ranting)

> _"But C# has added those cool nullable `T?` types that effectively function as Rust's options,
> what is so different with them that you can't handle them!"_

Excellent question! Well, since this C# feature, now also present in most other similar languages
I can think of actually, is more of an afterthought;

- it did not exist in the language originally, this means that a lot of code was written *before*
  this was even added so it could not have been used.
- since backwards compatibility is a thing, nothing is stopping anyone from declaring a type as
  "non-nullable" (ie, `T` instead of `T?`) and then simply setting it to null at some point.
  This is a fundamental problem with these languages that I can't see how it could be remedied.
  So while seeing `T?` in signatures is convenient, you might as well treat all `T`s as nullable
  as well which kind of defeats the purpose.

And of course exceptions, unlike `Result`s, are not always obvious that they can be thrown.
Sometimes they are mentioned in the docs, sometimes they are not, especially when they are deeply
nested {{ shrug() }}

## The main problem

My main issue was really just _how_ I wrote the code, regardless of whatever tooling I used. At the
time, a bunch of "clean code" and enterprise-style Java was fresh in my mind from university
courses and projects so you can bet I was dependency injecting absolutely everything. I was not
quite at the level of abstract factory builder factories but I had my fair share of unnecessary
abstractions.

This was in retrospect a great decision because I really got to see how terrible that type of code
can often be, especially when you need to work on it for a few years. The mental complexity of
everything was so high I had to spend a few minutes each time I wanted to make a small change just
to remember where each service and interface was located. Debugging was even worse because of this.

I don't exactly regret it per se because I remember that at the time I wanted to learn more about
that style of programming and I intentionally included a bunch of those ideas in my codebase. Had I
not done this, who knows, I could still be advocating for "clean code", instead I lived to tell the
tale.

## So how did the rewrite go?

It was pretty smooth actually but as I said, the code that I had to write in the end was not that
much. Plus, the second time you do anything is significantly easier than the first so no surprises
there. I ended up with about ~500 lines of code in the end but that included some new functionality
that took about 100 lines, as I said it was _really_ not that much. Still about half of my original
code though so that's always a nice thing to see.

I am quite happy with the DX improvements, especially the local environment and deployment speeds.
Ending up with a 6mb zipped binary is definitely helping that over the 400mb Docker image I had
previously!

## Closing thoughts

Would I do it again? Probably. 

Although I don't think I will ever really like these very "managed" environments like AWS Lambda.
They work fine and all but I really just like having a normal project I can just run from my
terminal with no instrumentation required. Lambda is often too convenient unfortunately so there's
that I guess.

But anyway, that was fun nonetheless.

Till next time!
