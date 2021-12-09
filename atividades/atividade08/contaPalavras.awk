#!/usr/bin/env -S mawk -f

$0 !~ /^[[:space:]]*$/ {
    for (i=1; i<NF; i++) {
        if (match($i, /[[:alpha:]]+(-[[:alpha:]]+)*/) > 0) {
            words[tolower(substr($i, RSTART, RLENGTH))]++
        }
    }
}

END {
    for (word in words) {
        printf "%-20s %d\n", word ":", words[word] | "sort -rnk2"
    }
}
