#!/usr/bin/env -S awk -f

!/^ *$/ {
    ip = $0
    cmd = sprintf("ping -c 10 %s", $0);
    
    while ((cmd | getline) > 0) {
        if (gsub(/time=/, "", $7) == 1) {
            lats[ip] += $7
        }
    }
}

END {
    for (ip in lats) {
        printf "%-15s %fms\n", ip, lats[ip]/10
    }
}
