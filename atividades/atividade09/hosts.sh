#!/usr/bin/env bash

[ -f '.hosts.db' ] || touch .hosts.db

add() {
    # $1 hostname
    # $2 IP
    l="$(grep -n "$1" .hosts.db | cut -d: -f 1)"
    if [ -z "$l" ]; then
        sed -i -E "$ a $1,$2" .hosts.db
    else
        sed -i -E "$l s/.+/&,$2/" .hosts.db
    fi
}

rem() {
    # $1 hostname
    sed -i "/$1/d" .hosts.db
}

find() {
    # $1 hostname 
    grep "$1" .hosts.db | cut -d, -f 2- | column -s, -t
}

rfind() {
    # $1 IP
    grep "$1" .hosts.db | cut -d, -f 1
}

list() {
    column -s, -t .hosts.db
}

selected=

while getopts 'a:i:d:r:l' arg; do
    case $arg in
    a)
    selected=$OPTARG
    ;;

    i)
    if [ -n"$selected" ]; then
        add $selected $OPTARG
    else
        echo "Forneça um hostname com a opção '-a'" 
    fi
    selected=""
    ;;

    d)
    rem $OPTARG
    ;;

    r)
    rfind $OPTARG
    ;;
    
    l)
    list
    ;;
    esac
done

if [[ "$1" =~ ^[^-] ]]; then
    find $1
fi