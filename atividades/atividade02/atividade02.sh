#!/usr/bin/env bash

mkdir disciplinas historico professores

# Professores
curl -s https://www.quixada.ufc.br/docente/ | \
  egrep -o '<h2>.+' | \
  sed 's/<h2>\(.\+\)<\/h2>/\1/' | \
  iconv -f UTF8 -t ASCII//TRANSLIT | \
  tr -d '[:punct:]' | \
  tr '[:upper:]' '[:lower:]' | \
  tr ' ' '_' | \
  xargs -I{} -t touch "professores/{}.txt"

# Disciplinas
curl -s https://cc.quixada.ufc.br/estrutura-curricular/estrutura-curricular/ | \
  sed -ne '/"displ-obrig"/,${p;/"displ-opt"/q}' | \
  egrep --no-group-separator -A1 '<td>QX.+</td>' | \
  egrep -v '<td>QX.+</td>' | \
  sed -n 's/<td>\(.\+\)<\/td>/\1/p' | \
  iconv -f UTF8 -t ASCII//TRANSLIT | \
  tr -d '[:punct:]' | \
  tr '[:upper:]' '[:lower:]' | \
  tr ' ' '_' | \
  xargs -I{} -t touch "disciplinas/{}.txt"

# Historico
classes_and_professors=$(pdftotext historico*.pdf - | \
  grep --no-group-separator -B1 'Docente(s): ' | \
  sed 's/Docente(s): // ; s/(.\+) ?// ; s/ \?(.\+) \?//' | \
  iconv -f UTF8 -t ASCII//TRANSLIT | \
  tr -d '[:punct:]' | \
  tr '[:upper:]' '[:lower:]' | \
  tr ' ' '_' | \
  xargs -n2 echo)

cd historico

while read -r class prof; do
    if ! [ -f "../disciplinas/$class.txt" ] || ! [ -f "../professores/$prof.txt" ]; then
        echo "$class $prof"
        continue
    fi

    [ -d $class ] || mkdir $class

    cd $class

    if [ -z $(ls) ]; then
        ln -sv "../../professores/$prof.txt" "professor"
        ln -sv "../../disciplinas/$class.txt" "programa"
    else
        ln -sv "../../professores/$prof.txt" "professor$(ls -w1 | wc -l)"
    fi

    cd ..

done <<< $classes_and_professors

# Desaloca as variáveis usadas pelo script
unset classes_and_professors class prof
