#!/usr/bin/env bash

user=$(whoami)

read -r cur_day cur_mouth cur_year <<< $(date +'%d %m %y')

echo -e "Olá, $user!\nHoje é dia $cur_day, do mês $cur_mouth do ano de $cur_year." | tee saudacao.log
