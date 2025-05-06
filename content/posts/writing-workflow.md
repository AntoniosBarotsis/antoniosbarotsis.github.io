---
title: "My writing workflow"
description: "Helping myself blog"
keywords: ["Blogging", "spell", "check", "cspell", "dead", "link", "lychee"]
date: 2025-05-06T12:28:06+02:00
draft: false
taxonomies:
  tags: ["No Coding", "Meta"]
---

## Introduction

In my [last post](../low-effort-everything#closing) I mentioned that because the post was so long
compared to what I usually put out, I ended up improving my CI to help me catch some errors more
easily.

I found it quite useful and I've actually been using parts of it for many of my notes and my ongoing
Bachelor thesis so I felt like sharing it!

### My Workspace

It is worth mentioning that my blog posts are written in Markdown and as I'm a fan of markup
languages (over say Microsoft Word or something), my thesis is written in [Typst].

I'm bringing this up because if you do use fancier environments like Word, there are probably
more convenient ways of achieving the improvements I'm going to talk about. If you do write loads
of text in a code editor like me however, you might find something useful in the rest of this post!

### Spell Checking

The first (and arguably more important) change I made was performing spell checking in my CI! I
cannot believe it took me this long to even consider adding something like this. I think that's
because VSCode does do some spell checking (or maybe it was some of my plugins?) but it was not
always correct, it was inconsistent, sometimes annoying and of course easy to miss.

What I ended up doing is setting up [CSpell]. Their docs are pretty decent so I won't go into too
much detail but essentially what you end up doing is
- creating a config file `cspell.config.yaml`
- creating a file of allowed words that `cspell` does not already accept `project-words.txt`

In the config you usually define things like what directories you actually want to spell check
(you probably don't care about spell checking your `node_modules` or something) or maybe any regexes
specifying text you want to ignore, and a whole bunch more that I don't really care about.

The `project-words` file is also neat as a lot of programming related words are usually considered
invalid (and so are many names) and you get to keep all these exceptions in 1 place as a plaintext
file. You can of course add to this file manually or, as per
[their docs](https://cspell.org/docs/getting-started#2-add-words-to-the-project-dictionary),
do something like 

```sh
cspell --words-only --unique "**/*.md" | sort --ignore-case >> project-words.txt
```
to append to it all the words `cspell` currently considers wrong so you can decide which _are_
wrong and which are false positives. Considering you are probably using git, you can very easily
immediately see which words were added to this dictionary so its easy to review them.

Running the spell checking in CI was trivial:

```yml
  spell_check:
    name: Spell check
    runs-on: ubuntu-latest
    steps:
    - name: Checkout main
      uses: actions/checkout@v4
      with:
        fetch-depth: 1

    - name: Install cspell
      run: npm install -g cspell@latest

    - name: Spell check
      run: cspell .
```

- Clone the repo
- Install cspell
- Run it
- Profit

Very low effort addition that will save you lots of headaches.

### Link Checking?

A tool I heard of a while ago but never tried out is [Lychee]. Lychee can scan your text files _or_
webpages and find all broken/dead links and mail addresses.

I had not realized how many of the links I used in older posts were just not working any more 🗿

I'll definitely start using things like [archive.is] more in the future to avoid this.

Setting this up was a little bit more annoying (not to Lychee's fault, websites are just annoying
to curl sometimes) but in the end I ended up with the following config:

```toml
# lychee.toml
cache = true
max_cache_age = "2d"
max_redirects = 10
user_agent = "curl/7.83. 1"
timeout = 20
retry_wait_time = 2

accept = ["200", "403", "429"]

insecure = false
scheme = ["https"]
require_https = false
method = "get"

# Check links inside `<code>` and `<pre>` blocks as well as Markdown code
# blocks.
include_verbatim = false

# Exclude URLs and mail addresses from checking (supports regex).
exclude = [
  'linkedin.com',
  'archive.is',
  'https://github.com/pulls',
  'https://gdsc.community.dev/delft-university-of-technology/',
]

# Exclude loopback IP address range and localhost from checking.
exclude_loopback = true

```

I think all of it is pretty self explanatory, as are
[the docs](https://lychee.cli.rs/introduction/).

While locally you can just serve your site and run Lychee via
`lychee http://127.0.0.1:1111/posts/specific_post` for new posts,
running it in CI was a bit more annoying because I wanted to check all pages of my blog.

What I ended up doing was use the [sitemap] (good chance your SSG generates one for you, try
`/sitemap.xml`), pass it to [this tool I found](https://github.com/lukehsiao/sitemap2urllist)
that just parses it and extracts all the URLs it contains (admittedly this does not seem that
hard to DIY but I am lazy) and _finally_ past all the resulting links to lychee using `xargs`.

The CI job looks like this:

```yml, linenos, hl_lines=15 16 26
  link_check:
    name: Link check
    runs-on: ubuntu-latest
    steps:
    - name: Checkout main
      uses: actions/checkout@v4
      with:
        fetch-depth: 1
        submodules: true

    - uses: cargo-bins/cargo-binstall@main

    - name: Install lychee
      run: |
        sudo apt-get install gcc pkg-config libc6-dev libssl-dev -y
        cargo binstall lychee sitemap2urllist

    - uses: taiki-e/install-action@v2
      with:
        tool: zola@0.19.2

    - name: Link check
      run: |
        zola serve &
        sleep 3
        sitemap2urllist http://127.0.0.1:1111/sitemap.xml | xargs lychee --config ./lychee.toml
      env:
        GITHUB_TOKEN: ${{ github.token }}
```

In short:

- Clone the repo
- Install `lychee` and its [build dependencies](https://lychee.cli.rs/installation/#build-dependencies)
  \+ sitemap2urllist (the tool I mentioned earlier) **(line 16-17)**
- I then serve my blog (which uses [zola]) and run lychee on the sitemap running in localhost
  (**line 26**)

This checks all links in my blog (both internal and external), pretty neat!

## Closing

That is all!

This was a pretty short post, not much else to talk about.

Till next time!

[Typst]: https://typst.app
[CSpell]: https://cspell.org/docs/getting-started
[Lychee]: https://lychee.cli.rs
[archive.is]: https://archive.is
[sitemap]: https://en.wikipedia.org/wiki/Site_map
[zola]: https://www.getzola.org
