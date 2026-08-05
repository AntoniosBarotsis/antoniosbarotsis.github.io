---
title: "Peer to Peer Groceries"
description: "Most overkill todo list of all time"
keywords: ["Rust","Distributed Systems", "p2p", "peer to peer", "CRDT", "Conflict-free Replicated Data Types",
  "Mobile", "tauri"]
date: 2026-08-06T01:26:02+02:00
draft: true
taxonomies:
  tags: ["No Coding", "Rust", "Distributed Systems"]
---

## Introduction

For some time now I've been wanting to learn more about distributed systems and [Conflict-free Replicated Data Types]
(_CRDTs_) and even though I've read a bit about both of these, I never built anything that utilized them.

Thankfully in my infinite wisdom (and mostly boredom) over the summer, I found an excuse to build something that
uses both of these: a ~_glorified todo list_~ peer-to-peer grocery list tracker!

## Background

Me and my sister have been doing grocery shopping for the whole family recently and in an effort to buy everything
we need faster, we usually split up and collect whatever we need in parallel. 

The "problem" with this is that our
grocery lists so far have been WhatsApp messages we each copy paste in our phones' pre-installed note apps.
Because we never actually plan out who should buy what, we waste precious seconds figuring out what items we each
collected and what we still have to buy. Technically we _could_ use something like Microsoft's ToDo which from what
I remember does let you share the "tasks" with someone else but that is:

- boring
- has too many bells and whistles we don't need/want
- very annoying to set up (probably takes like 5 seconds to share a list)
- probably needs accounts
- needs an internet connection

Not sure if this is a common occurrence but half the supermarkets I go to either have horrible reception, horrible WiFi
or both.
At one point last year I saw [Bitchat] and thought it was a cool idea so naturally I figured Bluetooth would solve my
connectivity issues. 

The other 4 bullet points were easily solved by making a barely-functional mobile app over the
course of two weeks or so because engineers like nothing more than looking at a pretty decent wheel someone else
created and thinking "I could make that but worse" and then doing just that!

> At the time of writing this, I'm waiting on the maintainer of the BLE crate(s) I wanted to use to respond to
> an issue I've been having (I think it might be on the crate's end but we'll see) so right now I am not actually
> using BLE but [mDNS]! 
> 
> This should be near-trivial to change in the code but it is worth pointing out because, _though
> I haven't tested this_, I doubt that mDNS is allowed in public networks, like supermarket WiFi. So _technically_ the 
> app is kinda useless at the moment, obviously I made it for fun so I don't care but yea.

### Short Note on the Full Project

Even though this had to be a mobile app, I am actually very uninterested in UIs and as a result I ended up vibe coding
most of that. I don't think it is too interesting to talk about but the [code] is public if you want to take a look.

Hopefully by the time anyone reads this I'll have actually added READMEs explaining how to build and run it but if not,
this is what the app looks like now running on my Android phone.

{{ image(src="/img/p2p-groceries/screenshot.webp", style="max-width:30%") }}

You can add/edit/remove items and mark them as bought or not. The save button serializes your list to disk so you can
make it at home, close the app, then open it at the supermarket and be ready to go.

## CRDTs

Before we talk about any of the networking, I think it makes sense to briefly talk about CRDTs.

I feel like a lot of people who might not know about CRDTs have probably heard of multi-threading and if you've
heard of multi-threading you probably know that mutating the same thing, at the same time from multiple threads
is a big no-no. 

I think, in some cases at least, it makes sense to think of distributed systems as a multi-threaded
program where instead of different threads, code is running on different devices. As such, it shouldn't be shocking
that you can't easily have two devices maintaining some shared state between them which they can both edit 
concurrently. Unlike a thread-safe object, however, (think a concurrent hashmap), safety & correctness are not achieved
via locks but via eventual consistency, an Operation Log (oplog) and algorithms for "merging"/applying operations to
our state reliably.

For the opglog to make sense, it needs to follow some order. Naively, one might consider using time - if event A
happens earlier in time than event B then obviously `A < B`. The problem is that it is not actually that simple;
you've probably noticed [clock drift], especially in offline devices such as a wristwatch. Even if we know
that all our peers' clocks are correctly set (and no one is "cheating" by rewinding theirs to gain precedence!),
clock drift can eventually still put events out of order. 

Obviously this doesn't work, what we need is a *causal* relation (A causes B therefore, A proceeds B) and this is where
the [Vector Clock] comes in! Now although it sounds terribly fancy, a vector clock is _essentially_ a dictionary
that maps **actors** (each device) to a count representing how many actions they've done. The idea is to
attach this clock to each operation you perform as a way to "timestamp" it. 

For example: We start with an empty state. Actor `A` decides they want to add something to a CRDT so they broadcast
their operation and their incremented clock: `{A:1}`. The same actor then decides to update the CRDT so they
broadcast with clock `{A:2}`. Now say for the sake of the example that these two broadcasts arrive to peer B out of
order. Because each op came with `A`'s clock, `B` can confidently say that the op that came with the smaller clock
(`{A:1}`) happened first.

### Resolution Strategies

It is worth mentioning that this doesn't always work by design; vector clocks only determine a **partial** ordering
which means that not all clocks are comparable. As an example, consider the case where both actors add their own
values, producing clocks `{A:1}` and `{B:1}` respectively, we can't tell which came first! We have to choose our own
resolution strategy for cases like this.

This to me seems like a very confusing and deep topic that I did not explore too much, but I can talk about the two
register types I saw in the crate and the two strategies I considered using.

#### Last-Write Wins Register (LWWReg)

The "convenience" of this register type is that it always contains just one value. Concurrent writes are merged
using a total ordering marker we define. I suppose you have some freedom in designing this marker but the idea I had
was to use a tuple of our map's vector clock[^1] combined with our actor id. The vector clock guarantees partial
ordering and we can get total ordering by resolving tied/incomparable states with the lexicographic order of the
actor id.

#### Multi-Value Register (MVREG)

Instead of immediately resolving conflicts, this register instead maintains a collection of values when their clocks
are incomparable, which means we still (might) need to resolve them ourselves. In my case at least, obviously I
don't want a grocery item to map to multiple boolean values, that would make no sense. Instead I decided to apply what
_I think_ is called an Enable-Wins semantic; if any of the values is true: keep the true, else remain false.

My reasoning behind this is that I want to prevent different peers buying the same item accidentally. If a concurrent
write occurs where someone marks an item as bought and someone else as not with this strategy, the bought dominates
so we avoid buying it multiple times. In contrast, LWWReg _could_ make the false dominate in this case if the Actor's
id was lexicographically bigger.

### A Bit of Code

Thankfully there's a great Rust crate that does _a lot_ of the heavy lifting: [`crdts`]. Let's see how we can create
one of the simplest CRDTs; a Multi-Value Register.

```rust, linenos, hl_lines=12 13 15
// Think of this as some sort of peer id
type Actor = String;

// Create a new MVReg that stores i32s
let mut reg = crdts::MVReg::<i32, Actor>::new();

// Get add_context (this increments our add_clock)
let ctx: crdts::ctx::AddCtx<Actor> = reg.read_ctx()
    .derive_add_ctx("actor 1".to_owned());

// Produce apply op
let op = reg.write(42, ctx);
reg.apply(op);

assert_eq!(reg.read().val[0], 42);
```

One thing to be mindful of is that `.write` doesn't actually mutate `reg` (as evident by the fact that it takes
`&self`), you need to `.apply` the op separately. The returned op type is very convenient for our case since we'll
want to both apply but also broadcast ops to peers.

As we build more complex CRDT structures, we need keep in mind that all nested fields in our struct must also
be CRDTs themselves! Thankfully this is enforced statically through the type system in the `crdts` crate.

This is what my final types looked like:

```rs
pub type Actor = iroh::PublicKey;
pub type Grocery = crdts::MVReg<bool, Actor>;
pub type Groceries = crdts::Map<String, Grocery, Actor>;
pub type Clock = crdts::VClock<Actor>;
```

> The `PublicKey` is not too important right now, just know that it is essentially a peer-unique String.

### Recap

This section was quite lengthy so let's very briefly recap some key points before we move on to networking:

- CRDTs rely on an oplog comprised of serializable operations
- fancy logical clocks are used to establish a causal partial order
- the way to establish a total order depends on your domain

## Networking

For networking, we'll be using [Iroh] which, in their own words, "_handles the hole-punching, NAT traversal, and relay
fallback needed to open a direct, authenticated QUIC connection between any two nodes._", it also does a bunch of
other stuff in a very neat, modular way, go check their [docs] if you're building anything peer-to-peer.

We're going to be using [Gossip] ([gossip iroh docs]) so we won't need a central message broker. The big issue with
the unreliable nature of our environment (changing network conditions, peers going temporarily offline etc) means that
we'll need mechanisms for bringing peers up to speed with our current state (this is also why we are using CRDTs!).

### Message Types

I'll skip over some implementation specific details and give a rough overview of our message types instead. We'll go
over the responce logic to each message type in the next section.

Let's start with the simplest message; earlier I explained how our CRDT produces `Op`s, obviously whenever a peer
performs an operation, we need to broadcast it to everyone else so they can apply it to their own state as well.
The message for that looks like this.

```rs
pub enum CoreMessage {
  Op(map::Op<String, Grocery, Actor>),
  // ...
}
```

What happens when a peer misses an Op broadcast though? That's what our logical clocks are for! We can periodically
broadcast a "heartbeat" containing our clock information to all other peers. Then those peers can compare the clocks
to their own and reply to us with any Ops we might be missing! In practice I broadcast a heartbeat every 5 seconds.

That "reply with the ops we are missing" is called an anti-entropy response but even though it sounds real fancy, it
is just a list of ops:

```rs
pub enum CoreMessage {
  Heartbeat {
    add_clock: Clock,
    rm_clock: Clock,
  },
  AntiEntropyResponse {
    ops: Vec<map::Op<String, Grocery, Actor>>,
  },
  // ...
}
```

#### Anti Entropy Responses Can Get Huge Quickly..

Here's the thing, since we _could_ have a bunch of peers on the same network exchanging messages, we need to keep an
eye on our message sizes in order to avoid network congestion, and this Op list can grow quickly.

Iroh does have a [default max message size] which obviously you can change but I wanted to keep it around and figure
out how I can keep my messages below that. 

The first an easiest thing we can do to lower `AntiEntropyResponse` is to make sure we are only sending Ops that
the peer is missing. To do that, we have to go through our local oplog and filter out any ops with clocks strictly
smaller than our peer's, that way we know the ones we're left with are going to be new to them.

> In my code, I just used a `Vec` to store the oplog but in a real, long lived system you might want to use a
> fixed length circular buffer to make sure you won't randomly run out of memory!

Another easy thing we can do is to just compress all our messages before sending them. If you are in a very dense
network, with very weak devices that are broadcasting very frequently, you might consider the cost of decoding to be
too significant. In my case, I doubt a phone's processor will have issues decoding a 4kb gzip payload every few
seconds! It is easy to forget how good gzip can be, when testing it would often bring a message the size of a few
thousand bytes to just a few hundreds. If you are not in a very compute-limited environment, this sounds like a great
idea to me.

But that is not very interesting. What is slightly cooler is realizing that it's the _list_ of Ops specifically that 
can grow very large, _not_ the state itself. In other words, there comes a point[^2] where sending over the state
will produce a smaller message than the Anti Entropy Response. That's what `SnapshotResponse` is for:

```rs
#[derive(Debug, Serialize, Deserialize)]
pub enum CoreMessage {
  SnapshotResponse {
    state: Groceries,
  },
  // ...
}
```

A compressed gzip response would probably work most of the time but just to be safe I added another fallback to
[`iroh-blob`]s which sends the data over in chunks. This way even if a compressed SnapShotResponse ends up being
over the limit, we can still send it over and maintain parity.


```rs
#[derive(Debug, Serialize, Deserialize)]
pub enum CoreMessage {
  Blob {
    ticket: BlobTicket,
  },
}
```

### Message Handling

I'll keep this section relatively high level to avoid getting hyper-specific but feel free to read the [code] if you
want. Most of what I will talk about in this section is inside one match statement.

+ `Op`: We add the op to our oplog (so we can later broadcast it to peers that need it) and apply it to our data.
+ `AntiEntropyResponse`: We iterate through the ops contained in the message and treat them like individual `Op`
   messages.
+ `SnapshotResponse`: We merge our state with the incoming state and clear our oplog (remember we received the full
   state, not the full oplog!). 
+ `Blob`: We let iroh download the blob into memory and we recursively call `handle_message` with its contents. In my
   codebase, I **only** put `SnapshotResponse`s in blobs, that way I know this recursive call will at most have a depth
   of one.
+ `Heartbeat`: I left this for last as its the lengthiest one. This is the "main" message that drives everything else,
   remember that we send heartbeats every 5 seconds. The heartbeats only contain the peer's clocks so we compare them
   with our own to find whether we have any missing ops.

   If we do have missing ops, we build an `AntiEntropyResponse`, if that's too big we fallback to a `SnapshotResponse`
   and if that's too big as well we send it as a blob.

   If we notice that the clock is behind but we can't find the missing ops (which can happen if we reset them
   earlier!), we send a `SnapshotResponse` with a blob fallback.

## Lessons Learned

By far the biggest issue I had was testing the CRDT to make sure it was working as expected. For the most part it did
work fine but I kept finding new bugs surrounding removals and their clocks. Because I hadn't anticipated this
(I assumed the `crdts` crate would be a bit more hands off than it was), I ended up coupling a lot of the iroh 
networking logic bits with the pure CRDT logic bits, meaning I needed an actual iroh connection to do any testing.
By the time this became mildly frustrating, I knew I wouldn't need much more time to iron issues out so I didn't
redesign the entire backend to facilitate testing _but_ this is definitely something I'll be paying more attention
to in the future.

I learned that I am in fact, still not a fan of building UIs, and that mobile app development sucks. I don't think
any of my issues are tauri specific, I think for the most part it is a pretty decent project (_although I did have
a few complaints in the execution order of some of their setup functions and their docs can be a bit lacking
sometimes_), but they are rather inherent to cross-platform development _combined_ with rust-js/wasm interop.
Obviously it's great that this is even possible but it is not without its inconveniences. Next time I want a UI, if I
can make a simple TUI and cover my needs, I'm doing that instead of anything else.

## Future Changes

While writing this post i had some time to reflect on the current networking design which, as I explained earlier,
was kind of an afterthought since I'm having issues with the BLE crate I was planning on using. In hindsight, I think
that even though automatic discovery is cool, for this project specifically exchanging [`EndpointId`]s would work
better. This would work even better than Bluetooth (assuming a stable WiFi connection in the supermarket) as it
wouldn't be bound by things like distance.

The idea as of now
is to generate and persist a secret key on each peer, that way we can re-use the same `EndpointId` across different
runs[^3]. These IDs are serializable and meant to be shared, it would probably be convenient to do so via a QR Code.
Maybe we could add an optional `nickname` field and share that along with its corresponding ID so that we can then
display a list of the peers and their IDs in the mobile app (in case you later decide you want to remove some of
them). 

Annoyingly, even though this does not sound like a big backend change at all, it would need a bunch of frontend fluff
to be convenient to use so I'll see what corners I can cut hehe.

[Conflict-free Replicated Data Types]: https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type
[Bitchat]: https://github.com/permissionlesstech/bitchat
[Vector Clock]: https://en.wikipedia.org/wiki/Vector_clock
[code]: https://github.com/AntoniosBarotsis/groceries-bmesh
[mDNS]: https://en.wikipedia.org/wiki/Multicast_DNS
[`crdts`]: https://crates.io/crates/crdts
[clock drift]: https://en.wikipedia.org/wiki/Clock_drift
[`VClock`]: https://docs.rs/crdts/latest/crdts/vclock/struct.VClock.html
[`Dot`]: https://docs.rs/crdts/latest/crdts/dot/struct.Dot.html
[Gossip]: https://en.wikipedia.org/wiki/Gossip_protocol
[gossip iroh docs]: https://docs.iroh.computer/connecting/gossip
[Iroh]: https://docs.iroh.computer
[`EndpointId`]: https://docs.rs/iroh/latest/iroh/type.EndpointId.html
[Tickets]: https://docs.iroh.computer/concepts/tickets#tickets
[docs]: https://docs.iroh.computer
[default max message size]: https://docs.rs/iroh-gossip/latest/iroh_gossip/proto/constant.DEFAULT_MAX_MESSAGE_SIZE.html
[`iroh-blob`]: https://docs.iroh.computer/protocols/blobs

## Footnotes

[^1]: Technically speaking, we should probably _not_ use a [`VClock`] here but rather a [`Dot`]. Dots are just the
      actor-specific entry in the clock (so with a clock of `{A:1,B:1}`, `A`'s dot is `(A,1)`)
[^2]: I suppose this might differ from use case to use case but for example in my case, to further illustrate this
      point, imagine we have just one item in our map; if we decide to toggle its boolean value 500 times, the state
      will remain tiny (its still one KV pair) but the oplog will now have 500 entries in it.
[^3]: Iroh also has what they call [Tickets] which they use in a bunch of their examples, however, those are
      more suited for shorter lived connections where network topology doesn't change. Because I want to be
      able to connect my peers at home and at the supermarket for instance, only sharing EndpointIds instead
      probably works better.
