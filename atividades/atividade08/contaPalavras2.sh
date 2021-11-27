#!/usr/bin/env bash

counter() {
  egrep -o '[[:alpha:]]+(-[[:alpha:]]+)+' $1 | awk '{print tolower($0)}' | sort | uniq -c | sort -n -r | sed -E 's/ *([[:digit:]]+) (.+)/\2: \1/' | column -t
}

if [ -z "$1" ]; then
  echo -n "Informe o arquivo: "
  read -r filepath
else
  filepath=$1
fi

counter "${filepath/\~/$HOME}"
