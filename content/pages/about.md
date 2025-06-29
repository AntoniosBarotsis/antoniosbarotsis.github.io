---
title: "About Me"
rss_ignore: true
path: about
extra:
  hide_word_count: true
  hide_reading_time: true
  hide_toc: false
  hide_comments: true
---

## About Me

<!-- TODO firm believer in learning by myself -->
Hello 👋

I'm Tony, and I love software. I am genuinely interested in most things Computer Science
and I am constantly learning.

Whenever I have time, I like watching conference talks, reading random articles or books and
browsing GitHub. Usually, that is enough to get me a project idea which I work on for some time and
then the cycle repeats.

### Interests

- Concurrency and high-performance Software
- Software Architecture, System Design & DevOps
- DevTools, Libraries & Frameworks
- Rust 🦀

> "*I realized I want to work for other devs and not clients directly*"

### Professional Experience

- Received a *Letter of Appreciation* for performing data analysis and statistical processing of
  the exam results for the European Board of Physical and Rehabilitation Medicine (EBPRM)
  `2020-2024 academic years`.
- *Junior Backend Developer* at GILO Technologies `from September to December 2021`.
- *Member of the tech core team* in
  [Delft's Google Student Developer Club](https://web.archive.org/web/20230521000246/https://gdsc.community.dev/delft-university-of-technology/)
  `2022-2023 academic years`
- *Student Mentor* for Postman API Fest 2022 `26th to 29th January 2022`.
- Official maintainer of the [Resend Rust SDK](https://resend.com/docs/send-with-rust) `from May 2024`

### Some Cool Projects I've Worked On

- A real-time, transparent chart of your controller trigger inputs - 
  [[repo]](https://github.com/AntoniosBarotsis/controller-trigger-recorder)
- A library that provides a couple of Unicode utilities for dealing with Unicode 
  confusables/homoglyphs - 
  [[repo]](https://github.com/AntoniosBarotsis/confusables)
- A Mandelbrot renderer that leverages multi-threading and SIMD - 
  [[repo]](https://github.com/AntoniosBarotsis/mandelbrot)
- A QR Code generator library exposed as a web server and CLI. Built for
  [Delft's GDSC](https://web.archive.org/web/20230521000246/https://gdsc.community.dev/delft-university-of-technology/) - 
  [[repo]](https://github.com/AntoniosBarotsis/qr-rs) 
- An RSS feed aggregator that notifies you of new posts via email -
  [[repo]](https://github.com/AntoniosBarotsis/Rss2Email)
  [[blog]](../posts/rss2email)
- An experimental Compiler written in Rust -
  [[repo]](https://github.com/AntoniosBarotsis/RustSharp)
- A testing framework for a compiler written in Scala - 
  [[repo]](https://github.com/pijuskri/Po-Sharp/tree/master/app/src/main/scala/veritas)
  [[blog]](../posts/posharp)
- A proof of concept - clone of the C# AutoFixture package in Java - 
  [[repo]](https://github.com/AntoniosBarotsis/BudgetFixture)
  [[blog]](../posts/budget_fixture)
- A CLI tool to Git-Hooks through `yml` files - 
  [[repo]](https://github.com/AntoniosBarotsis/Rember)
  [[blog]](../posts/zip_it_and_ship_it)
- A Discord bot that generates graphs on Covid data - 
  [[repo]](https://github.com/AntoniosBarotsis/coronaBot)

You can find a few more on
[my Github](https://github.com/AntoniosBarotsis?tab=repositories&q=&type=source&language=&sort=).

## My Journey

This will get quite lengthy :)

### 2023

I managed to join my University's
[Google Developer Student Club](https://web.archive.org/web/20230521000246/https://gdsc.community.dev/delft-university-of-technology/)!
Carrying over some of the things I learned developing
[Rss2Email](https://github.com/AntoniosBarotsis/Rss2Email), I worked on a QR Code generator API
for the aforementioned student club to avoid being dependent on third-party software for generating
any QR codes needed for our events. I started reading Jon Gjengset's 
[Rust for Rustaceans](https://rust-for-rustaceans.com/) (great book and criminally underpriced, you
should go read it) which influenced some of my design choices for the crate I built for the project.

Following the "contributing to open source" goal I set for myself for the year, I started opening
[various pull requests](https://github.com/pulls?q=is%3Apr+author%3AAntoniosBarotsis+archived%3Afalse+sort%3Aupdated-desc+is%3Amerged+-user%3AAntoniosBarotsis+created%3A%3E%3D2022-10+), mostly in Rust
projects. These are small and simple contributions but I am planning on working my way up in
terms of complexity over the rest of the year and you have to start somewhere :) A nice step up was
[a small patch I created](https://gitlab.com/veloren/veloren/-/merge_requests/3853) for
[Veloren](https://veloren.net/) which was my first contribution to a *really* big, production
codebase (over 200k lines of code) without any particular guidance.

I decided to spend some time writing a few more "*useful*" blog posts such as
[`Python with a bit of Rust`](../posts/python_package_written_in_rust/) and
[`Finding Rust crates`](../posts/finding_rust_crates/) which combined gathered around 1000 reads
over 3 weeks!

<!-- I started experimenting with a flexible Text Search Engine written in Rust. It is still at quite
an early stage but hopefully, I'll be able to share more about it soon! -->

Having finished Rust for Rustaceans, I started reading the brilliant 
[Rust Atomics and Locks](https://marabos.nl/atomics/) by Mara Bos. This has been very insightful
both when it comes to low-level concurrency but also unsafe and more advanced Rust, definitely
recommended!

The book proved useful in a few areas of my Software Project where for 2 months, I and 5
other colleagues worked together in "*developing a cheap little robot to teach children and students
alike robotics and computer vision called [Mirte](https://mirte.org)*". The project aimed
to both get the robot to drive around a [model city](https://www.duckietown.org/) on
[very limited hardware](https://www.orangepi.com/index.php?route=product/product&product_id=844)
and to create interfaces of varying complexity to our code and the robot directly so as to allow
the users to implement the self-driving algorithms themselves.

The project was a success and it was really interesting to work on. Conveniently for me, we used
Rust so I felt at home! Being more experienced in the language (and in projects) than my colleagues,
I took responsibility for architecting key areas of the project as well as identifying various areas
and problems that needed to be tackled early to avoid time sinks in the future.

Apart from learning a lot of new things while working on the project, it was really cool to see
how a lot of things I had learned over time through my side projects contributed to this one
(even [that Scala testing framework](../posts/posharp/) I had made
for a friend's compiler turned out to be useful). There was also one instance where I removed a bunch
of unsafe, raw pointer code with 2-3 safe method calls which I was very proud of.

After all that was done and settled, I made a
[Mandelbrot set renderer](https://github.com/AntoniosBarotsis/mandelbrot) which I think looks
pretty cool. I also finally got around to looking into SIMD to make it faster, dove
a bit into constant generics and macros and wrote a
[blog post](../posts/simple_rust_macros/) about them which surprisingly amassed over 1300 reads!

A while after having watched 
[Dylan Beattie's talk called "Plain Text"](https://youtu.be/_mZBa3sqTrI), I decided to dig into
Unicode a bit more. The first time I encountered issues related to Unicode confusables was during
my first internship, specifically with different double quote characters. As I often want to learn
about multiple things per project, I decided to explore compile-time evaluation and parsing with
Rust as well as creating bindings for JavaScript's Node runtime. It was quite a fun project to
work on which you can find [here](https://github.com/AntoniosBarotsis/confusables).

### 2022

This is the first time I decided to set some goals for myself. 

I decided to start by tackling one of them which was 'create and publish a NuGet package that does 
something useful' and thus, [Rember](https://github.com/AntoniosBarotsis/Rember) was created. Rember
is a CLI tool that lets you easily configure git hooks and is currently available both on Nuget and 
Chocolatey. This was the first time I packaged a project of mine and made it available to the
broader public through a more general-purpose manager and it definitely was a great experience. 

I was getting more and more interested in working on things like libraries and frameworks and I 
thankfully had the chance to work on one. A friend of mine is developing 
[his own compiler](https://github.com/pijuskri/Po-Sharp) and I decided to build a small testing
framework for it. I got to dive into things like reflection and multi-threading and it has 
been a great learning experience seeing this project grow. I also consider the blog post I made
about it to be the most detailed one so far so that is also nice. 

This sparked an interest in learning more about optimizations and concurrency as well as other
things like source generators. 

Over the summer I decided to refine my knowledge of scalability and architecture design. I learned
more about load balancing with Nginx and Caddy, monitoring applications using InfluxDB and Grafana,
CQRS, event sourcing, different database strategies, bringing all that together with Docker and
performing load testing with k6. All the reading that I did over this period has greatly helped me
understand 
scalability and more importantly, how (and when) to build for scale as well as identify the parts
of a project that can be scaled and how to go about doing that. 

I learned a bunch more stuff about parallel and asynchronous programming which I'll be glad to make use 
of at some point. 

I decided to start learning Rust while building 
[my own Programming language](https://github.com/AntoniosBarotsis/RustSharp), inspired by my 
aforementioned friend. Turns out, compilers are rather complicated and LLVM is not any better.
I looked into syntax highlighting and neat error reporting as well.

Sometime after that, I decided to work on [Rss2email](https://github.com/AntoniosBarotsis/Rss2Email)
to extend my Rust knowledge. Having finished it as of writing this, I must say I find it quite
useful actually! I used some of the stuff I'd learned previously to package the project in a slim
Docker image and make it easy to host on AWS Lambda.

### 2021

I got comfortable with deploying my projects. Learned how to work with Heroku and automate my
builds, tests and deployments. I finished and deployed the chess game. I learned more about Docker
and how to package my apps with it. 

I wrote my first article on Spring Boot after polishing my knowledge of it a bit more and posted it
to help my fellow students prepare for an upcoming course. 

After taking a short break from learning on my own, I learned how to publish an npm package, 
[FakeDB](https://github.com/AntoniosBarotsis/fakeDB) which to this day I am unsure as to whether it 
works or not and looking back, I am too scared to check. 

I started working on [Gromceri](https://twitter.com/gromceri) which was the biggest project I had  
tackled so far. Learned about authentication and JWTs in particular. Learned a lot about C# and the
.NET ecosystem.  I learned how to securely deploy public repositories without giving all my
credentials and secret tokens away. I worked on database optimizations as well as logging. For the
first (and coincidentally last) time I used GraphQL in this project. 

After working on that for a few months I went back to python to learn a bit of Django
and FastAPI to prepare for my first internship. I dove into NLP using python with Spacy, Bert and 
PyTorch and a lot of regular expressions for my first internship. There, I also worked on API
development with Python and Azure Functions as well as dove into asynchronous programming and
profiling for the first time. 

### 2020

Some of the earliest programming I ever did was making Discord bots with DiscordJS. Motivated to
learn more about Javascript, I worked on my first 'big' project:
[coronaBot](https://github.com/AntoniosBarotsis/coronaBot). 

For no apparent reason, I decided to learn some basics about Linux (I briefly used Arch by the way), 
Bash and regex. 

I got pulled into the realm of Machine and Deep learning, as well as Data Science and I learned a
few basics about all 3 of these starting with Python but decided to switch to R. I discovered Kaggle
and entered 2 competitions in which I was really proud to score fairly above average. 

This is where University started so I had to drop working on these and I went for stuff that was
more relevant to my program. I familiarized myself with the Java ecosystem some more. I learned
about Maven and Gradle, testing and some basic  CI/CD + automated test coverage reports. I learned
SQL and started teaching myself about Spring Boot while also starting work on a multiplayer, browser
chess game.

### 2019

This is when I first got formally introduced to programming and Computer Science in general. 

I learned the basics of Java, and Javascript and wrote a few X86 Assembly scripts (don't ask). 
Learned the concepts of Object Oriented Programming as well as some stuff about Functional concepts.
Got introduced to algorithms and abstract data structures. Began learning the basics of relational,
document and graph databases. 

There was not much self-learning throughout this year in contrast to the next ones since
I was still very new to the field.
