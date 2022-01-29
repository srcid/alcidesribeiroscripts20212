#!/usr/bin/env bash

amazon-linux-extras install nginx1
mkdir -p /usr/share/nginx/www
chown -R ec2-user /usr/share/nginx/www

touch /var/log/mensagens.log
chown ec2-user /var/log/mensagens.log

cat << EOF > /usr/share/nginx/www/index.html
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Watcher</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
</head>
<body>
    <script>
        setTimeout(() => document.location.reload(true), 60000);
    </script>

    <table class="table table-striped">
        <thead>
            <tr>
                <th>data</th>
                <th>uptime</th>
                <th>uso da cpu</th>
                <th>uso de memória</th>
                <th>memória livre</th>
                <th>dados recebidos</th>
                <th>dados enviados</th>
            </tr>
        </thead>
        <tbody>
            
        </tbody>
    </table>
</body>
</html>
EOF

echo \
'#!/usr/bin/env sh

# 1. O horário e data da coleta de informações.
data="$(date +%H:%M:%S-%D)"

# 2. Tempo que a máquina está ativa.
uptime="$(uptime --pretty)"

# 3. Carga média do sistema.
pcpu="$(top -b -n 1 | sed -n '"'"'3p'"'"' | tr -d '"'"'[:alpha:][%:()]'"'"' | awk '"'"'{print $1+$2"%"}'"'"')"

# 4. Quantidade de memória livre e ocupada.
mused="$(free -h | sed -n 2p | awk '"'"'{print $3}'"'"')"
mfree="$(free -h | sed -n 2p | awk '"'"'{print $4}'"'"')"

# 5. Quantidade de bytes recebidos e enviados através da interface eth0.
recvb="$(sed -n '"'"'/eth0/p'"'"' /proc/net/dev | awk '"'"'{print $2 " Bytes"}'"'"')"
transb="$(sed -n '"'"'/eth0/p'"'"' /proc/net/dev | awk '"'"'{print $10 " Bytes"}'"'"')"

echo "$data;$uptime;$pcpu;$mused;$mfree;$recvb;$transb" >> /var/log/mensagens.log

sed -i "/<\/tbody>/i <tr><td>$data</td><td>$uptime</td><td>$pcpu</td><td>$mused</td><td>$mfree</td><td>$recvb</td><td>$transb</td></tr>" /usr/share/nginx/www/index.html
' > /usr/local/bin/watcher.sh

chmod +x /usr/local/bin/watcher.sh

sed -i '$i * * * * * ec2-user /usr/local/bin/watcher.sh' /etc/crontab

sed -i '42 s/html;/www;/' /etc/nginx/nginx.conf

systemctl enable nginx.service --now
