---
title: "About Me"
showViewSource: false
hideComments: true
readingTime: false
rss_ignore: true
---

## About Me

<!-- TODO firm believer in learning by myself -->
Hello 👋

I'm Tony, and I love software. I am genuinely interested in most-things Computer Science
and I am constantly learning. I very often find that university courses do not satisfy
my curiosity (I am not dissing my university, Bachelor courses aren't supposed to go to great
depths anyways!) but thankfully the internet exists and it always has an abundance of information
on pretty much everything.

Whenever I have time, I like watching conference talks (especially [NDC](https://ndcconferences.com/)!),
reading random articles or books and browsing Github. Usually that is enough to get me a
project idea which I work on for some time and then the cycle repeats.

### Interests

- Software & Backend Development
- Exploratory Data Analysis & Machine Learning
- Software Architecture, System Design & DevOps
- DevTools, Libraries & Frameworks

### Professional Experience

- *Junior Backend Developer* at GILO Technologies `from September to December 2021`.
- *Student Mentor* for Postman API Fest 2022 `26th to 29th January 2022`.
- Received a *Letter of Appreciation* for performing data analysis and statistical processing of
  the exam  results from the `2020-2022 academic years` for the European Board of Physical
  and Rehabilitation Medicine (EBPRM) `June 2022`.

### Practical Experience

I've worked with numerous technologies and here's a few broad, important ones that I am very
comfortable with;

- Java, C#, Rust
- Spring Boot, .NET Core
- Docker, automation and CICD
- SQL Databases

Less general topics (but definitely not less useful!) that I have either read about or practiced
myself are hard to list one by one. For that, refer to the [*My Journey*](#my-journey) section.

### Some Cool Projects I've Worked On

- An experimental Compiler written in Rust -
  [[repo](https://github.com/AntoniosBarotsis/RustSharp)]
- A testing framework for a compiler written in Scala - 
  [[repo](https://github.com/pijuskri/Po-Sharp/tree/master/app/src/main/scala/veritas)] 
  [[blog](../posts/posharp)]
- A proof of concept - clone of the C# AutoFixture package in Java - 
  [[repo](https://github.com/AntoniosBarotsis/BudgetFixture)]
  [[blog](../posts/budget_fixture)]
- A CLI interface to Git-Hooks through `yml` files - 
  [[repo](https://github.com/AntoniosBarotsis/Rember)]
  [[blog](../posts/zip_it_and_ship_it)]
- A Discord bot that generates graphs on Covid data - 
  [[repo](https://github.com/AntoniosBarotsis/coronaBot)]

You can find a few more on [my Github](https://github.com/AntoniosBarotsis?tab=repositories).

## My Journey

### 2019

This is when I first got formally introduced to programming and Computer Science in general. 

I learned the basics of Java, Javascript and wrote a few X86 Assembly scripts (don't ask). Learned the concepts of Object Oriented Programming as well as some stuff about Functional concepts. Got introduced 
to algorithms and abstract data structures. Began learning the basics of relational, document and graph 
databases. 

There was not much self learning throughout this year in contrast to the next ones since
I was still very new to the field.

### 2020

Some of the earliest programming I ever did was making Discord bots with DiscordJS. Motivated to
learn more about Javascript, I worked on my first 'big' project; 
[coronaBot](https://github.com/AntoniosBarotsis/coronaBot). 

For no apparent reason, I decided to learn some basics about Linux (I briefly used Arch by the way), 
Bash and regex. 

I got pulled into the realm of Machine and Deep learning, as well as Data Science and I learned a few
basics about all 3 of these starting with Python but decided to switch to R. I discovered Kaggle and 
entered 2 competitions in which I was really proud to score fairly above average. 

This is where University started so I had to  drop working on these and I went for stuff that was more 
relevant to my programme. I familiarized  myself with the Java ecosystem some more. I learned about
Maven and Gradle, testing and some basic  CI/CD + automated test coverage reports. I learned SQL and 
started teaching myself about Spring Boot while also starting work on a multiplayer, browser chess game.

### 2021

I got comfortable with deploying my projects. Learned how to work with Heroku and automate my
builds, tests and deployments. I finished and deployed the chess game. I learned more about Docker and
how to package my apps with it. 

I wrote my first article on Spring Boot after polishing my knowledge on  it a bit more and posted it to 
help my fellow students prepare for an upcoming course. 

After taking a short break from learning on my own, I learned how to publish an npm package, 
[FakeDB](https://github.com/AntoniosBarotsis/fakeDB) which to this day I am unsure as to whether it 
works or not and looking back, I am too scared to check. 

I started working on [Gromceri](https://twitter.com/gromceri) which was the biggest project I had  
tackled so far. Learned about authentication and JWTs in particular. Learned a lot abou C# and the .NET 
ecosystem.  I learned how to securly deploy public repositories without giving all my credentials and
secret tokens away. I worked on database optimizations as well as logging. For the first (and 
coincidentally last) time I used GraphQL in this project. 

After working on that for a few months I went back to python to learn a bit of Django
and FastAPI to prepare for my first internship. I dove into NLP using python with Spacy, Bert and 
PyTorch and a lot of regular expressions for my first internship. There, I also worked on API
development with Python and Azure Functions as well as dove into asynchronous programming and profiling 
for the first time. 

### 2022

This is the first time I decided to set some goals for myself. 

I decided to start by tackling one of  them which was 'create and publish a Nuget package that does 
something useful' and thus, [Rember](https://github.com/AntoniosBarotsis/Rember) was created. Rember is 
a CLI tool that lets you easily configure git hooks and is currently available both on Nuget and 
Chocolatey. This was the first time I packaged a project of mine and made it available to the broader 
public through a more general purpose manager and it definitely was a great experience. 

I was getting more and more interested in working on things like libraries and frameworks and I 
thankfully had the chance to work on one. A friend of mine is developing 
[his own compiler](https://github.com/pijuskri/Po-Sharp) and I decided to build a small testing
framework for it. I got to dive into things like reflection and multi threading and it has 
been a great learning experience seeing this project grow. I also consider the blog post I made about it 
to be the most detailed one so far so that is also nice. 

This sparked an interest in learning more about optimizations and concurrency as well as other things 
like source generators. 

Over the summer I decided  to refine my knowledge on scalability and architecture design. I learned more 
about load balancing with Nginx and Caddy, monitoring applications using InfluxDB and Grafana, CQRS, 
event sourcing, different database strategies, bringing all that together with Docker and performing 
load testing with k6. All the reading that I did over this period has greatly helped me understand 
scalability and more importantly, how (and when) to build for scale as well as identify the parts of a 
project that can be scaled and how to go about doing that. 

I learned a bunch more stuff about parallel and asynchronous programming which I'll be glad to make use 
of at some point. 

I decided to start learning Rust while building 
[my own Programming language](https://github.com/AntoniosBarotsis/RustSharp), inspired by my 
aforementioned friend. Turns out, compilers are rather complicated and LLVM is not any better.
I looked into syntax highlighting and neat error reporting as well.
