---
title: "Aim for the stars"
description: "Shooting the Andromeda Galaxy"
keywords: ["andromeda", "galaxy", "astro", "astrophotography", "deep", "sky", "photography", "galaxy"]
date: 2024-08-14T18:24:14+03:00
draft: false
taxonomies:
  tags: ["Astrophotography", "Photography"]
extra:
  og_image: "/img/aim-for-the-stars/thumbnail.png"
---

## I Take Photos Actually

I've been into photography for some time now and I've quite liked both astrophotography and
deep-sky photography. Somewhat recently I bought a
[105mm macro lens](https://www.sigmaphoto.com/105mm-f2-8-ex-dg-os-hsm-macro) (for some reason
this is now more expensive than when I bought it??). While I was studying in the Netherlands,
I didn't have too much time to dedicate purely to photography so I would shoot something here
and there but nothing major.

Astro was out of the question both because of the horrible light pollution the entire country
has but also because it is not something you just randomly decide to show up and do; shooting
anything at night needs a good amount of planning as well as a good amount of shooting if you want
a half decent result, even for the simple stuff I was doing. I also didn't have a driver's license
at the time which is arguably indispensable for this sort of thing.

> TLDR: I had never tried shooting at night with this lens. 

Even though I really loved shooting with
it during the day, because of the long focal length, when I was walking around (and couldn't use
a tripod), I would start to struggle to get clean pictures from sunset already because of the lack
of sufficient light.

Seeing as how I was back home in Greece for the summer and a [Perseid Meteor Shower] was taking
place, the entire family decided to drive somewhere remote at night and spend an hour or so
star gazing. This was just about the perfect opportunity for me to try out the new lens at night.

Throughout this post, I'll go over all the preparation and learning I had to do to take my
first deep-sky photograph using just a lens I had, as well as how I processed it to improve it.
I'll also talk about a bunch of adjacent stuff as one does.

## First Night

On the first night, I was not really aiming for anything specific. The plan was to get a feel
for what settings worked (ISO, exposure times, aperture etc) and to get something along the lines
of "cool mountain but with stars". It was at this point that I was about to find out just how much
more apparent the rotation of the Earth is in my 105mm lens compared to the 55mm lens that came with
my camera. Before, I did not really have to care much, shooting at 20-30s would add a bit
of star trails but not too much. I didn't have an intervalometer at the time so that's as high as I
could go anyway.

I ended up with this: 

{{ image(src="/img/aim-for-the-stars/_DSC0156_copy.JPG") }}

This shot was having an identity crisis (well it was for testing purposes so can't blame me too
much I guess). I was trying to do terrain+stars+trails and the combination was just not working.
I was shooting too short for nice trails, just enough for the terrain itself but more importantly
I was just now realizing how "zoomed in" and somewhat uncomfortable this lens was to get what I was
very vaguely aiming for.

> Do not ask me why I was vaguely aiming for a wide angle shot with a 105mm lens

I shot a few more stuff that was not really of note until eventually I just said "whatever man,
what if I shot for like 15 minutes lol" and ended up with this

{{ image(src="/img/aim-for-the-stars/_DSC0163.JPG") }}

which again is not fantastic, however, it looks kinda cool.

It is also easy to notice that the star trails (albeit being incredibly cool), have a lot of jitter.
It was quite windy that day and my tripod is quite cheap so that didn't work out too well.

But this got me thinking, well, how *do* people take such nice pictures of the night sky if I can
barely shoot a mountain and like 7 stars.

## Research Time

Well as it turns out, it's just hard to shoot very long exposures for the 2 reasons I had already
realized: the Earth's rotation will blur out the stars or give them trails and the longer you shoot,
the chances that your tripod keeps the camera perfectly still dwindle. There are 2 ways to combat
these issues and ideally you want to use both in conjunction;

### Image Stacking

The first (and cheaper) option is a technique called image stacking. The idea is simple: instead
of shooting one long exposure, shoot multiple short ones and blend them together into one image.
This eliminates both the star trail issue as well as greatly reduces ISO noise since you can just
use a smaller ISO.

Well the "just blend them together" is doing a lot of heavy lifting. You could technically do this
yourself in Photoshop but you should probably use an image stacking software such as
[Deep sky stacker]. There are probably different ones you could use but this is the first one I found,
it works and it is free and open-source.

Software like this (to my current knowledge) effectively does 2 things;

- Aligns all your images with each other using bright stars as anchor points
- By blending and averaging out the light between the different pictures, it greatly reduces
  the noise (which is by nature inconsistent and thus gets averaged out) and amplifies the star's
  lights which are consistent. It is sort of the same principle that makes long-exposure photos 
  "ignore" movement and only register constant (or really bright, think car headlights) objects.

This does come with some hurdles. For one, you need to make sure whatever it is you are shooting
is *always* centered, the Earth's movement is still an issue, we just pushed it further back.
It is a good idea to make sure your subject is centered every few minutes, in my case I checked
every 3 or so minutes but this will depend on both your focal length (the longer your FL the more
frequently you'll need to recenter) and how much of your frame your subject occupies.

In my case, 105mm was nowhere near enough to properly zoom in on the Andromeda Galaxy so since I
knew I was going to crop the result anyway, I could afford to recenter my camera less frequently.

The Andromeda Galaxy is that vaguely brighter spec of light near the center of this image:

{{ image(src="/img/aim-for-the-stars/_DSC0180.png") }}

Considering that it is apparently estimated to be roughly 23605433496791683000 kilometers away
(give or take some rounding error), it is insane that I can even see it with just my lens!

Another "issue" with image stacking is just how many photos you need. In my case I shot

- 212 light frames
- 40 dark frames
- 30 flat frames
- 50 bias frames

for a whopping total of 332 photos which amounts to 4+ GB. I will not claim to know how many of any
of these frame types are "good" but the guides and articles I read beforehand usually shot more
than me, I was just constrained on time, it took almost an hour to get all of these.

But what are all those "frames"?

Light frames are your "normal" pictures where you want to capture your subject with your camera
sensor.

The rest are...

#### Calibration Frames

Calibration Frames are pictures you take to average out different types of noise your light frames
will have in order to end up with a cleaner picture.

Dark frames are meant to remove thermal noise which is affected by temperature, ISO and your
exposure time. The way you take these is just after you are done with your light frames, you
just put the cover cap on your lens and start shooting without changing the settings. It is
important to take these on-site and right after you are done shooting your light frames as your
camera settings and environment affect some of the calibration frames so it is important to capture
*how* they are affected as your light frames will have the same issues.

Flat frames are shot in Aperture mode and should be properly exposed. You remove the lens cap and
cover up your lens with something white (maybe a shirt). These capture things like dust particles
on the lens as well as [vignetting].

Finally, we have the bias frames. These are shot at the lowest shutter speed your camera can handle
and tackle the inherent sensor bias that cameras have (no sensor is perfect!).

### Star Trackers

While stacking works great, it is not always enough, especially if you want to use high focal
lengths (such as with telescopes). The problem as mentioned earlier is that you need to shoot
short exposures in order to not get star trails. The issue with that is that this severely limits
the amount of detail you can capture. Things like fainter stars and all their different colors
just do not pop out well enough without longer exposures.

So what is a star tracker?

It is *an expensive* piece of equipment that sits between your tripod and your camera and slowly
moves your camera to counteract the rotation of the Earth, allowing you to shoot longer exposures
without any issues. Some star trackers can apparently also point your camera to any celestial body
you want automatically which sounds pretty useful as we'll see later.

I do not have one of these unfortunately so I can't comment a whole lot on them but if you are
interested in deep sky photography (especially with a telescope, this is a must), it sounds like
a worthy purchase if you can afford it.

### Camera Settings

I have to once again mention that my combined experience in deep sky photography is one (1) picture.
These might not be optimal, but they are what I used to get going.

To get my shutter speed I used what is referred to as "the 500 rule". This states that your
exposure time (in seconds) should be the result of `500 / (Crop-Factor x Focal Length)`

My Nikon D5000 has a crop factor of `1.52` and since my lens is `105mm` my exposure time is
`500 / (1.52 x 105) = ~3.1s` which I rounded down to 3 seconds. I used
[this site](https://www.digicamdb.com/specs/nikon_d5000/) to find my crop factor.

Some people prefer using the same formula but instead of `500` they use `400` or `300`. I did not
try either of those out but seeing as how both of them result in shorter exposure times, I wanted
to avoid them in order to get some more detail in my images + even at 3 seconds I did not get
blurred results so that is good enough for me. There's also another heuristic called the NPF rule
but that one is more complicated to compute and I am lazy so I decided to not go for that.

When it comes to the ISO, I couldn't really find anything specific. Many people seem to recommend
something in the range of `1600-3200`, I think I ended up with something in the middle.

Finally your Aperture. This one is an interesting balancing act. Shooting wide open obviously lets
more light and consequently more details reach the sensor which is great, however, this also often
results in [vignetting] so it might be a good idea to not shoot completely wide open. But then again,
if you increase the aperture you need more light so you need to shoot for longer and that can cause
its own problems as discussed previously. In my case I was lucky because I knew I was going to crop
my image pretty heavily so I could just not care about vignetting since I would crop that out anyway.

Another thing I saw some people mention is that disabling your camera's either nighttime or long
exposure noise reduction is a good idea. I would imagine that is because you will do your own
noise reduction with image stacking and later on in post but also because it takes a while for
your camera to process said noise reduction.

Your ideal white balance setting might vary depending on things like the intensity of light
pollution and its warmth. In my case, a daylight WB worked nicely enough.

## Preparing for the Shot

Probably the first thing to look at when it comes to planning is light pollution, both from things
like cities but also from the moon. I found [this neat website](https://www.lightpollutionmap.info)
that puts light pollution estimates on a map so you can more easily find the darkest areas near you.
I also used [this website](https://www.timeanddate.com/) for both finding the Moon phases as well as 
when night starts.

> When the sun sets, even though we cannot see it directly it still illuminates the sky for a while
> after it's gone. There are 3 types of "twilight" between the sunset and night, each designate
> a different level of "darkness" which is just the degrees the sun is at below the horizon. In
> order of most bright to least bright those are Civil, Nautical and Astronomical twilight.
>
> I would imagine that Astronomical twilight is good enough for 99% of people (nautical might also
> be good enough to be honest) but I prefer shooting at Night since I know I won't have to adjust
> my settings at any point as it can't get any darker than that. Night seems to start just over
> 90 minutes after sunset in my case.

At this point, you probably want to get your camera focused. This sounds deceptively trivial at
first but the first few times you try it might be a bit harder than you'd expect. The issue is that
autofocus cannot work and you should thus disable that and use manual focus instead. Try and find
a bright star, point your camera at it and turn on the camera's live view or whatever it is called.
Zoom into the star as much as your camera allows you to (usually this is a 10x zoom and yes I am
talking about a digital zoom, not optical zoom) and try and adjust your focus so the star appears as
small as possible. After you've done that, be very careful to not mess up your focus accidentally.

Now that you've focused on something that is not your subject, it is time to try and find the
actual subject which can also be surprisingly difficult, at least the first few times. I definitely
recommend using something like [Stellarium] (or something similar, this is again free) on your phone
to at least get a sense of the general direction of whatever it is you are trying to shoot.
Searching for "Andromeda galaxy" in the app shows the following:

{{ image(src="/img/aim-for-the-stars/stellarium.jpg") }}

Well the underlines I added myself, I'll come back to them in half a paragraph. The actual "galaxy"
is that ellipsis titled `M 31` where the `M` stands for `Messier` which likely has some significance
and historical attribution I am unaware of so just pretend that says "Andromeda Galaxy" instead.
Believe it or not, it is nearly impossible to spot with the naked eye, even at night and with
near-zero light pollution. How do we find it then? Well, the 3 stars I underlined in red were
really bright and were very easy to spot. It was not too hard to aim my camera in the middle one,
named "Mirach". The star above that, which I underlined in green, was super faint but visible with
the naked eye so I could see the general direction I had to aim to start seeing the Andromeda Galaxy.
After taking a bunch of 10 or so second exposures *just to aim my camera at an entire galaxy*, I
eventually managed to do just that. I would imagine that this is quite common unless you have one
of those fancy and expensive motorized stands that can aim your camera for you.

## Taking the Shot(s)

Now time to shoot a few hundred photos and unless you want to do that by hand, you should buy an
intervalometer. These are dirt cheap devices you can connect to your camera and they essentially
control the shutter. If you want to do things like shooting exposures longer than 30 seconds or
shooting many pictures *at intervals* then this is a must-have tool. Make sure your camera's shutter
speed is set to `bulb`, pick the ISO you want and you can finally start shooting. In my case I shot
50 3-second exposures with some added time between shots (like 4-5 seconds from what I remember) to
make sure my camera could keep up. This was around 5-6 minutes, at which point I had to stop and
adjust my camera because the galaxy was on its way to escape my frame. I took 4 sets of these.

Don't forget to also take your calibration frames at this point. Also, something to keep in mind is
just how much space this can take up on your SD card, in my case I had just over 4GB of photos taken
just for this.

## Post Processing

Now that we've shot everything it is time to finally put it all together.

[Deep sky stacker] is quite straightforward to use so I won't touch too much on that; you just
select your images, assign them into the correct category (light frames, bias frames etc) and let
it do its thing. In the end you will end up with something that looks shockingly uneventful:

{{ image(src="/img/aim-for-the-stars/Stacked.png") }}

I spent all this time and effort just to get this???

Fear not, for it *should* look something like that at this stage. You can just about make out that
there even is a galaxy present in the picture and from what I've read, even that might not be
obvious in some cases.

It is time to throw that into Photoshop and do magic on it to make it look better. I can simply not
stretch enough just how daunting this has sounded to me for years. Now don't get me wrong, it still
sounds daunting and I still don't know what I'm doing ***but***, making a photo like the one above
look somewhat cool is actually not quite as hard as it at least felt like it would be to me.

> I pretty much found out about all the things I am about to talk about through these 2 videos,
> definitely give them a watch if you're interested!
>
> - [3 EASY ASTROPHOTOGRAPHY Targets for Beginners!](https://www.youtube.com/watch?v=KHaELP7__7M)
> - [Shooting & Processing Orion Nebula with a DSLR and Tripod, NO TRACKER - Astrophotography Tutorial](https://www.youtube.com/watch?v=bDqrW8cLEx8)

The main goal of the edits we are about to do is to broaden the spectrum of light captured in the
photo. There's a good chance that the starting image is quite "rough" in that regard i.e. it goes
from full black to white with not much in-between. By broadening the *in-between*, we increase
the contrast of all the different colors we captured. You don't want to overdo this however as that
will end up reducing the contrast between the pitch black sky and your subject.

Here's a before and after of what that might look like:

{{ image(src="/img/aim-for-the-stars/levels_before.jpg") }}
{{ image(src="/img/aim-for-the-stars/levels_after.jpg") }}

In my case, I think the before was a bit too extreme and I *think* that is because I could not
expose for too long, although I am not entirely sure, that might just be normal for a starting
point.

We do this via the `Levels` menu which you can access via `CTRL+L`. We pretty much try to pull
the left and right borders closer to our peak, effectively stretching it.

Another similar modification involves the dreaded curves which you can access with `CTRL+M`. These
always seemed so cryptic but they're actually not *that* bad. We again aim to increase the contrast
except this time we want to do that on specific areas of our image. By `CTRL`-clicking on areas of
our image that are faint but we know should have more color, we get a point on our curves that
represent those colors. What we can now do is lift the curve around that area to increase the
brightness of those colors and lower it on the other end of the histogram to, again, increase
contrast. This really makes some areas pop.

Here's how that might look like with a before and after:

{{ image(src="/img/aim-for-the-stars/curve_before.jpg") }}
{{ image(src="/img/aim-for-the-stars/curve_after.jpg") }}

There are also a bunch of other things that we can do such as noise reduction filters, increasing
certain colors, upping saturation and vibrancy etc but generally speaking those are a lot more straightforward. 

In the end, after all this stuff and post, I ended up with this!

{{ image(src="/img/aim-for-the-stars/edit.png") }}

I think it looks quite cool for a first attempt.

I am not entirely sure what I can improve just yet. Just shooting more light frames is probably
an easy one to point out. I'm also sure that I can improve my post-processing tremendously but not
sure how just yet so I guess I'll have to experiment a bunch with that to see what works as well
as go through some guides probably.

However, that said, this brings us to...

## Equipment Matters

Purchasing often expensive equipment is very common for anyone who has been into photography for a
while, but I do think that deep-sky photography has both one of the largest selections of gear you
can buy as well as requires that you buy a bunch of things if you want to get nice pictures in the
first place. There are very few things that you can't shoot well enough (at least at a beginner
level) with just your average 55-65mm lenses that often come bundled with your camera. Sure there
are some things that will be better with a lower or higher focal length, say 20-30 or around 100.
But those all have relatively cheap options, at least for photography standards. Not to mention they
are all quite common, which means you can find used lenses if that's more your thing.

But for deep sky photography, you kinda need a telescope to get really cool pictures. And the issue
is that that's a very specialized purchase. For example, I love my 105mm lens; I've shot neat
pictures of cars, buildings, even portraits and scenery which are traditionally shot on wide-angle
lenses. It is a much more general piece of equipment, at roughly the same price as a telescope
which does 1 thing only. And of course, once you get a telescope you really should also get a star
tracker because finding your subjects would be exponentially harder at those focal lengths and
you wouldn't want to shoot without compensating for the rotation of the Earth either.

My point with all this is that you should meter your expectations if this is something that you
want to try out, without throwing a bunch of money at it. You can definitely shoot some cool stuff
but expecting to get something like those wallpapers you see on the internet is rather unreasonable.

THAT SAID, I must stress that I am talking about *deep-sky* photography. If you want to shoot
things like the Milky Way or just the stars, you can 100% do that with most lenses. Wide angles
could be better but not required.

## Other Possible Sky Subjects

I couldn't really fit these in in any other paragraph so I'll just give them their own.

Some common subjects that I've seen mentioned are the [Orion Nebula], the [Pleiades Star Cluster]
(which I will actually try and shoot tonight!) and the [Rosette Nebula].

There's also this thing called [The Messier Catalog of Deep Sky Objects] which is a list of 110
deep-sky objects. You can sort these by ascending [Apparent Magnitude] which, the lower that is, the
easier it should be to take pictures of.

## Closing

Overall, I'm quite happy with all the things I learned and just the overall experience of taking the
picture. It might not be of *stellar quality* (sorry) but when has that ever the case in a first
attempt? It is also kinda interesting to put into perspective just how much work is really needed
to get such a picture. I can only imagine the amount of effort some of the pictures I've seen
online must have needed.

This was quite a lengthy post (also the first one I've done that is not programming-related) but it
was interesting to write nonetheless. If I do get a neat picture of the Pleiades tonight, I'll be
sure to add it here!

And with that,
Till next time!

[Perseid Meteor Shower]: https://science.nasa.gov/solar-system/meteors-meteorites/perseids/
[Deep sky stacker]: http://deepskystacker.free.fr/english/index.html
[vignetting]: https://en.wikipedia.org/wiki/Vignetting
[Stellarium]: https://www.stellarium-labs.com/stellarium-mobile-plus/
[Orion Nebula]: https://en.wikipedia.org/wiki/Orion_Nebula
[Pleiades Star Cluster]: https://en.wikipedia.org/wiki/Pleiades
[Rosette Nebula]: https://en.wikipedia.org/wiki/Rosette_Nebula
[The Messier Catalog of Deep Sky Objects]: https://en.wikipedia.org/wiki/Messier_object
[Apparent Magnitude]: https://en.wikipedia.org/wiki/Apparent_magnitude
