def main [name: string] {
  let date = (date now | format date "%Y-%m-%dT%H:%M:%S%:z")
  let path = "./content/posts/"
  let filename = $name + ".md"
  let fullpath = ($path + $filename)

  let text = $"---
title: "($name)"
description: ""
keywords: []
date: ($date)
draft: true
taxonomies:
  tags: []
---

"
  $text | save $fullpath
}
