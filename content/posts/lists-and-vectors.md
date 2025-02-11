---
title: "Linkedlists kinda ..suck?"
description: "Long live cache locality"
keywords: ["linked", "list", "linkedlist", "vec", "vector", "complexity"]
date: 2025-02-11T21:18:05+01:00
draft: false
taxonomies:
  tags: ["Rust", "Performance"]
---

## Introduction

Earlier today I watched Bjarne Stroustrup's "_why you should avoid linked lists_" (it seems that the
YouTube video went private for some reason unfortunately but there is 
[Prime's reaction]) and found it very interesting
so I decided to write some benchmarks and get some more concrete insights.

> On a side note, I'm afraid the plots will be kinda unreadable on mobile :/
> 
> You could try to `tap & hold > open in a new tab` but it will probably still be tiny.

## Background

The aforementioned talk went on to explain how, due to just how good caches have gotten nowadays,
data structure compactness and memory contigiousness is crucial to performance. So much so that
even time complexity ends up being a useless metric in some cases.

It is worth pointing out that time complexity is a measure of how well an algorithm *scales* rather
than how *fast* it is but we'll see that even that can be misrepresentative of the actual performance
of two algorithms.

## The Problem

We will focus on element deletions (additions would work the same way) at different points of the
linked list and vector data structures.

If you recall from your Algorithms & Data Structures class, deleting the `i`th element requires a
traversal up to `i-1` and then changing its pointer to point to `i+1` instead of `i`, effectively
deleting it. In contrast, because vectors use contigious memory, they need to be copied to a new
location in memory without the item that we want to delete.

If you had asked me which of the two would end up being faster, before today I would've answered
"*Well linked lists of course! I know memory is slow and copying an entire array sounds expensive!*".

As it turns out however, that tends to *not* be the case!

What ends up happening is that the cost of traversing the data structure to find the element we are
looking for completely overshadows the copying costs that arrays come with!

## Writing the boilerplate

We will start by creating a linked list and a vector.

In Rust we have the [`LinkedList`]
struct which is a doubly-linked list and [`Vec`]
which is a contiguous growable array.

I made a simple helper method for generating a `LinkedList` and a `Vec` of the same size:

```rs
// This needs nightly
#![feature(linked_list_remove)]

use std::collections::LinkedList;

pub fn generate(range: usize) -> (LinkedList<i32>, Vec<i32>) {
  let mut list = LinkedList::<i32>::new();
  let mut vec = Vec::<i32>::new();

  for i in 0..range {
    list.push_back(i as i32);
    vec.push(i as i32);
  }

  (list, vec)
}
```

Then I made just 2 methods, each for removing the `i`th element of the passed list/vec respectively:

```rs
pub fn remove_ith_list(mut list: LinkedList<i32>, i: usize) -> LinkedList<i32> {
  let _ = list.remove(i);
  list
}

pub fn remove_ith_vec(vec: Vec<i32>, i: usize) -> Vec<i32> {
  let mut left = vec[..i].to_owned();
  let mut right = vec[i + 1..].to_owned();
  left.append(&mut right);
  left
}
```

Rust's explicitness over things like cloning is one of the things I really like about it as it makes
spotting potentially costly operations really easy and it forces you to think about them. At least
when I contrast it to something like Java or Python which is what I've worked with mostly, I'm sure
C++ works much the same way as Rust (or any other lower level lang for that matter).

## Writing the benchmarks

For the benchmarks I will use [Criterion].

I want to benchmark the following scenarios for a few different list/vec sizes:
- removing the first element
- removing the middle element
- removing the element at `size/4`
- removing the element at `3*(size/4)`
- removing a random element

Intuitively, the earlier the element appears in the sequence, the faster Linked Lists should be as
they have to traverse fewer elements. But there is also the size of the data itself to consider as
behavior might change for small or very large inputs.

I decided to use

```rs
const SIZES: [usize; 3] = [100, 1_000, 10_000];
```

for the different data sizes. The full code is available [here] but I'll briefly go over
the random element benchmark code here. These are all largely the same.

```rs
pub fn criterion_benchmark_rand(c: &mut Criterion) {
  let mut group = c.benchmark_group("Remove random element");

  // Seed for reproducible results
  let mut rng = ChaCha8Rng::seed_from_u64(42);

  // Benchmark all different data sizes
  for size in SIZES {
    let _ = group.throughput(Throughput::Bytes(size as u64));

    // Generate data
    let (list, vec) = generate(size);

    // List benchmark
    let _ = group.bench_with_input(BenchmarkId::new("list", size), &size, |b, _range| {
      b.iter_batched(
        || list.clone(),
        |list| remove_ith_list(black_box(list), rng.random_range(0..size)),
        BatchSize::SmallInput,
      );
    });

    // Vec benchmark
    let _ = group.bench_with_input(BenchmarkId::new("vec", size), &size, |b, _range| {
      b.iter_batched(
        || vec.clone(),
        |vec| remove_ith_vec(black_box(vec), rng.random_range(0..size)),
        BatchSize::SmallInput,
      );
    });
  }

  group.finish();
}
```

If you've written ([Criterion]) benchmarks before, this should all be pretty self explanatory. Perhaps
the only thing to note here would be the `bench_with_input` method. I use that instead of just `bench`
because it takes 2 closures, one of which is *not* measured and is used to generate the test data
(`vec.clone()` in my case). Doing this makes it so we do not include the cost of cloning in our
measurements.

## The Results

Let's start by comparing the removal of the first element:

{{ image(src="/img/lists-vs-vectors/1st-lines.svg", class="dark-filter", style="max-width:160%;margin-left:-25%;margin-right:-35%") }}

As we can see, list does expectedly scale in constant time, while list appears more linear. Nothing
weird so far but it is all downhill for the linkedlist from here.

{{ image(src="/img/lists-vs-vectors/q1-lines.svg", class="dark-filter", style="max-width:160%;margin-left:-25%;margin-right:-35%") }}

We are only 1/4th of the way into the data and already vectors are outperforming lists. Going 
to the middle only exagerrates the issue further while remaining roughly the same for the vector;

{{ image(src="/img/lists-vs-vectors/middle-lines.svg", class="dark-filter", style="max-width:160%;margin-left:-25%;margin-right:-35%") }}

If we remove the 3/4th element, we see that performance becomes very comparable to the first plot again:

{{ image(src="/img/lists-vs-vectors/q3-lines.svg", class="dark-filter", style="max-width:160%;margin-left:-25%;margin-right:-35%") }}

This is because as I mentioned earlier, Rust's Linked List is doubly linked and the remove method
[checks to see which side it should iterate from]. Smart!

Finally (and perhaps the more useful) benchmark; removing random elements:

{{ image(src="/img/lists-vs-vectors/rand-lines.svg", class="dark-filter", style="max-width:160%;margin-left:-25%;margin-right:-35%") }}

We can see that they are a bit closer this time but still the vector does quite a bit better and they
would only diverge further for larger inputs. Depending on what you're doing, 10k elements might be
unreasonably small for in real life the difference could be much bigger.

This is also the only case where lists were actually faster for the smallest inputs although at that
point of course you hardly care about the difference, it is more interesting than useful.

Another thing to consider that is often critical is how predictable the performance is:

{{ image(src="/img/lists-vs-vectors/rand-violin.svg", class="dark-filter", style="max-width:160%;margin-left:-35%;margin-right:-25%") }} 

We can see that for the largest input, the vector's distribution is significantly tighter compared
to the list. This is to be expected; the performance of litsts depends on where exactly the element
is (slowest in the middle, fastest on either end) while vectors don't care.

As a final benchmark I decided to repeatedly randomly remove elements until half of them remain.

{{ image(src="/img/lists-vs-vectors/half-lines-10k.svg", class="dark-filter", style="max-width:160%;margin-left:-25%;margin-right:-35%") }}

Woah that is *very* close. I was not really expecting that. I am not entirely sure why that is but
I am guessing it has to do with the fact that the more elements we remove, the more favored lists
become since they have to iterate less and less. Still quite interesting! If we use 100k as an
input size as well however they diverge quite a bit:

{{ image(src="/img/lists-vs-vectors/half-lines.svg", class="dark-filter", style="max-width:160%;margin-left:-25%;margin-right:-35%") }}

Vectors are twice as fast at this point. Goes to show that depending on your use case, you might get
slightly different results. That said at no point in my tests were vectors slower and of course all
these tests are their weaknesses so I don't see when you would want to use linked lists over them.

{{ image(src="/img/lists-vs-vectors/half-violin.svg", class="dark-filter", style="max-width:160%;margin-left:-25%;margin-right:-35%") }}

Just as before, the distribution of the vector is a bit more packed than that of the list.

## Closing

This was for sure one way to spend one of my afternoons. 

As Mr Stroustrup said in his talk "*When I was taught about data structures, this [insertions/deletions]
is what you used lists for!*" same for me and I assume most other people. 

It was interesting to see how (at least nowadays) this seems to no longer be the case. I do wonder
if the benchmarks would be different on older hardware and just how far back we would need to go to
potentially reverse this trend.

This was a rather short post but oh well. I need to find more things to write about.

In any case, till next time!

[checks to see which side it should iterate from]: https://doc.rust-lang.org/src/alloc/collections/linked_list.rs.html#1014-1015
[Criterion]: https://docs.rs/criterion/latest/criterion/
[`LinkedList`]: https://doc.rust-lang.org/std/collections/struct.LinkedList.html
[`Vec`]: https://doc.rust-lang.org/std/vec/struct.Vec.html
[Prime's reaction]: https://youtu.be/cvZArAipOjo?si=xsGhEy1yLiMYEXw7
[here]: https://github.com/AntoniosBarotsis/linkedlist-vs-vec
