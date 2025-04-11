---
title: "Rss2Email"
description: "My introduction to Rust."
keywords: ["Rust", "Email", "SendGrid", "RSS", "AWS", "Lambda", "Benchmark", "Criterion", "Docker"]
date: 2022-10-07T18:47:04+02:00
draft: false
taxonomies:
  tags: ["Coding", "Rust"]
---

## Introduction

I picked up Rust about a month ago and have been loving it. I don't think I've learned as much
about a language in a single project as I did with [Rss2Email](https://github.com/AntoniosBarotsis/Rss2Email)
although that might just be because there is a *lot* to learn in Rust, especially as a beginner.

I somehow ended up presenting the project I am about to talk about in a
[Postman Livestream](https://www.youtube.com/watch?v=EBjmbyC-h0Y).

I (very) briefly go over what Rust is all about, why it's popular among devs and why you should try it out yourself
so I decided to not talk much about any of these in this post. I tried doing that once or twice already but
I ended up going criminally off-topic and talking about my opinions on the declining state of modern software
development more than my project so perhaps let's leave that for some other time 👍 

## What is it?

TLDR: I wanted a way to forward web feeds to my mailbox for blogs that do not have newsletters.

Quoting my own README;

> I have a few blogs in mind that I do find interesting but they do not provide a newsletter.
>
> There are some RSS readers but I am too lazy to download and use other software exclusively for this, I would much
> rather see a summary of these posts in my mailbox.

The core logic is very simple;

- Get a list of web feeds
- Parse those to a concrete, internal representation
- Send "new" posts via email

If you are already familiar with Rust basics then you can probably skip to [here](#downloading-the-web-feeds).

## Set Up Rust

You first want to install Rustup. You can find numerous installation methods
[here](https://forge.rust-lang.org/infra/other-installation-methods.html).

This is probably redundant but make sure you have the latest version of everything with

```sh
rustup update
```

Lastly, I'd recommend installing [Clippy](https://github.com/rust-lang/rust-clippy)

```sh
rustup component add clippy
```

I code in Visual Studio Code so the plugins I'll mention might not exist for say
Intellij but there most are alternatives that do essentially the same stuff.

- [Rust Analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)
- [Better TOML](https://marketplace.visualstudio.com/items?itemName=bungcip.better-toml)
- [Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)
- [Search Crates IO](https://marketplace.visualstudio.com/items?itemName=belfz.search-crates-io)

Only the first one is "needed" but I find the rest pretty useful so I thought I'd mention them.

### Linting

Before I get into the actual code I would like to mention that linting has taught me a generous amount
of the stuff I know currently about Rust and I cannot stress how much I recommend you make use of it as a beginner.

I doubt that more experienced Rustaceans would look at this without cringing but I do not care 😎

Feel free to paste the [following config](https://gist.github.com/AntoniosBarotsis/60060357589af501efdaf89e18dcc522)
to `.cargo/config.toml`.

You can run Clippy either with `cargo clippy` or preferably change your VSC setting

`Settings > rust-analyzer > Check on save: Command` to `clippy`. This in combination with the
Error Lens plugin should show you inline errors.

If you are completely new to Rust I would recommend going through at least some of
[The Book](https://doc.rust-lang.org/stable/book/) before resuming reading this article
as I'll be making a jump in pace from here on.

## High-Level Technical Overview

I'll list a few of the libraries used for various parts of the code to set the stage for the more in-depth
explanations that are to follow. I intend on referencing this post during my Postman talk and thus I want
to spell out many of the dependencies I used as they might not be obvious to beginners.

- A `GET` request is sent to each feed using [`ureq`](https://crates.io/crates/ureq)
- The feeds are parsed into structs using [`serde`](https://crates.io/crates/serde) (serialization crate)
- The core logic is mostly pure Rust but I do use [`regex`](https://crates.io/crates/regex), 
  [`chrono`](https://crates.io/crates/chrono) (DateTime), and [`itertools`](https://crates.io/crates/itertools) 
  (Extra iterator methods)
- The email part is just one HTTP request to a remote API

## Downloading the Web Feeds

### Getting our Links

Let's start with a slightly simplified version of the method I wrote;

```rust
/// Parses links from `feeds.txt`.
///
/// Assumed one link per line. Any text between a `#` and a line end
/// is considered a comment.
pub fn read_feeds() -> Vec<String> {
  let links = fs::read_to_string("feeds.txt")
    .expect("Error in reading the feeds.txt file");

  links
    .split('\n')
    .map(std::string::ToString::to_string)
    .map(|l| l.trim().to_owned())
    .filter(|l| !l.is_empty())
    .unique()
    .collect::<Vec<String>>()
}
```

Interestingly enough, this is might have changed slightly by the time you are reading
this article as detailed in [this](https://github.com/AntoniosBarotsis/Rss2Email/issues/7) issue.

In any case;

- I expect the user to have a `feeds.txt` file with all his links. That file:
    - Should have one link per line
    - Can have comments that start with `#` (more on this in a bit)
- I make sure to split the file contents by newline into a vector
- Trim and filter out empty lines just in case
- Remove duplicate links
- Collect to a vector of Strings

Not sure what you're used to calling them, iterator methods, stream API, lambdas, LINQ but
I absolutely love these in all languages. They are always a very powerful yet clean and concise
way of describing some operations on data that they are an indispensable part of most of the code
I write.

The great thing about rust is that these are claimed to be "zero cost abstractions", this means that
they come with seemingly no performance overhead. I have mostly used these iter methods in Java, Scala,
and C# and for those languages, I know that they have performance issues, especially when compared to say
for loops. I believe that C# has some overhead from instantiating some iterator class behind the scenes
while the JVM has cold start issues, whatever the case might be, all you need to know is that Rust
simply does not suffer from this; you can and should use these iter APIs.

Coming back to the actual code, I mentioned earlier that I wanted to support comments in the
feeds file. For reference mine looks like this:

```txt
https://antoniosbarotsis.github.io/index.xml

# Youtubers
https://www.youtube.com/feeds/videos.xml?channel_id=UCiSIL42pQRpc-8JNiYDFyzQ # Chris Biscardi
https://www.youtube.com/feeds/videos.xml?channel_id=UCUMwY9iS8oMyWDYIe6_RmoA # NoBoilerplate
https://www.youtube.com/feeds/videos.xml?channel_id=UC8ENHE5xdFSwx71u3fDH5Xw # ThePrimeagen
https://www.youtube.com/feeds/videos.xml?channel_id=UCsBjURrPoezykLs9EqgamOA # Fireship
https://www.youtube.com/feeds/videos.xml?channel_id=UC2Xd-TjJByJyK2w1zNwY0zQ # Beyond Fireship

# Rust stuff
https://blog.rust-lang.org/feed.xml
https://blog.rust-lang.org/inside-rust/feed.xml
https://this-week-in-rust.org/rss.xml
https://rust.libhunt.com/newsletter/feed
https://rustsec.org/feed.xml

[...]
```

I have way too many links and this commenting system helps me keep track of what's what.

The actual method looks like this;

```rust
pub fn read_feeds() -> Vec<String> {
  let links = fs::read_to_string("feeds.txt")
    .expect("Error in reading the feeds.txt file");

  // Not really necessary but yes
  // https://docs.rs/regex/latest/regex/#example-avoid-compiling-the-same-regex-in-a-loop
  lazy_static! {
    static ref RE: Regex = Regex::new(r"#.*$").unwrap();
  }

  links
    .split('\n')
    .map(std::string::ToString::to_string)
    .map(|l| RE.replace_all(&l, "").to_string())
    .map(|l| l.trim().to_owned())
    .filter(|l| !l.is_empty())
    .unique()
    .collect::<Vec<String>>()
}
```

`#.*$` matches a `#` followed by any number of characters and stops at the end of the line.

If you read the docs from the link I left in that comment you'll find the following;

> It is an anti-pattern to compile the same regular expression in a loop since
> compilation is typically expensive.
> [...]
> we recommend using the `lazy_static` crate to ensure that regular expressions are
> compiled exactly once.

Do I need this? Definitely not but I mean why should I not use it? Defining this
expression as a simple static (`const` in Rust) would not work in this case because
the Regex constructor is not a const so we need to use static.

The rest of the code remains the same except for that `RE.replace_all(&l, "")` which
removes the comments from the text before processing it further.

### Downloading

I define the following helper methods to handle the downloads:

```rust
#[derive(Debug)]
pub enum DownloadError {
  Ureq(Box<ureq::Error>),
  Io(std::io::Error),
  Custom(String),
}

fn is_supported_content(content_type: &str) -> bool {
  let supported = vec![
    "application/xml", 
    "text/xml", 
    "application/rss+xml", 
    "application/atom+xml"
  ];

  supported.contains(&content_type)
}

/// Helper function for downloading the contents of a web page.
pub fn get_page(url: &str) -> Result<String, DownloadError> {
  let response = ureq::get(url).call()?;

  if !is_supported_content(response.content_type()) {
    return Err(DownloadError::Custom(format!(
      "Invalid content {} for {}",
      response.content_type(),
      url
    )));
  }

  let body = response.into_string()?;
  Ok(body)
}
```

There's a bit of code here but it's relatively simple; download the page if the content
type is set to one of the supported ones, otherwise, return
a Download Error.

Now that we have a way of reading the user-defined links and downloading them, it's time
to process them!

```rust
pub fn download_blogs(days: i64) -> Vec<Blog> {
  let links = read_feeds();

  let contents: Vec<Blog> = links
    .into_iter()
    .filter_map(|link| {
      let xml = get_page(&link)
        .map_err(|e| warn!("Error in {}\n{:?}", link, e))
        .ok()?;

      parse_web_feed(&xml)
        .map_err(|e| warn!("Error in {}\n{}", link, e))
        .ok()
    })
    .filter_map(|x| {
      if !within_n_days(days, &x.last_build_date) {
        return None;
      }

      let recent_posts: Vec<Post> = x
        .posts
        .into_iter()
        .filter(|x| within_n_days(days, &x.last_build_date))
        .collect();

      let non_empty = !recent_posts.is_empty();

      non_empty.then_some(Blog {
        posts: recent_posts,
        ..x
      })
    })
    .collect();
```
TLDR:

- We iterate over our links
- Download their contents and parse them to `Blog`s (more on this later)
- Filter by posted in the last `n` days
- Collect

That's all of the "business logic" of the project, this one method. The result of this
gets directly mapped to HTML and emailed but before we check that part out, let's see
what all those `Blog`s and `Post`s are...

## Representing Web Feeds

When I started this project, I thought to myself "oh well this should be simple, I just
download the RSS feed and parse it!". Well, that's not far from the truth but what I did
not know was RSS is just one Web Feed format, there's another one called Atom that is
also very popular.

Here are some links in case you are interested;

- [Web Feeds](https://en.wikipedia.org/wiki/Web_feed)
- [RSS Spec](https://www.rssboard.org/rss-specification)
- [Atom Spec](https://www.rfc-editor.org/rfc/rfc4287)

So we already have a small problem, that being that we have 2 different possible inputs
that represent the same thing. In addition, some fields that I need are not mandatory
(such as dates for instance) which I need to handle.

This lead me to create the following structs that represent any web feed;

```rust
#[derive(Debug, Clone)]
pub struct Blog {
  pub title: String,
  pub last_build_date: DateTime<FixedOffset>,
  pub posts: Vec<Post>,
}

#[derive(Debug, Clone)]
pub struct Post {
  pub title: String,
  pub link: String,
  pub description: Option<String>,
  pub last_build_date: DateTime<FixedOffset>,
}
```

> Small edit here, I've made a few changes to the codebase already while
> writing this article because I kept realizing some stuff could be better.
> In this case I switched from `DateTime<FixedOffset>` to `DateTime<Utc>`
> for consistency. This post would take forever if I kept detailing every
> small change like this so I will just focus on more important, high-level
> modifications. If you want to copy paste some stuff from my code, I'd recommend
> copying from the repository instead of here.

Now this part of the code I am not particularly proud of and I think that
if I remade it now I'd design it completely differently but again, keep in mind I am
still very new to the language and this was one of the first things I did.

I kept getting progressively annoyed by how I implemented this abstraction and I am quite
happy with how I did it later on for the emails, if you want a "good" example of abstractions
in Rust, that one probably comes closer to it, definitely not this one but here goes;

```rust
/// Represents a web feed that can be converted to a `blog.Blog`.
pub trait WebFeed {
  fn into_blog(self) -> Result<Blog, String>;
}

/// Represents an object that can be converted to a `blog.Post`.
pub trait BlogPost {
  fn into_post(self) -> Result<Post, String>;
}

/// Helper wrapper for `Result<T, String>` where `T: XmlFeed`,
pub trait ResultToBlog<T>
where
  T: WebFeed,
{
  fn into_blog(self) -> Result<Blog, String>;
}
```

The idea is to, again, abstract away from a specific, underlying implementation
and treat everything the same. This might make more sense later when you see how
these are used.

### RSS and Atom Concrete Implementations

Remember that the feeds look like this:

```xml
<!-- RSS -->

<rss>
  <channel>
    <title></title>
    <lastBuildDate>RFC 2822</lastBuildDate>
    <pubDate>RFC 2822</pubDate>
    <item>
      <title></title>
      <link></link>
      <pubDate>RFC 2822</pubDate>
      <description></description>?
    </item>
  </channel>
</rss>

<!-- Atom -->

<feed>
  <title></title>
  <updated>ISO.8601</updated>
  <entry>
    <title></title>
    <link href=""/>
    <updated>ISO.8601</updated>
    <summary></summary>?
  </entry>
</feed>
```

The corresponding structs are as follows;

```rust
///////////////// RSS /////////////////
pub struct RssFeed {
  pub channel: Channel,
}

pub struct Channel {
  pub title: String,
  pub last_build_date: Option<String>,
  pub pub_date: Option<String>,
  pub items: Vec<RssPost>,
}

pub struct RssPost {
  pub title: String,
  pub link: String,
  pub description: Option<String>,
  pub pub_date: Option<String>,
}

///////////////// Atom /////////////////

pub struct AtomFeed {
  pub title: String,
  pub entries: Vec<AtomPost>,
}

pub struct AtomPost {
  pub title: String,
  pub link: Link,
  pub summary: Option<String>,
  pub updated: String,
}

pub struct Link {
  href: String,
}
```

Skipped the macros for the sake of readability.

We now need to implement the traits I defined earlier. I won't be showing these in detail
as they are fairly boring, I'll instead just list them out;

```rust
impl WebFeed for RssFeed { ... }
impl BlogPost for RssPost { ... }
impl ResultToBlog<RssFeed> for Result<RssFeed, Error> { ... }

impl WebFeed for AtomFeed { ... }
impl BlogPost for AtomPost { ... }
impl ResultToBlog<AtomFeed> for Result<AtomFeed, Error> { ... }
```

Now that all that bloat is out of the way we can finally write the one method we
truly are about:

```rust
/// Turns an XML feed into a `Blog` if possible.
pub fn parse_web_feed(xml: &str) -> Result<Blog, String> {
  let possible_roots = vec![
    from_str::<RssFeed>(xml).into_blog(),
    from_str::<AtomFeed>(xml).into_blog(),
  ];

  let (roots, errors): (Vec<_>, Vec<_>) = possible_roots
    .into_iter()
    .partition_result();

  roots
    .first()
    .cloned()
    .ok_or_else(|| format!("{:?}", errors.iter().unique().collect::<Vec<_>>()))
}
```

It is worth noting that you should probably not use `String`s for your errors but
everyone has to start somewhere right?

The idea behind this was to try and parse the given XML in all formats until one succeeds.
We then use this super handy `partition_result` method which splits the successful results
from the errors. Lastly, if any of these succeeded then we return the result, otherwise,
we throw an error.

## Sending Emails

Finally covered all of that web feed representation stuff, definitely feels like quite the
mess but I am not exactly motivated enough to go back and make it better.

If you know any Rust (or even if you don't honestly), I feel like you would agree with me
that this is a relatively messy solution right? I mean it does work, don't get me wrong,
but I would not want to "teach" this to someone.

The reason why I included it is to contrast it with this section that deals with the emails
because the two could not be further apart in my opinion and I am hardly ever satisfied
with my code so this should mean something.

The idea with the emails is that everyone might have their own favorite provider and I shouldn't
limit them. I used [Twilio SendGrid](https://sendgrid.com/) which is the only available
implementation currently. It is, however, extremely easy to add more implementations
(which I wouldn't say for the web feeds) as you'll see soon.

The core of the email-related code is the `EmailProvider`; an abstraction
over an email backend

```rust
#[enum_dispatch]
pub trait EmailProvider {
  /// Sends an email to and from the specified address.
  fn send_email(&self, address: &str, api_key: &str, contents: &str);
}
```

Let's see the SendGrid implementation before explaining why this works much better than before:

```rust
#[derive(Default)]
/// `EmailProvider` implementation using [`SendGrid`](https://sendgrid.com/).
pub struct SendGrid {}

impl SendGrid {
  pub(crate) fn new() -> Self {
    Self::default()
  }
}

impl EmailProvider for SendGrid {
  fn send_email(&self, address: &str, api_key: &str, contents: &str) {
    let contents = contents.replace('\"', "\\\"");
    let message = format!(r#"..."#);

    let req = ureq::post("https://api.sendgrid.com/v3/mail/send")
      .set("Authorization", &format!("Bearer {}", &api_key))
      .set("Content-Type", "application/json")
      .send_string(&message);

    match req {
      Ok(req) => info!(
        "Email request sent with {} {}",
        req.status(),
        req.status_text()
      ),
      Err(e) => error!("{}", e),
    }
  }
}
```


> The `message` was omitted for the sake of readability and can be found [here](https://github.com/AntoniosBarotsis/Rss2Email/blob/7fa496bcdd54dbdbf4d61732e3cc2cf3fdbef839/src/email/sendgrid.rs#L19).

We define a simple struct with a constructor and implement the `send_email` method for
`EmailProvider`. The implementation isn't too exciting; it's just a formatted string
sent to the SendGrid API.

This is where it gets a little more interesting.

```rust
/// An enum containing all Email Provider implementations.
#[enum_dispatch(EmailProvider)]
enum EmailProviders {
  SendGrid(SendGrid),
}
```

This enum in combination with a `String -> EmailProvider` converter;

```rust
impl From<String> for EmailProviders {
  fn from(input: String) -> Self {
    // Note that the input is trimmed and converted
    // to upper case for the sake of consistency
    match input.trim().to_uppercase().as_str() {
      "SENDGRID" => Self::SendGrid(SendGrid::new()),
      e => {
        warn!("Invalid Email provider: {}, defaulting to SendGrid.", e);
        Self::SendGrid(SendGrid::new())
      }
    }
  }
}
```

allows me to finally declare this method

```rust
/// Abstracts away the email backend.
///
/// By default, this will return the `SendGrid` implementation.
pub fn get_email_provider() -> impl EmailProvider {
  let env_var = std::env::var("EMAIL")
    .ok()
    .unwrap_or_else(|| "SENDGRID".to_owned());

  EmailProviders::from(env_var)
}
```

This first obtains the `EMAIL` environment variable (or overwrites it to `SENDGRID` if not found)
and uses the `From` trait we implemented earlier to convert that to an Email Provider.

This is great because:

1. The consumer of `get_email_provider` does not need to know what is happening
2. Adding a new email provider means only adding one new entry in the `EmailProviders` enum and
    our `from` function.
3. This is all type-safe, and guaranteed to work; the `EmailProvider` is bound to assume
    some value before we try to interact with it.
4. All implementations are concentrated in one spot and it's easy to edit them.

## AWS Lambda

I recently deployed on AWS Lambda for the first time. It was a C# function that would run once a day
and send text messages to help my dad keep track of some of his appointments which as you may have noticed
is relatively similar to what I am building here.

I wanted an easy way to deploy this and run it with a CRON job and AWS makes both very easy.

There are two parts to this:

- Adding the AWS Rust Runtime
- Dockerizing the app

### Adding the Runtime

AWS Lambda uses [Runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) to support any language
out there (as long as they have an implementation of it of course). This means that making our code run on Lambda
is not as trivial as just *pushing it there*. Luckily for us, we don't have to
[build our own custom runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html#runtimes-custom-build)
as the AWS folks have handled that already in [this crate](https://github.com/awslabs/aws-lambda-rust-runtime).

If you want a guide on how to use it then just go ahead and read their docs as they are quite straightforward.
I will instead talk about [Conditional Compilation](https://doc.rust-lang.org/reference/conditional-compilation.html)

.The runtime needs *a lot* of dependencies, around as many as the rest of the project if I recall correctly.
In addition to that, as I likely mention somewhere, I want this project to be as easy to run as possible and
the Lambda runtimes always complicate things somewhat in addition to bloating the project and doubling
my compilation times. Ideally, I would want to have a way to separate the core project from the Lambda stuff
and in fact, early on I achieved this with Git by having 2 separate branches but that was certainly annoying.

If only there was a simple way to solve this problem.

Introducing conditional compilation! Only compile the parts of the code that you choose! This is done through
[features](https://doc.rust-lang.org/cargo/reference/features.html).

There are 2 parts to this;

- The dependencies
- The code

#### The Dependencies

To tell Cargo that some of your dependencies are to only be included when certain features are specified
you need to declare the dependency as `optional` like so:

```toml
lambda_runtime = { version = "0.6.0", optional = true }
```

And to actually include it with a feature you can do this:

```toml
aws-lambda = [ "dep:lambda_runtime" ]
```

I do this with another 3 dependencies but you get the idea.

#### The Code

Of course, this only makes sense if you can define whether some pieces of the code are specific to a feature
or not. I think that there's more than one way to do this but what I did is something like the following:

```rust
[cfg(not(feature = "aws-lambda"))]
fn main() -> Result<(), String> { ... }

#[cfg(feature = "aws-lambda")]
fn main() -> Result<(), aws_lambda::LambdaErr> { ... }
```

I made 2 different `main` methods! The second method calls code defined in a module that is also annotated
with `#[cfg(feature = "aws-lambda")]` while the first one just calls "*normal*" Rust code.

I found this very useful for this specific use case but I can also see how convenient this is if you are dealing
with platform-specific code. Another nice application of this would be to let users decide which modules
of your library they actually need instead of importing a giant framework to use 1 method.

Choosing these features is done by appending `--features aws-lambda` to your `cargo` commands, for instance,
`cargo run --features aws-lambda`. This as you are about to see is also made use of in the Dockerfile.


### The Dockerfile

Credits for the Dockerfile go to [this](https://tms-dev-blog.com/lean-docker-image-for-rust-backend/) post but I'll
include a short explanation here anyway.

This is the full Dockerfile:

```Dockerfile
FROM rust:1.64-alpine as builder

ARG compile_flag=""

RUN apk add --no-cache musl-dev
WORKDIR /opt
RUN cargo new --bin rss2email
WORKDIR /opt/rss2email
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
RUN cargo build --release $compile_flag

RUN rm ./src/*.rs
RUN rm ./target/release/deps/rss2email*

ADD ./src ./src
RUN cargo build --release $compile_flag

FROM scratch
WORKDIR /opt/rss2email
COPY --from=builder /opt/rss2email/target/release/rss2email .
COPY ./.env ./.env
COPY ./feeds.txt ./feeds.txt

CMD ["./rss2email"]
```

Let's break it down.

- I use `alpine` as they usually are somewhat lighter than the standard images.
  I also name this [stage](https://docs.docker.com/build/building/multi-stage/)
  `builder`.
- The `compile_flag` is used to optionally include `--features aws-lambda` as a
  command line argument.
- `musl-dev` was needed for one of my cargo dependencies so I need to install it
- I create a **new and empty** cargo project and paste in my `Cargo.lock` and
  `Cargo.toml` files, I do this in order to compile all my dependencies separately
  from the rest of the project to make better use of the caching mechanism. After
  this, we remove all source files (the `main.rs` that `cargo new` generates) and
  all created executables since neither are related to my project.
- I add in my source directory and build it. By doing this here we make sure that
  any change in the source code that is not accompanied by the addition or removal
  of dependencies will use the cache up to this step, saving us a lot of time.
- After all this, I finally copy the executable over to a new stage, and lastly, I add
  the `.env` and `feeds.txt`. By adding these 2 files last, similarly to earlier,
  we will make use of the cache up to this step which means we will be completely
  skipping any compilations and thus the build will only take one or two seconds.

This isn't really relevant to the rest of the project but as someone who likes
using Docker, Rust offers a very neat, simple and efficient solution for a
compiled language. My last experience with Docker was trying to dockerize a
Scala project which is, in stark contrast, messy, convoluted and somehow still
terribly slow.

## Benchmarking

Proper benchmarking is something I started getting interested in relatively recently.
More specifically (and at this point unsurprisingly), the small testing framework I have been
contributing to [PoSharp](https://github.com/pijuskri/Po-Sharp) was quite slow at its first
implementation(please make dumb but working implementations before you start optimizing).
After a few headaches and some good old 4 am coding, I managed to make it 
2 or 3 times faster which was great. I also optimized the workflow duration from around 10 minutes
to 2-3 if I remember correctly which was pretty cool if you ask me. All of this was the combination
of a few educated guesses about performance and a lot of benchmarking. It reinforced why
benchmarking is important to me.

Coming back to Rss2Email, running this thing was a bit slower than I expected at first;
I had around 30-40 links at the time, and running the code locally would take around
13 seconds give or take. In this case, it is relatively obvious to say that this is
a Network bound program but I wanted to have a very clear point of reference for future
comparisons so I wanted to benchmark this regardless.

I wanted information on how long specific methods took to run so I started looking into
[Criterion](https://crates.io/crates/criterion) which is a great library. As I'll explain
shortly, these were unsurprisingly conclusive that indeed, the issue is the Network IO
which is why I will probably be adding asynchronicity to the project at some point.
Because of that, I will likely write some application-level benchmarks with
[Hyperfine](https://github.com/sharkdp/hyperfine) to have some nice before and after
comparisons but that's work for another day.

I opened [a Hacktober](https://github.com/AntoniosBarotsis/Rss2Email/issues/8) issue for
the Criterion benchmarks and it was the first one to receive a contribution. I added
some stuff to it myself and found this interesting enough to write about it.

Also, a short note, I just realized at the time of writing this that the plots are a bit
small. You can still read them but it's mildly annoying, sorry for that. They are, however,
SVGs so you can easily right-click > open in new tab and zoom in as much as you want :)

I don't think that the code behind these is particularly interesting but if you want,
you can check it out yourself 
[here](https://github.com/AntoniosBarotsis/Rss2Email/tree/master/benches/benchmarks).

#### Mapping to HTML

The first thing I wanted to benchmark as a test and to get Criterion all set up was the
method that maps the `Blog`s to HTML.

{{ image(src="/img/rss2email/map_to_html.svg", style="max-width:120%;margin-left:-10%;margin-right:-10%") }}

Not exciting as turns out, code is fast.

#### Downloading Blogs

Criterion generated the following plot.

{{ image(src="/img/rss2email/download_blogs.svg", style="max-width:120%;margin-left:-10%;margin-right:-10%") }}

We can see that this is a bit faster than the 13 seconds that I mentioned earlier which
is most likely because I was running in debug mode while Criterion uses Release by default.

From this, we can very easily see where the performance drops, and spoiler alert, it is, in
fact not in mapping the blogs to HTML but actually downloading them, who would've thought?

I had one question after this, and that was whether some blogs were disproportionally slower
than the rest. Since this is a purely blocking and synchronous process, that would slow
down the code quite a bit. That's what the next test is about. 

#### Downloading Blogs One by One

Unfortunately, as you can tell, whatever plotting library Criterion uses does not
exactly like how long these links are but it's not particularly important to actually
be able to read them. These links are the feeds I am currently following so feel free
to manually search them and see if you find them interesting I guess.

{{ image(src="/img/rss2email/get_page.svg", style="max-width:120%;margin-left:-10%;margin-right:-10%") }}

Unexpectedly, I was actually right, one of these takes way longer than average and as I
explained previously, this does bring down performance quite a bit.

This is the type of insight I was hoping to gain from an analysis like this so I am
more than happy.

#### Conclusions

As I mentioned earlier, I wanted to pinpoint the areas that make my performance drop so that
I can have very clear goals and points of reference when I try optimizing them.

My key takeaways from this are:

- This project is heavily Network IO bound
- Right now, individual feeds *can* affect performance a lot if they are disproportionally slow

Both of these indicate that adding asynchronicity would be a great performance improvement
and hence, will be something I'll do soon.

## The Future

The project is definitely working as is and I don't have any specific ideas for brand-new
features in mind. That said, some small modifications are planned, namely;

- Improving the docs and getting started pages
- [Some more testing](https://github.com/AntoniosBarotsis/Rss2Email/issues/9)
- Adding async support
- [Prettier emails](https://github.com/AntoniosBarotsis/Rss2Email/issues/6)
- [Using environment variables for easier configuration](https://github.com/AntoniosBarotsis/Rss2Email/issues/7)

I linked to the issues associated with some of these, the other 2 will probably be tackled by
me after the other 3 have been closed.

You are more than welcome to
[open issues](https://github.com/AntoniosBarotsis/Rss2Email/issues/new/choose) if you have any ideas!

## Closing

This was a fantastic learning experience for me and the end result is something that I have
been using ever since it was usable.

It was interesting dealing with community contributions as I made a few Hacktober issues that
got picked up by random people I did not know. It was also interesting incorporating
some ideas from solutions I came up with for other repositories (through Hacktoberfest)
into this .project

And lastly, being offered the chance to talk about this in front of an audience is one I am
very much grateful for! I love helping people figure programming out
and I hope I find myself in more similar situations in the future :)

Till next time!
