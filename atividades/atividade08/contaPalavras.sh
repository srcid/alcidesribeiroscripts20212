#!/usr/bin/env bash

counter() {
  egrep -o '[[:alpha:]]+' $1 | sort -f | uniq -ic | sort -nr | sed -E 's/ *([[:digit:]]+) (.+)/\2: \1/' | column -t
}

echo -n "Informe o arquivo: "

read -r filepath

counter "${filepath/\~/$HOME}"