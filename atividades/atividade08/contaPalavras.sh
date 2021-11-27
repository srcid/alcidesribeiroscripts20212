#!/usr/bin/env bash
# Correção: 0,5

counter() {
  egrep -o '[[:alpha:]]+' $1 | sort -f | uniq -ic | sort -nr | sed -E 's/ *([[:digit:]]+) (.+)/\2: \1/' | column -t
}

if [ -z "$1" ]; then
  echo -n "Informe o arquivo: "
  read -r filepath
else
  filepath=$1
fi

counter "${filepath/\~/$HOME}"
