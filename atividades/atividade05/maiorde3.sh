#!/bin/bash

[ $# -lt 3 ] || [ $# -gt 3 ] && echo "Forneça três parametros!" && exit 1

for param in $*; do
  [[ $param =~ ^[[:digit:]]+(\.[[:digit:]]+)?$ ]] || echo "$param não é numero!" || exit 2
done

max=$1

for i in ${*:2}; do
  [ $(expr "$i" ">" "$max") == 1 ] && max=$i
done

echo $max

unset max param i
