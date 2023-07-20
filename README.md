# My Personal Website

[![github pages](https://github.com/AntoniosBarotsis/antoniosbarotsis.github.io/actions/workflows/deploy.yml/badge.svg)](https://github.com/AntoniosBarotsis/antoniosbarotsis.github.io/actions/workflows/deploy.yml)

Created with [Zola](https://www.getzola.org/) using the
[Terminimal](https://github.com/pawroman/zola-theme-terminimal/).

## Running Locally

Make sure you have Zola 
[installed](https://www.getzola.org/documentation/getting-started/installation/).

```sh
git clone https://github.com/getzola/zola.git
cd zola
cargo install --path .
zola --version
```

After cloning the repo, make sure you install the submodules with

```sh
git submodule update --init --recursive
```

Run: `zola serve --drafts` to serve the file at http://localhost:1111/.

The webpage is updated automatically through Github Actions.