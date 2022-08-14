---
title: "Toast"
description: "Improving your Github Actions pipelines with Toast."
tags: ["Non-Coding"]
keywords: ["CI", "CICD", "workflow", "pipeline", "github" , "actions", "github actions"]
date: 2022-08-14T03:51:26+02:00
draft: true
---

## What is Toast

Toast is a CLI tool that allows you to define and run workflows inside docker containers.

It was created by an AirBnb (?) engineer ...

The repo can be found [here]().

## Why is it Useful?

Even though Github Actions is great, it (and almost all CI providers out there) has one very annoying drawback; you cannot do a test run of your workflow locally.

Reproducability is of paramount importance in something like a pipeline in my opinion; you should
be able to replicate whatever error your CI runner got locally so that you can debug it effectively.
Another perhaps less obvious perk to those of you who do not obsess with making pipelines for every
project, is that there will be no need for you to push 20 commits, each slightly changing the `yml`
file ever so slightly because the CI runner keeps telling you it's invalid. With Toast you can, 
and should, run your pipelines locally to verify that they work properly if you make any changes to
the `yml` file.

Yes, I know tools like [Act]() exist but I personally did not have a great experience with them,
there was always some issue with something. Toast has been perfect for me and I don't really have
the need to replace it. I believe that as of now, Mac and Windows images are not supported but
the vast majority of CI runs happen on Linux machines anyways so for the most part, this is not
really an issue.

### My Usecase

...

where toast really shines is with the interactive mode

## Explaining my Basic Workflow

```yml
# toast.yml
image: antoniosbarotsis/posharp-veritas
command_prefix: set -e # Make Bash fail fast.

tasks:
  build_dependencies:
    command: ./gradlew clean build --no-daemon 2>&1 || true
    description: "Builds and caches all the used libraries to speedup subsequent steps."
    input_paths:
      - gradlew
      - gradle
      - build.gradle.kts
      - gradle.properties
      - settings.gradle.kts
      - app/build.gradle.kts
      - app/settings.gradle.kts
      - veritas/build.gradle.kts
      - veritas/settings.gradle.kts

  build:
    command: |
      # Skip separate build stage locally to save time
      if [[ -z "${CI}" ]]; then
        echo "Not in CI environment, skipping build stage..."
      else
        ./gradlew clean build --no-daemon
      fi
    dependencies:
      - build_dependencies
    description: "Performs a `gradle build`. Only runs in the CI environment to save time."
    environment:
      CI: ''
    excluded_input_paths:
      - 'bin'
      - 'build'
    input_paths:
      - '.'

  test:
    cache: false
    command: ./gradlew runCoverage $args --no-daemon
    dependencies:
      - build_dependencies
      - build
    description: "Runs the tests and generates a coverage report."
    environment:
      args: ''
    input_paths:
      - '.'
    output_paths:
      - coverage.json
```

```yml
# .github\workflows\workflow.yml
name: Build and Test
on:
  workflow_dispatch:
  push:
    branches:
      - "master"
  pull_request:

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: stepchowfun/toast/.github/actions/toast@main
        env:
          args: -PextraArgs=export -q
      - uses: codecov/codecov-action@v2
        with:
          files: coverage.json
```
