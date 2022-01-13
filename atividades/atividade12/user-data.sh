#!/usr/bin/env bash

amazon-linux-extras install nginx1

mkdir -p /usr/share/nginx/www

echo \
'<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scripts 2021.2</title>
</head>
<body>
    <style>
        #main {
            text-align: center;
        }

        #gh {
            height: 300px;
        }
    </style>
    <div id="main">
        <img id="gh" src="https://avatars.githubusercontent.com/u/34487193?v=4" alt="Imagem do github">

        <h1>Aluno</h1>
        <p>Alcides</p>

        <h2>Matrícula</h2>
        <p>402138</p>
    </div>
</body>
</html>' > /usr/share/nginx/www/index.html

sed -i '42 s/html;/www;/' /etc/nginx/nginx.conf

systemctl enable nginx.service --now
