---
title: "Python with a bit of Rust"
description: "Creating and publishing a Python package written in Rust."
keywords: ["Deployment", "GitHub Actions", "CD", "Publish", "rust", "python", "package", "PyPI",
  "call", "wheel"]
date: 2023-02-25T02:12:37+01:00
draft: false
taxonomies:
  tags: ["Rust", "Python", "Coding", "Deployment"]
---

## Introduction

I was always fascinated by the idea of different languages working together in a single codebase
for whatever reason. Rust seems to be especially good at this with
[its great C FFI](https://doc.rust-lang.org/nomicon/ffi.html) (with projects such as
[`cbindgen`](https://github.com/eqrion/cbindgen)) and [WASM](https://www.rust-lang.org/what/wasm)
support.

Considering how popular Python is, it should come as no surprise that there are tools available
that allow you to interface to and from Python, allowing you to leverage two very neat ecosystems.

Recently, a friend of mine (again) started playing around with some map data which happened to be
stored in the [ASCII Grid format](https://modis.ornl.gov/documentation/ascii_grid_format.html)
which is used often in
[GIS software](https://en.wikipedia.org/wiki/Geographic_information_system_software). Turns out,
this format is pretty easy to parse (even for someone who is very bad at parsing stuff like me) so
I wanted to see how hard it would be to make a Python package that used something like
[nom](https://github.com/rust-bakery/nom) to parse the files. I won't be going over the specifics
of my parser implementation as the blog post is focused on packaging Rust code and calling it from
Python, not parsing. Plus, I'm pretty confident that all my code *is* terrible that you are probably
better off without it :)

## The Plan

When I started looking into this, I wanted to at least answer the following questions:

- How is the developer experience of writing the Rust package as well as calling it
  and how *different* is it from the way you write code in the respective language
- How easy is developing such a project from the perspective of a developer 
  (testability, running tests, REPLs etc)
- How easy is it for someone who does not know Rust to use your package
- What could a deployment pipeline look like

## Creating the Library

### The Rust Part

We first start by creating the library create which is just plain old Rust, nothing weird here.

In my case, all of my parser's logic is summed up in a `parse` method that is defined as follows:

```rust
pub fn parse(input: &str) -> IResult<&str, AsciiGrid> {
  ...
}
```

> Notice the `IResult` type here? This is a 
> [type definition from the `Nom` crate](https://docs.rs/nom/latest/nom/type.IResult.html) which
> as, I mentioned above, I use for parsing. There is nothing special about it in this context and
> a normal `Result` or any other type would've worked just fine.

The `AsciiGrid` struct is also just plain Rust, for now, looks like this:

```rust
#[derive(Debug, Clone)]
pub struct AsciiGrid {
  pub header: Header,
  pub data: Vec<Vec<f64>>,
}
```

So how *do* we call this from Python? Enter [`PyO3`](https://github.com/PyO3/pyo3) which provides
"Rust bindings for the Python interpreter" and allows us to do just that!

Let's add `PyO3` to our `Cargo.toml` file

```toml
[lib]
name = "ascii_grid_parser"
path = "src/lib.rs"
crate-type = ["cdylib"]

[dependencies]
pyo3 = { version = "0.18.1", features = [ "extension-module" ] }
```

Notice 3 things here

The `name` is actually the name of the *Python* module we will specify later. This does not
necessarily need to be the same as your crate name. This is what you'll use in your Python code
imports when we eventually call our code from Python (`import ascii_grid_parser`).

The `crate-type` is for specifying that *"a dynamic system library will be
produced. This is used when compiling a dynamic library to be loaded from another language."*
[[source]](https://doc.rust-lang.org/reference/linkage.html).

> Fun fact, if you ever try to import your code from another Rust module (say, a benchmark for
> instance), it won't be discoverable because you need to *also* compile it as a Rust library. You
> can get that to work by adding 
>
> ```toml
> crate-type = ["cdylib", "rlib"]
> ```
>
> instead!

We are also including the `extension-module` feature, this is for telling `PyO3` that we are
building [Python extension modules](https://docs.python.org/3/extending/extending.html) which are
what allows us to interact with Python through `C`. 
[[source]](https://pyo3.rs/v0.18.1/building_and_distribution#linking)

Now we need to tell `PyO3` what we want to be able to use in Python, that includes both our `parse`
function and the `AsciiGrid` struct. This is perhaps unsurprisingly easy to do with the power of
Rust's macros;

```rust
use pyo3::prelude::*;

#[pyclass]
#[derive(Debug, Clone)]
pub struct AsciiGrid {
  #[pyo3(get, set)]
  pub header: Header,
  #[pyo3(get, set)]
  pub data: Vec<Vec<f64>>,
}

#[pyfunction]
pub fn parse(input: &str) -> PyResult<AsciiGrid> {
  ...
}
```

These are pretty self-explanatory. The 
[`PyResult`](https://docs.rs/pyo3/latest/pyo3/type.PyResult.html) type "represents the result of a
Python call." and is basically what we need to wrap any return value in to make it work with
Python. 

"What about error handling?" I hear you ask. Well, you can use the
[`PyValueError`](https://docs.rs/pyo3/latest/pyo3/exceptions/struct.PyValueError.html) struct that
represents Python's [`ValueError`](https://docs.python.org/3/library/exceptions.html#ValueError)
exception. To be quite honest with you, I don't really use Python so I am not too aware of what
people use for their errors and what common practices are there. I've seen `ValueErrors`s a few
times and I just chose to use that in my scenario, if something else makes more sense for your
given use case, you should probably go with that instead.

Finally, we need to register both our function and struct to a Python module which is just as simple

```rust
#[pymodule]
pub fn ascii_grid_parser(_py: Python<'_>, m: &PyModule) -> PyResult<()> {
  m.add_class::<AsciiGrid>()?;
  m.add_class::<Header>()?; // Header is a struct inside of AsciiGrid
  m.add_function(wrap_pyfunction!(parse_ascii_grid, m)?)?;

  Ok(())
}
```

And that's all you need from Rust's side!

It is worth noting that if you add normal Rust comments to a `pymodule`, `pyclass` or `pyfunction`,
they will be visible from the resulting Python package!

You can also add a `pyproject.toml` file for some more configuration options, here's a sample of
what that might look like 
(see [here](https://pyo3.rs/v0.18.1/getting_started.html?highlight=pyproject#pyprojecttoml)):

```toml
[build-system]
requires = ["maturin>=0.14,<0.15"]
build-backend = "maturin"

[project]
name = "ascii-grid-parser-rs"
requires-python = ">=3.7"
classifiers = [
    "Programming Language :: Rust",
    "Programming Language :: Python :: Implementation :: CPython",
    "Programming Language :: Python :: Implementation :: PyPy",
]
```

#### Some Thoughts on the Code I Literally Just Showed You

The code I showed above is not *exactly* what I ended up with and for anything bigger than a
100-line afternoon hack-it-together project, I'd recommend the following.

1. Decouple the `PyO3` stuff from your business logic. In the snippet above I changed the `parse`
   function (which is pure business logic) and polluted it with `PyO3` types and macros. It would
   instead be more convenient to separate the two in your code. What I *actually* ended up with
   is this:

   ```rust
   #[pyfunction]
   pub fn parse_ascii_grid(input: &str) -> PyResult<AsciiGrid> {
     let (_, res) = parse(input)
       .map_err(|_e| PyValueError::new_err("oops"))?;

     Ok(res)
   }

   fn parse(input: &str) -> IResult<&str, AsciiGrid> {
     // Parse `input`
     Ok(...)
   }
   ```

   As you can see, I kept `parse` the same as the original implementation I showed first and created
   a separate `parse_ascii_grid` that calls it which will be the only one exposed to Python.

   My reasoning for this is that it is simply easier to have pure, plain old Rust in as many places
   as you can to make your code easier to use and play around with **in the Rust project itself**.
   The only part of your code where you should care about Python compatibility is the very top.

2. Similarly to this and perhaps even more importantly, you probably should do the same with your
   structs. I say *probably* because *I didn't care enough to make that change for my small project
   that I worked on for the fun of it and no one, including me, will ever touch it again*. If you
   **do** care however then you should definitely think twice about this. You need to keep in mind
   that applying all those macros in the same struct that you use internally might have performance
   implications. I do not know exactly what these macros do or if this is even a problem that *can*
   happen but in any case, you should research into it before adding it to your codebase. If you
   are reading this and know that this is/is not the case indeed then let me know in the comments :)

As always, please do read the [docs](https://pyo3.rs/v0.18.1/getting_started).

### The Python Part

Let's go over how we can build the code we just worked on and call it from Python.

The `PyO3` [docs](https://pyo3.rs/v0.18.1/getting_started#python) recommend that you use a
virtual environment (to be honest, you should always do this), see more
[here](https://docs.python.org/3/library/venv.html).

After creating a virtual environment and activating it, we install
[`maturin`](https://github.com/PyO3/maturin) which is a tool (from the same org) that allows us to
easily build (and later publish) our crate as a Python package.

```sh
pip install maturin --user
```

For local development, you can run `maturin develop` which will build the package and add it to
your virtual environment. You can then open a Python shell (or run a file) and use the code!

```py
$ python
>>> import ascii_grid_parser
>>> ascii_grid_parser.parse_ascii_grid(...)
...
```

Building a [wheel](https://peps.python.org/pep-0427/) for your native platform is straightforward
(as you probably noticed from the `develop` command above), you can run the following:

```sh
maturin build -r --interpreter .env/Scripts/python.exe
```

You will likely need to specify the interpreter as I did above which can just be the executable in
your virtual environment's folder. In my case, I am using Windows, hence the `.exe`.

If you want to compile for multiple architectures, however, things get more complicated and I once
again must recommend you read the [docs](https://pyo3.rs/v0.18.1/building_and_distribution).

Even though Rust effortlessly compiles to any architecture you can think of, your Python interpreter
is built specifically for the platform that you are using which is a problem. In theory, you
*should* be able to get this to work but I did not try as I could already see how many hours I would
waste on this. Instead, seeing as how I am quite familiar with GitHub Actions by now, I opted to
do all the building there instead.

### Deploying Through GitHub Actions

> Note: I later simplified the workflow and made it spawn way less jobs and its overall much less
> messy thanks to some feedback I got on twitter. I'll leave the old version as well and I'll
> mention the cleanup in the next section.

I like using `on_workflow` triggers for any sort of release I do using GitHub actions. Some people
like pushing tags or commits with special messages but I always found that a bit messy.

This is what we start with 

```yml
name: CD

on:
  workflow_dispatch:
```

Since I was just experimenting, I decided to "*support*" a bunch of platforms such as

- macos (x86_64)
- Windows (x64, x86)
- linux (x86_64, x64, aarch64, armv7)

In my opinion, you should start with the absolute minimum of targets that you know you **must**
support and add more later if needed. The workflow dispatch trigger allows you to run a workflow
on any branch or tag which means that if you ever need to run it on an older version of the code
to add extra target compatibility, you can.

This is what my Windows job looks like

```yml

  Windows:
    runs-on: Windows-2022
    strategy:
      matrix:
        python-version: [ '3.7', '3.8', '3.9', '3.10', '3.11' ]
        target: [ x64, x86 ]

    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
          architecture: ${{ matrix.target }}

      - uses: dtolnay/rust-toolchain@nightly

      - name: Build wheels
        uses: PyO3/maturin-action@v1
        with:
          target: ${{ matrix.target }}
          args: --release --out dist --interpreter ${{ matrix.python-version }}

      - name: Upload wheels
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist
```

I compile a wheel for both `x64` and `x86` for versions `3.7` to `3.11`. I am using an existing
action to do the building instead of managing that myself since it exists but you could just as
easily replace that (although you'd have to manually set up `maturin` and what not).

In the end, I upload the generated wheels as
[artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)
which I use later.

The Linux job is mostly the same

```yml
  linux:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [ '3.7', '3.8', '3.9', '3.10', '3.11' ]
        target: [ x86_64, x64, aarch64, armv7 ]

    steps:
    - uses: actions/checkout@v3

    - uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
        architecture: x64

    - name: Build wheels
      uses: PyO3/maturin-action@v1
      with:
        target: ${{ matrix.target }}
        manylinux: auto
        args: --release --out dist --interpreter ${{ matrix.python-version }}

    - name: Upload wheels
      uses: actions/upload-artifact@v3
      with:
        name: dist
        path: dist
```

The [`manylinux`](https://peps.python.org/pep-0600/) parameter is interesting as that allows your
resulting binary to be valid in *most* Linux distributions, saving you from the whole lot of pain
you'd have to go through if you needed to create 1 job per distribution.

You might have noticed that I hardcoded `architecture` to `x64` unlike before. It seems that Python
only understands `x64` and `x86` as you can see
[here](https://raw.githubusercontent.com/actions/python-versions/main/versions-manifest.json) as
`architecture` values. I do admit that I am not sure if this then properly works in `x86`
environments and I can't really test it myself. This is definitely something to watch out for if
you are doing this yourself. The workflow passes with no errors or warnings *but then again, this
is Python we are talking about, not Rust, this does not guarantee that anything will work properly*.
Fixing this would be easy as you could add a check to see if your current `${{ matrix.target }}` is
`x64` and if not, set the arch to `x86`.

Macs were... interesting.

Turns out GitHub 
[is a bit limiting](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration#usage-limits)
when it comes to Mac runners as you can only run 5 at a time. *For some reason, I could only run 4
but that is besides the point*. Every matrix entry spawns a separate runner which is an issue
here. I instead removed the matrix and put everything on one runner.

```yml
  macos:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: '3.7 - 3.11'
          architecture: x64

      - uses: dtolnay/rust-toolchain@nightly

      - name: Build wheels - 3.7
        uses: PyO3/maturin-action@v1
        with:
          target: x86_64
          args: --release --out dist --interpreter 3.7

      #  ...

      - name: Build wheels - 3.11
        uses: PyO3/maturin-action@v1
        with:
          target: x86_64
          args: --release --out dist --interpreter 3.11

      - name: Upload wheels
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist
```

This is ugly but oh well. There is also a limit for 20 runners total (40 for pro) so you might want
to keep this idea around if you are compiling to *a lot* of targets.

Now to actually upload the artifacts:

```yml
  release:
    name: Release
    runs-on: ubuntu-latest
    needs:
      - macos
      - windows
      - linux

    steps:
      - uses: actions/download-artifact@v3
        with:
          name: dist
          path: dist

      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1
        with:
          user: AntoniosBarotsis
          password: ${{ secrets.PYPI }}
```

Not sure if the `user` is required but there it is. Even though this looks very messy, it only
takes about 5 minutes for everything to finish running in my case. Of course, this very much
depends on how complicated your crate is. You need to define a `PYPI` repository secret and set
its value to an API token from [PyPi](https://pypi.org/) for this to work of course.

Again, I feel like there are a lot of improvements you could make in this but it all greatly depends
on your specific use case. You might want to for instance not spawn as many runners, you might want
to spawn a set amount of Mac runners to distribute the work (say one builds `3.7-3.9` while another
builds the rest) etc etc. That said, I do think that this is a more than decent starting point
though.

> The version of the Python package will be automatically set to the version you mention in your
> `Cargo.toml`, atlhough *weird* version names (i.e. not just `X.Y.Z`) might change a bit.
> In my case, my `Cargo.toml` version was set to `0.0.1-alpha.4` but `PyPi`'s was `0.0.1a4`.

#### Cleaning Up the Workflow

Thanks to [@messense](https://twitter.com/messense) for his reply :)

{{ tweet(url="https://twitter.com/messense/status/1630811663103586304") }}

Turns out we can indeed specify multiple interpreters instead of spawning one task per version.
This, in my case, makes the workflow a bit slower which is to be expected since less work is
parallelized. It still only took about 2 minutes extra however and for most people, spawning
that many jobs is much bigger of a bottleneck than waiting an additional few minutes.

We can make the following changes (both windows and Linux are essentially the same again):

```yml
  windows:
    runs-on: windows-2022
    strategy:
      matrix:
        target: [ x64, x86 ]

    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: '3.7 - 3.11'                                   # <---
          architecture: ${{ matrix.target }}

      - uses: dtolnay/rust-toolchain@nightly

      - name: Build wheels
        uses: PyO3/maturin-action@v1
        with:
          target: ${{ matrix.target }}
          args: --release --out dist --interpreter 3.7 3.8 3.9 3.10 3.11 # <---

      - name: Upload wheels
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist
```

and for Mac we can remove the matrix all together and shorten it significantly:

```yml
  macos:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: '3.7 - 3.11'                                    # <---
          architecture: x64

      - uses: dtolnay/rust-toolchain@nightly

      - name: Build wheels - x86_64
        uses: PyO3/maturin-action@v1
        with:
          target: x86_64
          args: --release --out dist --interpreter 3.7 3.8 3.9 3.10 3.11  # <---

      - name: Upload wheels
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist
```

## What Did We Learn?

Let's revisit the questions we asked at the beginning of all of this.

- `How is the developer experience of writing the Rust package as well as calling it
  and how *different* is it from the way you write code in the respective language`

  This was spot on. From Python's point of view, this is just another ordinary package while from
  Rust's perspective, not much change or new stuff is required, especially if you limit the scope
  of the `PyO3` stuff as I mentioned earlier.
- `How easy is developing such a project from the perspective of a developer 
  (testability, running tests, REPLs etc)`

  Once again, spot on since it is very closely related to the first point. The Rust devs will need
  to have a Python interpreter available whilst the Python devs can just import the wheels which is
  great!
- `How easy is it for someone who does not know Rust to use your package`

  Again, very much related to the 2 points above, no one will even know your package is written in
  Rust (unless of course the words "*written in Rust*" have somehow not made it to your repository's
  README and description ;) )
- `What could a deployment pipeline look like`

  While I definitely don't *really* like how repetitive it turned out, the problem is ultimately
  Python itself and not the tools we used in this project. It is good enough and definitely not too
  slow, that's what you want for the most part.

Overall, slightly surprised by how easy this was 😅.

## Conclusion

I would say that this is definitely a realistic path to consider if you either want to optimize a
specific part of your codebase or to, as I did here, leverage Rust's ecosystem in your Python
project. 

There's a good chance that you will get a "free" performance boost by writing parts of your code
in Rust, assuming of course your code is sound. In my case, I parsed through my data
5.3 times faster (42s vs 8.8s) with the Rust implementation compared to a reference Python parser I
stole [from a blog post](https://scipython.com/blog/processing-uk-ordnance-survey-terrain-data/).

In fact, I managed to get it down to only 4.1s (11.7 times faster!) by applying the following to my
`Cargo.toml`:

```toml
[profile.release]
lto = true
codegen-units = 1
```

Of course, both definitely have massive room for optimization so this isn't necessarily a fair
comparison. In my case, I parsed over 2858 files that total at around 160mb so there is a lot of
IO happening which you usually should avoid but what do I know, I didn't benchmark anything :)

(please benchmark your code before and after you "*optimize*" it)

Of course, if you are doing this for fun like me, go ahead!

Till next time!

