#!/bin/bash
# Correção: 0,5

[ $# -lt 3 ] || [ $# -gt 3 ] && echo "Forneça três parametros!" && exit 1

for param in $*; do
  [[ $param =~ ^-?[[:digit:]]+(\.[[:digit:]]+)?$ ]] || echo "$param não é numero!" || exit 2
done

max=$1

for i in ${*:2}; do
  [ $(echo "$i > $max" | bc) == 1 ] && max=$i
done

echo $max

unset max param i
