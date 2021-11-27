#!/usr/bin/env bash

declare -A var

while read -r word; do
   ((var[${word,,*}]++))
done <<< "$(egrep -o '\w+(-\w+)*' $1)"

for i in "${!var[@]}"; do echo "$i: ${var[$i]}"; done | sort -n -r -k 2 | column -t
