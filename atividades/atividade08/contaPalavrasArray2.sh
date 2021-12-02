#!/usr/bin/env bash

declare -A words

while read -r line; do
   for word in $line; do
      token=${word//[^-[:alpha:]]/}
      [ -n "$token" -a "$token" != '-' ] && ((words[${token,,*}]++))
   done
done < "$1"

for i in "${!words[@]}"; do echo "$i: ${words[$i]}"; done | sort -n -r -k 2 | column -t
