def main [post: string] {
  print $"(ansi red_bold)Spell check:(ansi reset)"
  do -i { cspell content/posts/($post).md }
  
  print $"\n(ansi red_bold)Link check:(ansi reset)"
  do -i { lychee http://127.0.0.1:1111/posts/($post) --exclude linkedin.com --exclude archive.is }
}
