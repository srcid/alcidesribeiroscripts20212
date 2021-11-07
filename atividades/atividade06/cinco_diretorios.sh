#!/usr/bin/env bash

rept() {
    for i in $(seq 1 $2)
    do
        echo $1
    done
}

mkdir -p cinco/dir{1..5} 2> /dev/null

for sub in $(find ./cinco -type d -name 'dir*')
do
    for cnt in $(seq 1 4)
    do
        echo "$(rept $cnt $cnt)" > ${sub}/arq${cnt}.txt
    done
done

unset sub cnt