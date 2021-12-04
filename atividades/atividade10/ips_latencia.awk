#!/usr/bin/env -S awk -f

$7 ~ /time=.+/ {
    avg=avg+substr($7, match($7,"[[:digit:]]+(\.[[:digit:]]+)"), length($7));
    i=i+1;
}

END {
    if (i != 0) {
        print avg/i
    }
}
