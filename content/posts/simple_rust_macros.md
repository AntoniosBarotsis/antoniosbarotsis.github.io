---
title: "Simple Rust Function Macros"
description: "Sometimes, repeating yourself is not that bad, as long as macros do it for you."
tags: ["Coding", "Rust"]
keywords: ["Rust", "macro"]
date: 2023-07-17T00:42:43+02:00
draft: false
---

## Introduction

Rust's macros are quite powerful, whether you use them to avoid boilerplate code, make a crate's
interface easier to work with or even define entire domain-specific, type-checked languages.
One of the main issues with macros is how hard it is to get started *making* them. If you've ever
seen a macro definition in the wild, you know how weird and cryptic they can get, especially
procedural macros.

As a result, many (likely most) beginners simply stay away from them (or well, at least I did). 
It is however worth remembering that non-procedural macros are not that bad and considering how
useful they can be when used correctly, so much so that I would argue that it's a good idea for
everyone to know a little bit about them.

> A little heads-up, I generally like turning my posts into little stories instead of just focusing
> on the main topic in isolation as I think it is useful (and interesting) to talk about how we got
> there, why we needed and what alternatives were tried beforehand. In this case, that background
> context was quite a bit so if you are not interested in that, feel free to skip to 
> [here](#actually-making-the-thing) :)

## Setting the Stage

Recently, I worked on [a simple Mandelbrot renderer](https://github.com/AntoniosBarotsis/mandelbrot)
(that README has a pretty cool video included 👌, I think you should check that out if you're
reading this). I found fractals really intriguing for a while so I was bound to make something
like this at some point. The main reason why I ended up building it now was an interest in
seeing how [SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data) instructions work
in Rust.

> Long story short, SIMD instructions allow you to perform the same operation on multiple data
> elements simultaneously by vectorizing your data, hence the name, 
> **S**ingle **I**nstruction **M**ultiple **D**ata

I decided to use Rust's [`packed_simd`](https://github.com/rust-lang/packed_simd), Nightly only
crate to achieve this. That crate supports a wide variety of different register sizes, in my case
I was interested in [`f64x2`](https://docs.rs/packed_simd/0.3.8/packed_simd/type.f64x2.html) and
[`f64x8`](https://docs.rs/packed_simd/0.3.8/packed_simd/type.f64x8.html) which pack 2 and 8 64-bit
floating point numbers into a single register respectively.

I had already written non-SIMD code so I just had to start reworking it to emit SIMD instructions.

I started working towards making `f64x2` work and I eventually arrived at the following code:

```rust
fn map_simd(
  point: Simd<[f64; 2]>,
  old_top: f64,
  old_bottom: f64,
  new_top: f64,
  new_bottom: f64,
) -> Simd<[f64; 2]> {
  let tmp_1 = f64x2::splat(new_top - new_bottom);
  let tmp_2 = f64x2::splat(new_bottom);
  ((point - old_bottom) / (old_top - old_bottom)).mul_add(tmp_1, tmp_2)
}
```

For the purposes of this post, we only care about the following:

- `Simd<[f64; 2]>`
- `f64x2`

Somewhat interestingly enough, if we head over to
[the docs](https://docs.rs/packed_simd/0.3.8/packed_simd/type.f64x2.html), we'll see that the latter
is just an alias for the former:

```rust
pub type f64x2 = Simd<[f64; 2]>;
```

Of course, this is only for `f64x2`s and I just mentioned I also wanted to have `f64x8`s, this sounds
***extremely*** repetitive!!!

Seems like something we could solve using generics!

> As a side note, this was done for the educational purposes of both myself and whoever is reads 
> this post, please do not create unnecessary abstractions in your code (especially as
> convoluted as a macro) when the alternative is writing another 3 lines of code! 

## Trying to Generify Our Function

This didn't feel that hard so I immediately tried *generifying* the `map` method.

I started off with this:

```rust
fn map_simd<N>(
  point: Simd<[f64; N]>,
  old_top: f64,
  old_bottom: f64,
  new_top: f64,
  new_bottom: f64,
) -> Simd<[f64; N]> {
  todo!()
}
```

Looks about what you'd expect right? We want to essentially generify over 2 possible values of `N`,
namely 2 and 8 so let's make that a generic then! Well, the compiler does not like that:

```
error[E0423]: expected value, found type parameter `N`
   --> src\implementations\simd.rs:156:9
    |
148 | fn map_simd<N>(
    |        - found this type parameter
...
156 |   [f64; N]: SimdArray
    |         ^ not a value
```

The same `not a value` error occurs in all usages of `N`, so what is going on?

Peeking into the [`Simd` type docs](https://docs.rs/packed_simd/0.3.8/packed_simd/struct.Simd.html)
we see that it uses this
[`SimdArray` trait](https://docs.rs/packed_simd/0.3.8/packed_simd/trait.SimdArray.html) which
apparently takes in a `const N usize`. Maybe all we have to do is just mimic that and then it will
just work then (?)

```rust
fn map_simd<const N: usize>(
  point: Simd<[f64; N]>,
  old_top: f64,
  old_bottom: f64,
  new_top: f64,
  new_bottom: f64,
) -> Simd<[f64; N]> {
  todo!()
}
```

But this still fails to compile:

```
error[E0277]: the trait bound `[f64; N]: SimdArray` is not satisfied
   --> src\implementations\simd.rs:149:10
    |
149 |   point: Simd<[f64; N]>,
    |          ^^^^^^^^^^^^^^ the trait `SimdArray` is not implemented for `[f64; N]`
    |
    = help: the following other types implement trait `SimdArray`:
              [isize; 2]
              [isize; 4]
              [isize; 8]
              [i8; 2]
              [i8; 4]
              [i8; 8]
              [i8; 16]
              [i8; 32]
            and 81 others
note: required by a bound in `packed_simd::Simd`
   --> C:\Users\anton\.cargo\registry\src\index.crates.io-6f17d22bba15001f
        \packed_simd-0.3.8\src\lib.rs:288:20
    |
288 | pub struct Simd<A: sealed::SimdArray>(
    |                    ^^^^^^^^^^^^^^^^^ required by this bound in `Simd`
```

Well we are now getting a different error so there's that I guess. If we *actually* read the error,
we'll see that `SimdArray is not implemented for [f64; N]`. This is essentially enforcing that SIMD
arrays only have *some* select sizes that make sense. For example, `[f64; 2]` and `[f64; 8]` are
valid as they fit 2 and 8 `f64`s into `128` and `512` registers respectively but `[f64; 3]` for
example is not valid as there is no `192`-bit register.

We can easily add that as a where clause in our function definition however:

```rust
fn map_simd<const N: usize>(
  point: Simd<[f64; N]>,
  old_top: f64,
  old_bottom: f64,
  new_top: f64,
  new_bottom: f64,
) -> Simd<[f64; N]>
where
  [f64; N]: SimdArray {
  todo!()
}
```

Finally this builds and all our problems are gone! Now we just have to add back the actual code!
Of course we can't add that `f64x2::splat` stuff, we need to also make that generic. Well we did see
that `f64x2` was just an alias for `Simd<[f64; 2]>;` so we should be able to just use that!

```rust
fn map_simd<const N: usize>(
  point: Simd<[f64; N]>,
  old_top: f64,
  old_bottom: f64,
  new_top: f64,
  new_bottom: f64,
) -> Simd<[f64; N]>
where
  [f64; N]: SimdArray,
{
  let tmp_1 = Simd::<[f64; N]>::splat(new_top - new_bottom);
  let tmp_2 = Simd::<[f64; N]>::splat(new_bottom);
  ((point - old_bottom) / (old_top - old_bottom)).mul_add(tmp_1, tmp_2)
}
```

And we get an error again :(

```
error[E0599]: no function or associated item named `splat` found for struct 
              `packed_simd::Simd<[f64; N]>` in the current scope
   --> src\implementations\simd.rs:158:33
    |
158 |   let tmp_1 = Simd::<[f64; N]>::splat(new_top - new_bottom);
    |                                 ^^^^^ function or associated item not found in 
                                            `Simd<[f64; N]>`
    |
    = note: the function or associated item was found for
            - `packed_simd::Simd<[i8; 2]>`
            - `packed_simd::Simd<[u8; 2]>`
            - `packed_simd::Simd<[m8; 2]>`
            - `packed_simd::Simd<[i8; 4]>`
            and 81 more types
```

### Getting a Little Bit Off-Topic

At this point it started feeling like this might not be possible in Rust at least for the time
being... until I found [this](https://practice.rs/generics-traits/const-generics.html) post talking
about const generics which ignited some amount of hope in me.

The post essentially arrives at this handy trick:

```rust
pub enum IsTwoOrEight<const CHECK: usize> {}

pub trait IsTrue {}
impl IsTrue for IsTwoOrEight<2> {}
impl IsTrue for IsTwoOrEight<8> {}
```

This essentially allows us to express certain limitations that any data can have at compile time.
We could for example write something like this:

```rust
fn very_useful_method_1<const N: usize>() where IsTwoOrEight<N>: IsTrue, { }

fn naming_is_hard_txt() {
  very_useful_method_1::<2>();  
  very_useful_method_1::<3>(); 
}
```

And this crashes because `IsTwoOrEight` is obviously not implemented for `3`!

```
error[E0277]: the trait bound `IsTwoOrEight<3>: IsTrue` is not satisfied
   --> src\implementations\simd.rs:172:10
    |
172 |   very_useful_method_1::<3>();
    |          ^ the trait `IsTrue` is not implemented for `IsTwoOrEight<3>`
    |
    = help: the following other types implement trait `IsTrue`:
              IsTwoOrEight<2>
              IsTwoOrEight<8>
note: required by a bound in `very_useful_method_1`
   --> src\implementations\simd.rs:168:50
    |
168 | fn very_useful_method_1<const N: usize>() 
    |                     where IsTwoOrEight<N>: IsTrue, { }
    |                     ^^^^^^ required  by this bound in `very_useful_method_1`
```

I found this super cool for some reason and surely it would work if we added this to our previous
code! I mean after all, we *know* that that darn trait is implemented for `[f64; 2]` and `[f64; 8]`!

```rust
fn map_simd<const N: usize>(
  point: Simd<[f64; N]>,
  old_top: f64,
  old_bottom: f64,
  new_top: f64,
  new_bottom: f64,
) -> Simd<[f64; N]>
where
  [f64; N]: SimdArray, IsTwoOrEight<N>: IsTrue
{
  let tmp_1 = Simd::<[f64; N]>::splat(new_top - new_bottom);
  let tmp_2 = Simd::<[f64; N]>::splat(new_bottom);
  ((point - old_bottom) / (old_top - old_bottom)).mul_add(tmp_1, tmp_2)
}
```

Well darn

```
error[E0599]: no function or associated item named `splat` found for struct 
  `packed_simd::Simd<[f64; N]>` in the current scope
   --> src\implementations\simd.rs:158:33
    |
158 |   let tmp_1 = Simd::<[f64; N]>::splat(new_top - new_bottom);
    |                                 ^^^^^ function or associated item 
    |                                       not found in `Simd<[f64; N]>`
    |
    = note: the function or associated item was found for
            - `packed_simd::Simd<[i8; 2]>`
            - `packed_simd::Simd<[u8; 2]>`
            - `packed_simd::Simd<[m8; 2]>`
            - `packed_simd::Simd<[i8; 4]>`
            and 81 more types
```

What's annoying with this is that outright using `2` or `8` compiles with no issues!

```rust
fn map_simd<const N: usize>(
  point: Simd<[f64; N]>,
  old_top: f64,
  old_bottom: f64,
  new_top: f64,
  new_bottom: f64,
) -> Simd<[f64; N]>
where
  [f64; N]: SimdArray, IsTwoOrEight<N>: IsTrue
{
  let tmp_1 = Simd::<[f64; 2]>::splat(new_top - new_bottom);
  let tmp_2 = Simd::<[f64; 2]>::splat(new_bottom);
  todo!()
}
```

I believe we have made it to the limits of the Rust compiler here; even if *conceptually* this is
fine, the compiler is not convinced.

> It is worth noting here that if the crate itself had used some traits for this and made their
> implementation generic over them, what we are trying to do here would *probably*  maybe work!
> Or maybe there's another way of doing this that I am unware of, who knows.

## Here Come Macros! (Finally)

Now credit to where credit is due, if I hadn't watched [this](https://youtu.be/ModFC1bhobA) video
sometime during the 3 or so days I spent working on the project I would've probably not thought
of using macros at all so definitely go and give it a watch!

The one sentence Tantan said that stuck with me was *"Let's go ahead and copy our [...] code and
paste it into this macro"*. 

I know this probably seems like a very silly thing to find useful but it did kind of change how I
thought about macros. I often felt like because of how complex many of these macros get and because
of how heavily certain projects use them to the point where it feels like they barely have any
actual code, they surely must be pre-meditated.

Well, maybe. But they definitely don't *need* to be. The whole premature optimization/abstraction
surely applies to macros, you should first build a solution that does not use macros and then
only after careful consideration, should you consider adding them as 
[they are not all sunshine and rainbows](https://www.reddit.com/r/rust/comments/taxfe3/what_are_the_pros_and_cons_of_using_macros_in_rust/).

As someone on the above-linked Reddit thread elegantly put it;

> "*Pros: you can use macros to solve your problem*
>
> *Cons: you need to use macros"*

Ok enough talking, let's actually make the thing.

### Actually Making the Thing

As a reminder: we want a macro that can essentially produce the following 2 methods:

```rust
fn map_simd_f64x2(
  point: Simd<[f64; 2]>,
  old_top: f64,
  old_bottom: f64,
  new_top: f64,
  new_bottom: f64,
) -> Simd<[f64; 2]> {
  let tmp_1 = Simd::<[f64; 2]>::splat(new_top - new_bottom);
  let tmp_2 = Simd::<[f64; 2]>::splat(new_bottom);
  ((point - old_bottom) / (old_top - old_bottom)).mul_add(tmp_1, tmp_2)
}

fn map_simd_f64x8(
  point: Simd<[f64; 8]>,
  old_top: f64,
  old_bottom: f64,
  new_top: f64,
  new_bottom: f64,
) -> Simd<[f64; 8]> {
  let tmp_1 = Simd::<[f64; 8]>::splat(new_top - new_bottom);
  let tmp_2 = Simd::<[f64; 8]>::splat(new_bottom);
  ((point - old_bottom) / (old_top - old_bottom)).mul_add(tmp_1, tmp_2)
}
```

Let's start by just making one of them. I first created a file `simd_boilerplate.rs` which will
house the macro and then, well, *just copied my code over*

```rust
#[macro_export]
macro_rules! simd_boilerplate {
  () => {
    fn map_simd_f64x2(
      point: Simd<[f64; 2]>,
      old_top: f64,
      old_bottom: f64,
      new_top: f64,
      new_bottom: f64,
    ) -> Simd<[f64; 2]> {
      let tmp_1 = Simd::<[f64; 2]>::splat(new_top - new_bottom);
      let tmp_2 = Simd::<[f64; 2]>::splat(new_bottom);
      ((point - old_bottom) / (old_top - old_bottom)).mul_add(tmp_1, tmp_2)
    }
  }
}
```

Just as before, we need to somehow put all those `2`s behind a variable:

```rust
#[macro_export]
macro_rules! simd_boilerplate_ {
  ($N: literal) => {
    fn map_simd_f64x2(
      point: Simd<[f64; $N]>,
      old_top: f64,
      old_bottom: f64,
      new_top: f64,
      new_bottom: f64,
    ) -> Simd<[f64; $N]> {
      let tmp_1 = Simd::<[f64; $N]>::splat(new_top - new_bottom);
      let tmp_2 = Simd::<[f64; $N]>::splat(new_bottom);
      ((point - old_bottom) / (old_top - old_bottom)).mul_add(tmp_1, tmp_2)
    }
  }
}
```

This actually works fine! We just need to call `crate::simd_boilerplate!(2);` in the file where
we want the method to be dumped into and we can use it just like any other method!

We still have one final problem though. If we try and call our macro again with `8`, we'll get an
error since we will be essentially creating the same method `map_simd_f64x2` twice. There are a
few ways around this, the one I chose was to use the [paste](https://github.com/dtolnay/paste)
crate. 

Also, how come any time you find a neat crate that does exactly what you need it's always made by
that David Tolnay guy? Anyway.

The code for that looks pretty simple:

```rust
#[macro_export]
macro_rules! simd_boilerplate {
    ($N: literal) => {
      paste::item! {
        fn [< map_simd_f64x $N >](
          point: Simd<[f64; $N]>,
          old_top: f64,
          old_bottom: f64,
          new_top: f64,
          new_bottom: f64,
        ) -> Simd<[f64; $N]>
        where
          [f64; $N]: SimdArray
        {
          let tmp_1 = Simd::<[f64; $N]>::splat(new_top - new_bottom);
          let tmp_2 = Simd::<[f64; $N]>::splat(new_bottom);
          ((point - old_bottom) / (old_top - old_bottom)).mul_add(tmp_1, tmp_2)
        }
      }
    };
}
```

And we're done!

Calling `crate::simd_boilerplate!(2);` and `crate::simd_boilerplate!(8);` will create the
`map_simd_f64x2` and `map_simd_f64x8` methods we wanted respectively!

## Closing

What did we learn from all this? Well, I guess macros are kinda neat sometimes albeit not too useful
in this case, saving like 30 lines of code is not *that* amazing of a developer experience upgrade
is it? Well perhaps more importantly we figured out how to write those macros, and we also figured
out how to use const generics, what they can do and that cool little trick with the compile time
value checks! All that because I decided I wanted to use SIMD on a little project in my past time.

What I'm trying to say is that being curious and building stuff is the best way to learn new things
and we should all do that as much as we can.

Best case scenario, what you learn through this is useful to you sometime in the future, worst case,
it's just fun.

> Also please join [the Rust community Discord](https://discord.gg/rust-lang-community)! The people
> there are wonderful and without their help, I would've stopped trying before I even made it to
> const generics :)
>
> Didn't know where else to put this.

Till next time!
