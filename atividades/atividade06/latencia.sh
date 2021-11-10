#!/usr/bin/env bash

[ -z "$1" ] && echo "Forneça um arquivo com os endereços de IP." && exit 1

while read -r ipaddr
do
    timings=$(ping -c 10 $ipaddr | \
            egrep -o 'time=.+ ms' | \
            egrep -o '[[:digit:]]+(\.[[:digit:]]+)?')

    # Caso não haja resposta, não há tempo a ser medido
    if [ -z "$timings" ]; then
        echo "$ipaddr ?" >> lat.tmp
        continue
    fi

    # O comando ping já fornece uma média que pode ser obtido desse modo:
    # tail -n 1 <<< $(ping -c 10 8.8.8.8) |\
    #   egrep -o '[[:digit:]]+(\.[[:digit:]]+)\/?' | \
    #   sed -n 's/\/// ; 2p'
    # mas creio que para essa atividade deve-se usar laços para obter tal métrica
    # E tive que usar o 'bc' pois o $(()) no bash não funciona
    # muito bem com pontos-flutuantes
    acc=0
    for t in $timings; do
        acc=$(echo "$acc + $t" | bc) 
    done

    echo $ipaddr $(echo "$acc / 10" | bc) ms >> lat.tmp
done < "$1"

echo '"?" significa que não houve resposta'

sort -k 2 lat.tmp

rm lat.tmp

unset ipaddr timing acc

