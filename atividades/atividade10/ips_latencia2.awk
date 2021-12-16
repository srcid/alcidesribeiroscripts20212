#!/usr/bin/env -S awk -f
# Correção: 0,4. Só faltou ordenar. O primeiro script (ips_latencia.awk) não funcionou.

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
