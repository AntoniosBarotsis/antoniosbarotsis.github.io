---
title: "Low-effort everything"
description: "From taking shortcuts in code to taking shortcuts in learning"
keywords: ["AI", "slop"]
date: 2025-04-12T01:12:39+02:00
draft: false
taxonomies:
  tags: ["Rant", "AI", "No Coding"]
---

## Introduction

This post will just be me ranting for a while about a _bunch_ of different topics that have all
been marinating in my mind for the better part of the last year or so.

There is not really a single thing this post is about as you're about to see, it's more so few
unrelated topics that all share this "lowest effort possible" and cutting corners mentality, my
frustrations for which have been boiling up for a while but were hard to really put to words.

## Lab Work for my University Course

Let's start with what prompted this post.

### A Disclaimer

Let's make a few things clear before I get into this. I will try to stray away from any specifics
about the course and assignment(s) I am going to talk about in this section. This is not meant to be
an attack to any of the people involved directly, I believe the things that I am going to be
complaining about are rather common and this is just an example I personally came across. 

I also understand that there likely are limitations imposed to those who worked on the course and
assignment(s) that are unknown to me; whether that would be about the amount of time they have
available or something else entirely. I am no academic let alone professor, I am just a student that
is passionate about software, this is why I am writing all of this in the first place.

It is near impossible to truly understand how hard and time consuming creating a course
and its assignments must be, I certainly do not know much about that. Thus, understand that this
post was written by an outsider; someone with no experience as a professor and even next to no
professional experience in general. This is written purely out of love for my field and the
frustrations I've been having about some of its recent developments.

THAT SAID, will any of this prevent me from dumping my complaints here? *No*!

### The First Assignment

It was more so the second assignment that prompted this post but a few relevant things can be said
about this one.

I won't get into the specifics of what exactly we had to do in this assignment since it does not
matter for the points I want to make, all you need to know is we were given a codebase of 1 or 2
thousand lines of Python code, and some _very_ loose guidelines on what we had to do.

The assignment required us to experiment a lot with the code and try a bunch of ideas to see what
works and what makes sense. It was not a "_here's some code that partially works, finish it_" type of
assignment, it was more like "_here's some code that already does something, we need you to come up
with ways of extending it_".

The best way to describe the codebase I think would be an extremely brittle and fragile blob.
Combine that with how hard non-type hinted python is to work with and you've got a ✨mess✨.

Why am I dunking on the poor guy that had to code this up? Well because I just don't think he was
proud of it himself either and I don't think he was to blame. The code felt very much thrown
together and lacked cohesion in its design, things you often see when you have to rush to meet
a deadline. My question is why were the higher ups, whether that'd be professors or whoever else
happy with this and felt like using it for the assignment instead of just giving the guy a bit more
time to refine it or even have such refinements as a general requirement. If you tell people that
it is important to pay attention to their code quality because other people will have to work on it,
they'll be conscious about it and program with that in mind.

> And just to be clear, I am not immune to this by any means. This is normal. I didn't have enough
> time given the deadline to do things as I wanted so I had to move fast and hack things together.
> I get it. Saying I'm ashamed of how bad my code was would be a bit too strong a word but I for
> sure was not happy with it either. It worked but i wouldn't want to touch it again.
>
> What I'm trying to say is, its normal to write sloppy code when under tight time limits. I get
> why I, a student, have tight time limits, we need to finish the assignment at some point after all.
> What I don't get is why the people making the assignment could not just _use some more time since
> they clearly needed it_.
>
> They are not bound by having to start a few weeks before the deadline like the students do
> and there is nothing preventing them from working on the assignment code _after_ the deadline
> has passed. The assignment code was unchanged (and re-used) for multiple years, our course lasts
> 2 months.

I can already feel some people reading this thinking something along the lines of "_Oh so you want
them to make everything perfect for you? To make your life easier? They want to teach you how to work
in such bad environments because that's often how workplaces are!_"

This is such a silly argument. Very convenient how it coincides perfectly with what you get from a
combination of laziness and neglect.

There's a difference between someone not laying all the ground work for you vs someone intentionally
doing a bad job to artificially make an assignment harder. Does one learn more from being forced to
work with subpar code in subpar environments? Probably. But immediately assuming the people behind
this are doing this intentionally for your own good is a quite the reach. It seems much more likely
to me that they have other more interesting and important stuff to attend to, whether that'd be
their own courses that they are taking or actual research and they thus pay little attention to this
random assignment meant for Bachelor students. 

I understand that but this does not mean I can't believe they should do better!

On a side note, as I understand, it was just one guy worked on this assignment. I think it would've
been an enormous help to him to have worked with at least one other person. These are things that
you need to consider as the person coordinating (I'm assuming the professor) the assignment creation,
you need to have some quality requirements and since you "outsource" the work to teaching assistants,
you need to figure out how to help them achieve your quality standards more easily. You take the role
of a project manager somewhat, this shouldn't be a fire and forget process.

I know I'd have a hard time getting something like that to work well first try but the goal should not
be to get it done as soon as possible; it should be to end up with something good. If that needs
more time than whatever you gave the TA then so be it.

### The Second Assignment

This specifically was the last straw that led me to finally write about this because it pulled a
couple of things together for me.

In this assignment we had to create some agent that would do some stuff and the main way to evaluate
how good the agent was is to put him against the rest of the agents in a tournament. This tournament
was a 1-on-on-1 matchup between every pair of agents. In addition, each pair had _I think_ 4
rematches.

If you are a programmer, this should already be ringing alarms in your head.

Now my math is a little rusty but I believe that this ends up being `2n(n−1)` matchups for `n`=
the number of agents.

The problem is we had 32 agents to run, and that was already a subset, there were a lot more.
This amounts to 1984 matchups, each of which should take at most 10 seconds (+ some extra time
to spin everything up which was not counted in these 10 seconds but lets ignore this for now).

That leaves us with a whopping _5 and a half hours_ needed to run this tournament on all 32 agents.

This is quite the problem as the assignment requires you to experiment a lot and there is not really
a way to confidently know what effect most of your changes are going to have without testing them.
And since each one of those agents are different, testing on anything smaller than the full 32 agents
might give you an incomplete picture of the effectiveness of your changes.

And to top all that off, randomness plays a non-negligible role in each matchup, meaning that _after_
you run the tournament, ideally you'd want to run it again a few times just to be sure it was not
a one-off lucky result.

Now, again if you are a programmer, a few more alarms should be going off for you still; this is an
[Embarrassingly parallel](https://en.wikipedia.org/wiki/Embarrassingly_parallel) task. Do you want
to guess that the performance improvement was from parallelizing this?

{{ image(src="/img/low-effort-everything/perf-comparison.webp") }}

You could say it was noticeable.

> The very astute of you might've noticed that the single threaded version took 2 hours less than
> our previous estimate. This was down to two things; some agents just straight up crashing sometimes
> (which was quite funny to find, why was that allowed and handed to us? Did no one test this
> beforehand??) and also many sessions ending before the 10 second time limit. It adds up fast.
>
> You might've also noticed the green line labelled "Safe multi threaded" which was a bit slower
> than the other multi threaded line. I lied to you earlier when I said that this problem was 
> embarrassingly parallel, you see, a variable amount of agents make use of what we call memory;
> they remember their previous sessions and adjust their behavior accordingly. This introduces a 
> _dependency_ in our tournament as for these agents to work properly, we need to make sure their
> sessions happen one at a time. However, very few (or even none) of the agents in the tournament make
> use of this mechanism and as such, parallelizing everything else while all of the matchups of the
> memory dependent agents run on one thread still gives a massive performance boost while maintaining
> correctness. Note that by default the only agent that _can_ implement memory is your own and you
> might choose not to do that so you may have none at all that use memory in the first place.
>
> The point is; blue line very slow, the rest very fast.
>
> Another note: Throughout this post when I mention "Multi-threading" I _really_ mean
> [Multi-_processing_](https://docs.python.org/3/library/multiprocessing.html) as this was in Python
> and the [GIL](https://docs.python.org/3/glossary.html#term-global-interpreter-lock) exists.
> Apologies for the confusion but as you can tell I don't frequent Python :)

But then what's the problem? If it was so easy to do why complain about it? Well why was I the one
that had to make this change?

I (and admittedly my team) are kinda lucky I like optimising stuff (something _no_ course has paid any
attention to, it is worth noting) and I was lucky I decided to take a look at the assignment and really
understand it the day it was published. I did some napkin math to figure out that tournaments would take
forever and I knew I wouldn't be able to stand that much wait time. I thankfully also realized that this
seemed trivial to parallelize and that, it was. 

My issue? This has nothing to do with the course and presumably the vast majority of the rest of the
groups in my class did not have this luxury, forcing them to wait a while longer for good results or
forcing them to severely reduce their agent amount which hurts them with less representative results
Either way, this is bad for no reason.

I just don't get who in the right mind approved this. How do you think this is "good enough"? And funny
thing is, its not just us that have to run this, course staff also has to, either with all the
representative agents + all our own I would imagine. If this was anything more complicated than
literally the simplest parallelization I've ever implemented, I'd understand. You may have needed
some specialized knowledge to achieve it I mean, concurrency can get notoriously tricky. But this
was _trivial_ and I truly mean trivial. Wasting so many hours for everyone and why? Because no one
thought "_you know maybe we should consider for 10 minutes whether we can improve this somehow_".

This is not me complaining because I had to spent time parallelizing this. Quite the opposite, I find 
optimizing things very fun and rewarding, in fact it was the cooler part of the assignment for me. I'm 
purely complaining because I find it unreasonable for the assignment boilerplate to not have this 
already, considering it is completely unrelated to the scope of not only our course but our entire 
bachelor. We were not meant to do this ourselves.

I understand that I did implement it because I am interested in this sort of stuff (performance) and
because I likely have less on my plate. My point is that its the higher ups that are putting stuff
on these plates that should think about things like this more often.

> To be clear, I think having no courses that focus on performance measuring and
> optimization (other than just looking at pure time complexity which we _are_ taught) is a major
> oversight that most university programmes I know fall to.
>
> I think this is a big mistake and that students should know at least some basics to avoid
> situations like this but that is another discussion for another day.

At the time of writing this, the assignment deadline is in half a week and I have so far saved
at least 3 days of runtime from all the tournaments I've ran so far. This will likely be about a
full week's worth of runtime by the end of the week since we have to gather a lot of tournament
data for evaluating our agent and writing a report.

That is _a lot_ of time saved for next to no effort.

After the deadline has passed, I'll attempt to contact the course staff and see if I can get
my parallelization approved and merged into the boilerplate, it would be great if at least the
students taking this class in the future get to benefit from it!

> An update on the last few paragraphs; the deadline of the assignment is now behind me and my new
> estimates about the time saved are around **2 weeks+** now, the last 2-3 days I was practically
> running tournaments non-stop while I was awake.
>
> I've also attempted to contact the course professors about potentially including my optimization
> to the assignment code but have not received a response yet. I'll keep updating this when/if
> that changes in the future.

## The Recent Overwhelming AI Slop Trends

As I sort of alluded to earlier, this is what I really wanted to talk about, not all the stuff
about my assignments that I mentioned above. The assignments helped me really put into words
this general annoyance I had about some of the recent AI trends and some online behavioral
shifts I've been seeing in general.

### A Clarification Regarding Terminology

AI is a very wide and deep field, so much so that it is exceedingly hard for any one person
to have a good, in-depth understanding of all its facets. However, recently the word "AI" has
taken a much more reduced meaning in online conversations as it usually refers to mostly
[generative models](https://en.wikipedia.org/wiki/Generative_artificial_intelligence).
(sometimes abbreviated as GenAI). In the case of text generators, these largely end up referring to
the GPT family of models by OpenAI as for images or videos, there are a few more candidates.

Even though this way of using the term "AI" is as I mentioned wildly reductive, considering how
prevalent it has become over the last few years, I will be using it as such to avoid confusion
with any potentially non-technical readers of this post.

### The Current State of the Internet

I can't help but feel a sense of dread or repulsion, for lack of a better word, when I inevitably
come across AI related content anytime I go online these days. Whether that's low effort text to
speech videos with the same monotone annoying voice or low effort advertising for useless products
or low effort "art work" that always has that glowy mushed look to it and always looks the same or
straight up scam ads made by bots showing fake content/images or sometimes generated videos of
sometimes famous people telling you that you should definitely buy a lot of this new cryptocurrency
because it's about to make you rich or articles that sure include a lot of words for
the exorbitant amount of nothing they actually talk about! 

If you are particularly observant, you might have noticed a subtle reoccurring pattern in the
examples I mentioned.

It all looks the same, feels the same, is largely very low quality and because it requires little to
no effort, is absolutely ***everywhere***.

The kids call this [AI Slop](https://en.wikipedia.org/wiki/AI_slop), and depending on what parts of
the internet you frequent, it may or may not look like it is taking over everything.

And it **sucks**.

Another example of this is the
[Dead Internet Theory](https://en.wikipedia.org/wiki/Dead_Internet_theory); lots of social media
nowadays really does feel like its just bots making generic posts, most of the replies to which
are also random bots writing nonsense. This is so common that there are
[entire accounts](https://archive.is/M551n) dedicated to pointing this out.

#### Why Is It So Prevalent?

Here's a thought experiment; imagine if you will, that you are a journalist. Your day job consists
of writing article for a news website. You need to spend hours researching what you write about,
find an interesting, relevant topic, verify and include sources, structure your text in a way
that makes it easy to read and more things of that nature. 

At the end of it all you end up with an article that the news website you work for takes and posts
on their platform. Since you put all that work in writing it, it is reasonable to expect at least a
handful of people to be intrigued enough by your title to click on it and read it. Which is great!
Now the news website earns its money from the advertisements displayed to the readers and can
afford to pay you. Life is good! You get paid, the website gets paid, and the reader reads something
cool.

Now imagine instead, that you are the owner of the website instead. Writers are expensive and take
time to write articles. What if someone came to you one day and told you that they have developed
this great new amazing tool that can write orders of magnitude more articles, at a fraction of the
time it would take your writers to write them, and it can also do it for cheaper.

You may think to yourself "no way, that's way too good to be true!" but you might also seriously
consider it. And I mean I wouldn't really blame you, sounds like a great deal.

So you try it. 

And oh my god its great.

You are in awe of how it spits out entire articles from very basic instructions. And it looks great
I mean, no typos, no grammatical errors, it even adds its own images and references, sick!

So you start using it. Maybe you even replace your human work force with it, either partially or
fully. You spend less money and post more articles. 

But problems start to appear.

Sometimes your articles are completely incohesive. Sometimes they straight up lie and use fake
citations to back up their claims. Your images look .._weird_.

What is going on?? Well, it _was_ too good to be true. The person selling it to you either _forgot_
or severely undermined its flaws because those aren't good for making sales.

Okay well that sucks but what now? You can't just go back I mean you _are_ making more money! But fear
not, the new version of this tool is coming out soon and it will solve all the previous problems you
have! It will just be a bit more expensive, but it's worth it because it's sizably better and smarter!

You can guess how it goes from here.

### Overhype, Overpromise, Underdeliver

One of my biggest issues with AI in general over the last few years is just how much straight up
lying has been involved in the advertising. Either directly, or indirectly.

Take Devin, the AI software engineer that can code anything, [just look at our
totally real and not faked demo](https://www.youtube.com/watch?v=tNmgmwEtoWE)! It would be so funny
if the company behind Devin was valued at several hundred millions for a fake product that is, at
best, nowhere near as capable as nefariously advertised and, at worst, straight up intentionally
misleading.

Oh what's that? [It is actually valued at 2 billion](https://fortune.com/2024/03/31/cognition-labs-ai-startup-seeks-2-billion-valuation-investor-frenzy-warnings-bubble/)?

Or maybe indirectly. How many times have you heard that "this newer model addresses a lot of the
issues of its predecessor!". Only for newer models to often fall short, or have new issues that make
working with them worse. A recent example is Claude 3.7 which seems to be having a bunch of new
annoying issues that were not present in 3.5 for instance. Another example is Meta being under fire
earlier this week for
[allegedly artificially boosting their benchmarks for Llama 4](https://archive.is/JzONp).

> I see lots of stories like this brought up all the time. Granted, many of them can be deemed as
> anecdotal or unreliable. I encourage you to do your own research on the subject and draw your own
> conclusions, especially if you are a user of these models and their predecessors. You may find
> that they work better for you, in which case great! I do not have personal experiences with the
> claims I brought up earlier in this paragraph as I don't use AI much in programming in the first
> place.

How many times have you heard that "AI will replace programmers by next year", because I've seen a
metric ton of these posts. Often suspiciously coming about right around the launch of some company's
new AI model or product, wonder why that is. And _every_ time without fail, the post-hype results
are underwhelming.

I've lost track of the amount of times I've more or less seen something like the following tweet
by now:

{{ tweet(url="https://twitter.com/d4m1n/status/1905669155090563116", width="300") }}


"AI will replace programmers! Your skills are obsolete, you should buy our product/service instead!".

Every year it feels like this is echoed.

I challenge you to go to your favorite search engine and see how many tweets you can find from each
year, repeating "next year, we will achieve AI singularity for sure this time!" while trying to sell
you something.

I love how every few months you find an incredible startup idea. I remember once seeing a company
built around the idea of letting AI file your taxes.

Bro.

I can't trust AI to write me a short email without hallucinating, and you want me to trust it with
my taxes? I don't understand this at all.

What's even more hilarious is how many of these companies try to get non-technical
people to think they've made their "own" AI model, when they are really just what we call
[wrappers](https://en.wikipedia.org/wiki/Wrapper_function) (services that just call another service
that does the work under the hood) for, more often than not, GPT models.
Programmers understand how little effort is needed to accomplish that, but it turns out that if you
advertise your product to your clients as if you made your own cool model from scratch and they
believe you it makes you look more professional and serious and enterprise-y and that sells!

#### _"What is the Cost of Lies"_

A lot of my problems with how AI is at the moment is how it's presented. It has some _serious_
flaws that can really hurt you if you're not aware and especially careful when using it. I like to
believe that at least the majority of programmers know and understand this, but we are not the only
people that AI is being sold to.

I am constantly shocked and reminded by how many people don't know how easy for current AI models
to just _confidently_
[hallucinate](https://en.wikipedia.org/wiki/Hallucination_(artificial_intelligence)) information
that is just not real.

##### Some Examples

A nice relevant, personal example of this is my dad, who is a Doctor. At some point, he
was writing an article and decided to try throwing it to ChatGPT to see what it would give him back.
He was surprised by how nicely it rewrote some parts of the article, and just as he was about to share
it with someone else for review, he thought of verifying the references the AI had added. They were
hallucinated. Pointing to papers that did not exist, fabricated to support its writing. My dad
has since taken anything that comes out of AI with a grain of salt.

Another personal example is from a discussion I was having with [Luciano Mammino](https://loige.co),
a Senior Software Engineer and author of the WIP
[Crafting Lambda Functions in Rust](https://rust-lambda.com) book. Someone from his discord server
asked for Rust technical interview prep questions and Luciano shared a website he had come across
recently at the time which looked interesting. I remember checking it out myself only to find that
a bunch of the code example it contained were plain invalid and would not even compile. The article
repeated itself many times and even when the code it presented compiled, still often carried errors:

> This is part of a message I sent to Luciano:
>
> _"Theres also a couple of questions where the code that "has a logical error" seems to work and the
> suggested answer is based on something that is not true? A question about palindromes towards the
> end of the page mentions that using `.eq` between 2 iterators
> `is comparing two iterators, not the actual reversed string` but the docs explicitly tell you that
> its an element wise comparison so they \*are\* comparing the actual reversed string. This sounds like
> something java would do instead xd"_

If that all was not enough, at one point the article literally mentioned:
`Sure, here are the remaining four questions:` which sounds exactly like what you'd expect an AI model
to reply to something along the lines of `Give me another 4 questions`. I remember taking a quick
look at their Twitter page and finding out that their last posts was:

{{ tweet(url="https://twitter.com/CoderPad/status/1696288411567501662", width="300", hide_images=true) }}

Just about as ironic as it gets. Just to be clear, this is not at all a dig at Luciano who admitted
that he hadn't taken a proper look at their article. It just goes to show that issues like this
can slip past even experienced engineers and can seriously hurt less experienced ones who might
take them as the ground truth.

#### Ok Enough Examples

My issue is that this should be the norm and not the exception.

It is wildly unethical how hallucinations are not always on the front page of all of these products
and services, considering the amount of damage they can cause. Oh but that would hurt sales we can't
do that. We should lie about it instead or intentionally draw attention away from it which is definitely
not just as bad!

It is very bleak seeing applications of AI that, at its current state, are wildly unsuitable, but
presented ignoring all the potential issues they can cause.

### Accessibility, Effort & Responsibility

Another one of the fundamental issues that I have with AI is how its become synonymous with a lack of
effort and responsibility, often times marketed as accessibility. Allow me to explain.

A lot of the applications of AI that you see online, completely flooding the internet, are things
that allow you to generate content. Create images and art without having to pick up a camera or
a brush, create articles without having to get good at writing, create videos without having to
learn editing or researching or sound mixing, you get the point.

All these are, for the most part, just not as serious or bad as the things I mentioned earlier.

They _are_ however everywhere and ruining the internet.

There's a few problems with them. The most obvious one is the that they come from AI models;
images feel washed away, are blurry or just look impossible; hands with 20 fingers, things
randomly disappearing or getting warped etc. Articles feel hollow and often misleading or wrong.
Videos sound bad, have no cohesive flow to them and just feel horrible and a waste of time to watch.

And another problem: it all just ..feels the same.

The way these models work is they crunch up _a lot_ of data from the internet and then sort of
spit out the most likely results given their inputs. Apart from the obvious flaw being that there
is in fact no "brain" or reasoning really happening and the fact that AI can't learn the same way
humans can, they also spit out "averages".

I don't know about you but the average of anything online is often pretty bad. Statistically speaking,
most of anything can't be "great", that inherently implies that it is better than most other things
in that space. Your mileage might vary depending on what you look at but the average programming
resource for example is often not helpful, or can even be detrimental. Why? Programming is an
immensely complicated field. The same way not everyone that has driven a car can be a good racing
driver, not everyone that has programmed can be good enough to teach it.

This is not me being egotistical about it, that's just life, and that's okay. Everyone that knows me
as a person knows I do not have much of an ego, in fact, I am too often too critical of myself and
more often feel underconfident rather than overconfident.

Even looking at some of my older posts (some of which have even been removed from this
website), I immediately find a lot of things a don't like about them, whether that's about their
content, their style or whatever else. Hell, I could say the same even about some of my more recent
posts. I've written tenths of posts and I'd say I'm _at the moment_ happy with maybe 3-4 of them.

But that's great! It means that I have grown both as a developer (since most my posts are about
software anyway) but also, at least to my eyes, at a writer. 

Being bad is natural and necessary. I don't remember who said this but it has stuck with me for
a long time: "_You never stop being bad, you just get slightly less bad everytime you try_".
There's always improvements to be made and more room to grow.

It is natural to be bad at something but when you let AI be bad for you, you are robbed the
experience of becoming less bad.

What's more is, as I said I am not a fan of most of my posts, I wouldn't call most of them useful.
I wouldn't call them straight up wrong either though and I think those 3-4 posts I mentioned earlier
were actually both really insightful and useful. It's the type of stuff I would've loved to read
before I lived through their lessons and experiences!

Well, when you get AI to write for you, you don't get 10 or 20 meh posts and half a dozen good ones.
You get 500 posts, maybe a third of which contain errors and all of which offer _nothing_ new
because they are a rehash of the AI's training data. Admittedly, this is more so true for text,
rather than other mediums which are harder to define originality for, but still.

Do you see the problem with this? Search engines get so overwhelmed by billions of average posts,
you have a hard time finding anything useful. And it sucks.

We lived through the golden age of information over the last decades and are rapidly ruining so we
can post spam online.

This is such an incredibly short sighted movement I am honestly appalled.

What happens when you use AI to create videos or music or artwork faster? You end up flooding
the search space, overshadowing actual humans that put effort into their work and achieve actually
good results. That's great for you for now I suppose, maybe you make some extra money. What happens
when everyone else figures out that they can also make money for no effort you think. They do the
same. Now the market is flooded so badly, nothing is discoverable anymore, no one can earn anything,
no one can consume anything valuable because there is none of that left and everything looks the same
because it was all designed by AI to look and feel _average_.

The reason I spent so much time talking about this is because what people often say is "but AI is
just a tool! It just makes `x` more accessible!" which I completely disagree with.

There is real value in making things more accessible and I think we should pursue that. In fact
I'd argue that today, everything is the most accessible its ever been! You can
find heaps of information about anything you're interesting in. You have
access to nearly the entirety of _all_ recorded human knowledge through your mobile phone. This is
so easy to understate. Up until just a few years ago, we only had access to the books available at
our local library and we had to wait weeks or even months to talk to someone just a few cities away.
Sports are cheaper to try out for, you can pick up music without even buying an instrument (which
are also way cheaper than they used to be) and you can learn how to edit videos for free on YouTube,
on free editing software. This was all unimaginable a few years ago.

I especially would know something about this, there perhaps is no other professional field as
accessible as programming is right now. Entire university courses are free for you to read through
online, countless tutorials and guides and documentation and tooling that helps you immensely.
There are countless stories of self taught software engineers that did not attend any university
and ended up landing big important jobs.

But at some point you have to sit down and put in some effort.

Programming illustrates this particularly well I think. Programming 40-50 years ago looked very
different than today's; we had programming languages that were a lot harder to work with and of course
way fewer resources that taught you how to use them.

With time and expertise, we started trying to abstract away a lot of the hurdles of those languages
and started creating newer languages & tools with the goal of making them easier to work with, to make
programming easier and more accessible. This of course continues to this day but the original
problems and hurdles we masked are still around. Maybe you don't deal with them as often but it is
often a good idea to know about them as a programmer because sooner or later you'll find one of those
hurdles ahead of you. But the modern languages of today don't make programming trivial. It reduces
the cognitive load on the amount of things we have to pay attention to and keep track of sure but
we still need to _know_ a lot of things to write good software.

That is not how AI works, or at least it is not how I see it mostly pushed and advertised as. AI
is often advertised as this tool that does the work for you, but that's not making anything more
accessible, it is skipping the work all together.

You can't just claim or believe you can do something because you have an AI model doing it for you.
What happens when something inevitably goes wrong? Are you prepared to take responsibility? Because
the AI isn't a person you can blame for its mistakes nor can you fire it in retaliation.

### Vibe Coding

On the topic of coding, recently we've been seeing a wave of
["vibe coding"](https://en.wikipedia.org/wiki/Vibe_coding), the process of coding up entire projects
by only using AI and some of the results of this movement have been hilarious to see in real time.

Wikipedia mentions: "_Vibe coding is claimed by its advocates to allow even amateur programmers to
produce software without the extensive training and skills required for software engineering._"
which is indeed an argument I've often heard people make in favor of vibe coding, and to that I
raise you:

Okay? Why do you want amateur programmers to produce software without extensive training and skills??

Just in the last month or so I've seen multiple vibe coded projects riddled with security
vulnerabilities being discovered, AI deleting someone's entire codebase by accident,
secret keys being made public for others to steal, sites being flooded with spam requests costing
a fortune in server bills, unmaintainable & incomprehensible code, stupid performance bottlenecks
the list goes on and on.

All of these caused by ignorance, because these people just did not know any better and because AI
allowed them to produce software without any training or effort or understanding of how it works or
what it does.

Would some of that had happened anyway? Of course. People make mistakes, vulnerabilities and bugs
exist, but not this many, this quickly, at commercial, paid software with customers involved. A lot
of these mistakes I mentioned above were extremely amateurish, some could even be criminal considering
these were in commercial products. Who bears the consequences and responsibility?

Let me put it differently, in a way more people should be able to relate to. You can ask AI to
diagnose and consult it for your health problems. Say I come to you, and present myself as a doctor
that relies on AI for my diagnoses. I hope no one would be comfortable putting their lives on the
imaginary hands of a glorified random number generator! Then why is it that people are so
comfortable putting their software and digital lives on the hands of AI? People often forget how
much of our modern world depends on software and are all too comfortable and eager to submit
their payment details on websites that are coded by AI apparently, let's hope that those don't
contain giant security holes that allows hackers to trivially steal critical personal information!

Why are we monetizing mediocrity with the added risk of being often wrong combined with
lack of responsibility. Doesn't sound too appealing I'll be honest.

I am not going to sit here and tell you that you should avoid AI like the plague and that you should
never ever dare to touch it. I've used AI to help me write code, but I already know enough programming
to be able to reliably verify that what the AI programs is correct, which is why I've only used it
for easy, verifiable and unimportant tasks that I _kind of_ know how to do already but may not
remember the specifics off the top of my head. A common such example for me is using AI to help me
create plots in Python for myself; they're easy in the sense that the code is short and readable
and its not my first time making plots, I know what the code and the plot itself should look like
so I can quickly tell if something is wrong. I use it more so like a tailored search engine
(that is sometimes a bit wrong) than an assistant. An important detail is that I don't really care
about Python plots much as they are not something I need to do often (hence is why I forget the
specifics about them) which is great because everytime I've used AI to help me make one, I've
completely erased its code from my memory mere hours later. I just don't see how people believe
anyone can learn anything by letting AI do all the work for them, that's not how "tools" work.

## Where does AI go from here?

From the quite limited and largely superficial and surface-level knowledge I have on the field,
I would imagine that AI won't go far as it is now and needs radical architectural changes for it to
seriously improve.

Thankfully you don't have to take my word for it.

[Professor Yann LeCun](https://en.wikipedia.org/wiki/Yann_LeCun), widely considered one of the
fathers of Deep Learning as a whole,
[recently said](https://youtu.be/xnFmnU0Pp-8?si=InCRV38gyZOOLLKu&t=380):

"_Auto-Regressive LLMs are doomed. They cannot be made factual [...]. They are not controllable. [...]
It's not fixable without a major redesign_".

> This whole talk seems to be quite interesting. I haven't hard the time to watch it in its entirety
> just yet but it is in my backlog and I'd definitely suggest anyone reading this to take a look!

What I am seeing in my own personal experiences is a lot of these models steadily plateauing and
falling deep into very diminishing returns. I think the only somewhat substantial improvements
we've seen recently (at least from the perspective of users) have been larger context windows
which you should take with a grain of salt as many people seem to not be too satisfied with
Llama 4's performance for instance, even though it has industry-leading context window of up to 10
million tokens. And I guess some of the AI generated images look a bit better? Sometimes?

When it comes to programming (and text generation in general), we still get a lot of hallucinations
and honestly the quality really does not feel like it has improved much in the last few years though
that might just be me.

I'm cautious about making such remarks about things I don't have a very in-depth knowledge of but I
really can't help but think that there is not a whole lot left in terms of quality improvements of
LLMs. We might get entirely new architectures that completely bypass these problems and truly
revolutionize things like programming, but today we are just not there (or maybe even near anything
like that) just yet in my opinion.

It is rather hard to talk about generative AI and its future without mentioning the elephant in the
room: its legality and ethical concerns.

I think we'll see more legal action taken against the companies behind these models regarding what
they included in their training data and how they obtained it and I'm honestly a bit surprised so
many businesses seem to not be concerned with that? If courts end up ruling that code generated
by AI, trained on say [Copyleft licensed](https://en.wikipedia.org/wiki/Copyleft) code, are considered
to produce code that should be licensed accordingly, then what? I know that's rather unlikely to
happen but its a bit question mark that I wouldn't take too lightly too soon.

I understand that saying "but muh ethics!" when dealing with large corporations that don't shy away
from the occasional human rights violation is rather naive but I can't just not mention the ethical
questions AI like this raises. 

Let us all remember that no explicit consent was given to these companies to train their models on
open source code and no attributions were given either. It can be argued that these companies
infringed on the copyrights of programmers by plagiarizing their code.

Of course, code is one thing, training on text or art is also very dubious.

## Where do _We_ go from here?

When it comes to the aforementioned impact of AI in the general internet, unfortunately there is not
a whole lot we can do (well except for advocating against spamming AI generated content on every
platform). One thing that has noticeably improved my experience of browsing online has been the use
of browser extensions such as [Control Panel for Twitter], [uBlock origin] with [this block-list],
[Unhook] for YouTube and probably some more + my browser's built in Ad block. Some of these of course
are for advertisements in general and not specifically for AI but considering how many AI generated
advertisements I get, they help a bunch. Control Panel for Twitter helps a lot with limiting the
amount of bots I see on that platform so there's that.

Of course all this is more like putting a band aid on the underlying issue or even looking the other
way rather than tackling it directly but other than that I'm not sure what else can be done.
Raising awareness definitely helps. I think a lot of the people using AI for generating content
are either not fully aware of its shortcomings or haven't thought about how that affects searchability
for instance (or both). I would like to think that the majority of people doing this are not doing
it because its a shortcut to making a bit more money because that is definitely not sustainable 😅

When it comes to using it for things like programming, my opinion is very simple;

Programming is a skill, and unused skills, like muscles, atrophy.

AI just does _too_ much too often for you and I think you'll simply forget a lot of small things
here and there, ultimately growing yourself overly dependent on AI to program. Again, I've already
noticed this with myself and Python plotting which is why I don't want to use AI for anything more
common (for me) or important than that.

The problem with over-reliance on huge tools like that is simple; you don't have any control over
them. Of course that's true with many platforms we programmers use, what about Github or cloud
services or Jira? Well, vendor lock-in _is_ a real problem, but in the above examples you _can_
in many cases side step it. 

Github just stops existing? Well your code is just a git repository, you can "just" push it to another
platform.

Your cloud platform of choice just stops existing? If you are a small-medium sized company that
deliberately tried relying more on open source tools that exist on more or less all cloud platforms
(say Dockerizing your app or using PostgreSQL instead of vendor specific alternatives), then you
can maybe also switch though that sounds exponentially more painful, if at all feasible in practice. 

> I think in this last paragraph specifically you can tell I have no professional experience because
> I have no clue how common or even possible it is to "_just use open source tools instead of
> the overly convenient and potentially cheaper vendor specific offerings bro_" idea.
>
> I suspect that is just not practical for a lot of companies, just thinking about how convenient
> and cheap something like AWS Lambda is compared to permanently running a VPS almost invalidates
> my entire point.
>
> ***However***, I do think that if someone is determined to do that at all costs, they definitely
> can. A good example of this is [StackOverflow running entirely on prem].
>
> Is it for everyone? No. Is it possible? Yes. Is it retroactively possible? Realistically no unless
> you've made most architectural decisions in support of this already.

"_But there are many open source models we can self host, what's the difference?_"

Truthfully, it depends on the cost (and quality of the open models though that seems to be very
much okay from what I've seen which is incredible!) of running these models. Running one or a few
instances of a database for your entire business is one thing but I don't know how well these LLMs
scale with the amount of employees; is it realistic to have 1 machine hosting an LLM with multiple
developers accessing it at the same time or would that be slow and you'd need more? I have not done
my research on this and can't answer that, I just know you need some very beefy machines to host the
full versions of these models and if you need one such machine every two-three employees that would
get very expensive. Then again you might need 1 such machine for like 100 employees and this entire
argument falls apart, I don't know do your own research {{ shrug() }}

It is just worth to keep in mind that a lot of the advantages of AI in programming is based around
them being fast and specifically faster than humans, if hosting them affordably means waiting for
outputs for a while, it might not be that worth it in the end, just a money sink.

Also, all this assumes your company is on board with using AI in the first place. I admittedly do not
know about any companies banning use of AI for their software development but I can definitely see
companies refusing to buy enterprise licenses in order to use such AI models because companies just
do that sometimes. Would suck to be over-reliant on AI and then end up in such a company.

Jira just stops existing? That's fine.

Also, this might sound a bit silly but like, programming is fun. I like software development. I
want to do software development, I don't want AI to do it for me so it can be done faster, that's no
fun.

## Closing

This entire post has really made me feel like this:

{{ image(src="/img/low-effort-everything/Old_Man_Yells_at_cloud_cover.webp",style="max-width:80%") }}

In hindsight much of this post must've sounded quite absolute which is not really how I am in face
to face discussions with people but this is my own echo chamber so its harder to keep it well
rounded. _Also I just wanted to complain and not much sense goes in that usually_.

I think some of it was honestly borderline unreasonable. Like hm why do people not just
do more work. Because they're lazy, its human. I think the only way to "fix" this is by
changing what we consider "good enough". Then more work and effort will follow naturally.

When it comes to the writing itself, how do people manage to write entire books??? This post was
~9k words and I was already quite overwhelmed with remembering everything and re-reading it to
make sure it had at least _some_ cohesion going for it. I think paying more attention into how I
break the whole text down into more digestible units would help a lot, which is a good thing to
realize now because I will have to write a paper for my Bachelor thesis in ~2 months from now!

On a bit of a side-note, I want to try and cite things where appropriate in my posts. I recently
found [Dr. Tratt's blog] (specifically [this post] was really insightful) and he does that a lot
in his writing which I quite liked. I already make use of hyperlinks so I'll have to figure out
when it makes sense to use which (or if it even makes sense to blend them?).

But let's start now (more-so because I want to make sure my CSS works properly). My first ever
official citation shall be "AI is ruining the internet" by Drew Gooden[^1], which I have probably
re-watched 5 or so times already. It talks about a lot of the things that I already mentioned but
offers a different perspective (namely more from an artistic background rather than a programmer's)
which I think is interesting to look at (also the video is pretty funny).

All in all, I am more or less glad with how this post turned out, although I think this might just be
a one-of, I do like writing about software more than complaining anyway. Though I have to admit
that with all the stress from the last 1-2 months, it was neat to vent for a while.

This post was in fact so much longer and harder to keep track of than my previous one that I
ended up improving my workflow with some new checks, which I'll probably write about in my next
(probably very short) post, after I ideally add them all to my CI as well.

In any case, till next time!

[Control Panel for Twitter]: https://github.com/insin/control-panel-for-twitter
[uBlock origin]: https://github.com/gorhill/uBlock
[this block-list]: https://github.com/laylavish/uBlockOrigin-HUGE-AI-Blocklist
[Unhook]: https://unhook.app
[StackOverflow running entirely on prem]: https://stackexchange.com/performance
[Dr. Tratt's blog]: https://tratt.net/laurie/
[this post]: https://tratt.net/laurie/blog/2025/the_fifth_kind_of_optimisation.html

## Footnotes

[^1]: [AI is ruining the internet (video)](https://www.youtube.com/watch?v=UShsgCOzER4)