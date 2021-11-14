#!/usr/bin/env bash

ls -w1 $2 > .tmp_old

while true; do
    ls -w1 $2 > .tmp_new

    cur="$(wc -l < .tmp_new)"
    old="$(wc -l < .tmp_old)"

    d=$(diff --suppress-common-lines .tmp_old .tmp_new)

    if [ -n "$d" ]; then
        alt="$(date +'%d/%m/%y às %H:%M:%S') Alteração!"
        rem="$(sed -E -n 's/< (.+)/\1/p' <<< $d)"
        cre="$(sed -E -n 's/> (.+)/\1/p' <<< $d)"
        
        res="$alt $old->$cur"

        [ -z "$rem" ] || res="$res Removidos: $rem"
        [ -z "$cre" ] || res="$res Criados: $cre"

        echo -e $res | tee -a dirSensors.log
    fi

    cat > .tmp_old < .tmp_new

    sleep $1

done

rm .tmp*
unset prev next d alt rem cre res
