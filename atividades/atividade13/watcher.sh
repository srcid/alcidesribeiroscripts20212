#!/usr/bin/env sh

while : ;
do

# 1. O horário e data da coleta de informações.
data="$(date +%H:%M:%S-%D)"

# 2. Tempo que a máquina está ativa.
uptime="$(uptime --pretty)"

# 3. Carga média do sistema.
pcpu="$(top -b -n 1 | sed -n '3p' | tr -d '[:alpha:][%:()]' | awk '{print $1+$2"%"}')"

# 4. Quantidade de memória livre e ocupada.
mused="$(free -h | sed -n 2p | awk '{print $3}')"
mfree="$(free -h | sed -n 2p | awk '{print $4}')"

# 5. Quantidade de bytes recebidos e enviados através da interface eth0.
recvb="$(sed -n '/eth0/p' /proc/net/dev | awk '{print $2 " Bytes"}')"
transb="$(sed -n '/eth0/p' /proc/net/dev | awk '{print $10 " Bytes"}')"

echo "$data;$uptime;$pcpu;$mused;$mfree;$recvb;$transb" >> /var/log/mensagens.log

sed -i "/<\/tbody>/i <tr><td>$data</td><td>$uptime</td><td>$pcpu</td><td>$mused</td><td>$mfree</td><td>$recvb</td><td>$transb</td></tr>" sample/index.html

sleep 5

done
