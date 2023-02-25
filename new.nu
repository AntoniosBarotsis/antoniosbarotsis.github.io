def main [name: string] {
  let date = (date now | date format "%Y-%m-%dT%H:%M:%S%:z")
  let path = "./content/posts/"
  let filename = $name + ".md"
  let fullpath = ($path + $filename)

  let text = $"---
title: "($name)"
description: ""
tags: []
keywords: []
date: ($date)
draft: true
---

"
  $text | save $fullpath
}