#/usr/bin/env sh -c

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
class_and_professor=$(pdftotext historico*.pdf - | \
  grep --no-group-separator -B1 'Docente(s): ' | \
  sed 's/Docente(s): // ; s/(.\+) ?// ; s/ \?(.\+) \?//' | \
  iconv -f UTF8 -t ASCII//TRANSLIT | \
  tr -d '[:punct:]' | \
  tr '[:upper:]' '[:lower:]' | \
  tr ' ' '_' | \
  xargs -n2 echo)

while -r read class prof ; do
  if ! [ -f "disciplinas/$class.txt" ] || ! [ -f "professores/$prof.txt" ]; then
    echo "$class $prof"
    continue
  fi

  wkdir="$PWD/historico/$class"

  if [ -d $wkdir ] ; then
    nnew="$(ls $wkdir -w1 | wc -l)"
    ln -sv "$PWD/professores/$prof.txt" "$wkdir/professor$nnew"
  else
    mkdir $wkdir
    ln -sv "$PWD/professores/$prof.txt" "$wkdir/professor"
    ln -sv "$PWD/disciplinas/$class.txt" "$wkdir/programa"
  fi
done <<< $class_and_professor

# Desaloca as variáveis usadas pelo script
unset class_and_professor class prof wkdir nnew
