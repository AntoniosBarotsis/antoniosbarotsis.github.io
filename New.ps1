param(
    [Parameter(Mandatory=$true)] [String]$name
)

$path = ".\content\posts\$name"

$Tz = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

# This broke with daylight savings, hardcoded GMT+2
# $tmp = Get-TimeZone | Select-Object BaseUtcOffset
$tmp = [PSCustomObject]@{
    BaseGmtOffset = New-TimeSpan -Hours 2
}

$GmtOffset = "+{0:hh\:mm}" -f $tmp.BaseGmtOffset
$date = "$Tz$GmtOffset"

New-Item -Path "$path.md" -ItemType File -ErrorAction Stop

$text = @”
---
title: "$name"
description: ""
tags: []
keywords: []
date: $date
draft: true
---

"@

$text | Out-File -Encoding UTF8 "$path.md"