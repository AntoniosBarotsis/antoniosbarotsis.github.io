# Me Personal Website

[![github pages](https://github.com/AntoniosBarotsis/antoniosbarotsis.github.io/actions/workflows/deploy.yml/badge.svg)](https://github.com/AntoniosBarotsis/antoniosbarotsis.github.io/actions/workflows/deploy.yml)

Created with [Hugo](https://gohugo.io/) using the [Terminal](https://github.com/panr/hugo-theme-terminal)
theme with some ideas from the [Papermod](https://github.com/adityatelange/hugo-PaperMod) theme.

## Running Locally

Make sure you have Hugo [installed](https://gohugo.io/getting-started/installing/)
(extended, >v0.90.0).

```sh
# Windows
choco install hugo
scoop install hugo

# Mac
brew install hugo

# Linux 
sudo apt-get install hugo
snap install hugo
```

After cloning the repo, make sure you install the submodules with

```sh
git submodule update --init --recursive
```

Run: `hugo serve --buildDrafts` (or `./Start.ps1`) to serve the file at http://localhost:1313/.

The webpage is updated automatically through Github Actions.