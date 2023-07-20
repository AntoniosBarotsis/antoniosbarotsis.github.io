---
title: "Zip it and ship it!"
description: "How I published a CLI tool in Chocolatey and Nuget."
keywords: ["Deployment", "GitHub Actions", "CD"]
date: 2022-02-01T19:05:19+02:00
draft: false
taxonomies:
  tags: ["Coding", "Csharp", "Deployment"]
---

# Introduction

I recently started working on a command line tool that uses git hooks to remind you to run your
tests and builds before pushing your code among other stuff and I decided to package that and
publish it so anyone could use it. The project itself is nothing too impressive or innovative
so in this post I will be mostly focusing on the packaging and publication process rather than
the project itself but in case you are interested in checking it out, click 
[here](https://github.com/AntoniosBarotsis/Rember) and go make some issues :)

I'll be explaining how I published said package and how to make a Github Actions CD workflow
to publish your new releases automatically.

## Why

I feel like most if not all developers find the idea of making their work available for anyone
to check out and use an exciting one and I definitely relate to that. I personally really like
working on things that can be used by other developers specifically and that's the main reasons
why I started this project and why I decided to make it easily accessible to anyone (unless 
you are not on windows because I was too lazy to check how that would work). 

I decided early on that I wanted to publish my code on 2 platforms; the package manager of my
language of choice (in this case, NuGet) and a more general purpose package manager like
[Chocolatey](https://chocolatey.org/) so that my audience would not be limited to developers
from my tech stack only.

## What did I build exactly

The project was built using C# mostly because of [this](https://www.youtube.com/watch?v=JNDgcBDZPkU)
video I came across (great YouTuber by the way, make sure to check his channel out for C# content). TLDR; C#
has this thing called [dotnet tools](https://docs.microsoft.com/en-us/dotnet/core/tools/global-tools) which
are essentially command line applications that are very easy to make and package. The linked video walks you
through creating one from scratch. 

## Uploading to NuGet

### Preparing

Once you have your CLI tool up and running there's only that many steps left to push it to NuGet.

The mentioned video already guides you through adding most of the stuff that you need in your `.csproj`
file but here's a few more things you might want to add:

- A README file

  If you want your NuGet package to display the README file you spent hours filling with meaningless
  badges, this is for you. All you have to do is add the following:

  ```xml
  <PropertyGroup>
    ...
    <PackageReadmeFile>README.md</PackageReadmeFile>
  </PropertyGroup>

  <ItemGroup>
    <None Include="../README.md" Pack="true" PackagePath="\" />
  </ItemGroup>
  ```

  This tells NuGet to use our `README.md` file as the package README file but for that to work we must
  make sure that this is packaged into our `nupkg` file. This might be different in your project but
  my project has a separate folder for the actual code instead of it also being in the root of the project

  ```txt
  │   README.md
  │   Rember.sln
  │
  ├───publish
  │       Rember
  │       Rember.exe
  │
  ├───Rember
  │   │   Rember.csproj
  ```

  Because of that, my `Include` parameter goes a directory up to reference the README file.

- Other useful tags might include `RepositoryUrl` to link your Github repo and `PackageTags`
  to provide a list of space-delimited tags for your package.

- I do also recommend specifying the `RuntimeIdentifier` to something like `win-x64` although from
  what I understand this is not necessary but better safe than sorry!

### Pushing the Package

That pretty much concludes the needed preparations for NuGet so time to actually push the thing.

Run `dotnet pack` and you should get something along the lines of `Successfully created package
'path/to/package.nupkg'`.

Next you want to grab yourself a NuGet API Key from [here](https://www.nuget.org/account/apikeys)
and run the following command:

```bash
dotnet nuget push path/to/package.nupkg \
  --api-key <API_KEY> \
  --source https://api.nuget.org/v3/index.json
```

If all goes well your package will be soon available on NuGet! Wasn't that simple?

## Uploading to Chocolatey

### Preparing

Chocolatey requires you to provide a so called `nuspec` file which essentially provides some details
for your package. I personally found their [docs](https://docs.chocolatey.org/en-us/create/create-packages#nuspec)
a bit confusing so if you get confused perhaps looking over at my repository could help you out more after you've
read through them.

You will see that most of the stuff we specify are essentially the same as what we specified earlier for NuGet.
Only thing to note here is that you want to make sure that everything your package needs ends up in the `tools`
folder.

### Compiling

Uploading to Choco is a little more complicated. First of all, we need to compile our code to a single
file that has everything it needs to run bundled inside of it aka, a self contained file. It is also a
good idea to try and remove anything that is not used in terms of libraries considering how much larger
this file is going to be compared to the `nupkg` file we created earlier. Take a look at the docs for
[dotnet publish](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-publish) but TLDR; our command
will look something like this:

```bash
dotnet publish -o tools \
  --self-contained True \
  /property:PublishTrimmed=True \
  /property:PublishSingleFile=True
```

The reason why I specify these properties in the arguments of the command instead of in the `csproj`
file is because I would have to keep toggling them on and off depending on whether I was
targetting NuGet or Choco.

I also specify the following in the `csproj` file to hopefully cut the executable file size down a
bit more:

```xml
<DebugType>none</DebugType>
<DebugSymbols>false</DebugSymbols>
<Configuration>release</Configuration>
```

This should create a `.exe` file in the `tools` folder.

### Pushing to Chocolatey

We are almost done! We now only need to run the following:

```bash
choco pack
choco push --api-key=<API KEY>
```

Your API key can be found [here](https://community.chocolatey.org/account) and I do not know why
navigating to your profile page is so hard on their website.

Publications on Chocolatey take way longer than NuGet (around 1-3 hours from personal experience)
so sit back, go grab yourself some coffee, do some laundry, watch some YouTube, call your friends,
finish that one side project you abandoned 7 months ago, and check your email every 2 minutes in
case something goes wrong with the publication.

## Time to make a Workflow

Workflows are great! They do the boring, repetitive stuff for you automatically so you don't have
to worry about forgetting them or doing something wrong, your project looks cooler and more serious
with them but most importantly, from what I understand, they qualify you for DevOps positions which
pay quite well so that's the main reason why you should care about making them 👍

Feel free to check [Github's docs](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#release).

We first start by specifying that we want our workflow to run on a new release publication

```yml
on:
  release:
    types: [published]
```

The release event has a bunch of different types that are explained very nicely in the documentation,
I personally chose `published` which gets triggered for normal as well as pre-releases.

The good news is that this is a very simply workflow because we've already figured out how to do most
of the work from our terminals!

```yml
jobs:
  publish:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-dotnet@v1
        with:
          dotnet-version: '6.0.x'
      # Nuget 
      - run: dotnet pack
      - run: dotnet nuget push .\Rember\nupkg\*.nupkg --api-key ${{ secrets.NUGET_API_KEY }} --source https://api.nuget.org/v3/index.json
        name: Nuget publish
      # Choco
      - run: dotnet publish -o tools --verbosity normal --self-contained True /property:PublishTrimmed=True /property:PublishSingleFile=True 
      - run: choco pack
      - run: choco push --api-key=${{ secrets.CHOCO_API_KEY }}
        name: Choco publish
```

As you can see, I checkout to my repository and set up Dotnet 6 before running the exact same commands
I mentioned earlier. The only thing left now is to set the `NUGET_API_KEY` and `CHOCO_API_KEY` secrets
in your github repository and create your first release!

## Closing

Overall, I feel like this was a little less exciting than some of my other posts but to me, the whole process
of publishing this project was quite exciting and I wanted to write something about it. Hopefully this inspires
someone to go make his own package or library and make it available, same way Nick's video inspired me to work
on this project. Till next time!