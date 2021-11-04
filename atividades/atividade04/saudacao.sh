#!/usr/bin/env bash
# Correção: 1,5
# Se eu executar o script três vezes, apenas uma mensagem é escrita em saudacao.log. O correto seria anexar ao arquivo.

user=$(whoami)

read -r cur_day cur_mouth cur_year <<< $(date +'%d %m %y')

echo -e "Olá, $user!\nHoje é dia $cur_day, do mês $cur_mouth do ano de $cur_year." | tee -a saudacao.log
