#!/usr/bin/env -S awk -f
# Correção: 1,0
NR > 1 {
  if ($3 > maior_salario[$2]) {
    maior_nome[$2] = $1;
    maior_salario[$2] = $3;
  }
}

END {
  for (curso in maior_nome) {
    print curso ": " maior_nome[curso] " " maior_salario[curso];
  }
}
