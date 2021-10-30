#!/bin/bash

# Agenda será separada por dois pontos ':' (ou colon, em inglês) 
# NOME DO CONTATO:EMAIL

case $1 in
  adicionar|add)
    ! [ -f agenda.db ] && echo "Arquivo criado!"
    echo "$2:$3" >> agenda.db
    echo "Adicionado"
    ;;

  remover|rm)
    contact=$(egrep -n "^.+:$2$" agenda.db)
    
    if [ $? == 1 ]; then
      echo "Nenhun contato com esse email!"
      exit 1
    fi
    
    sed -E -i "${contact%%:*}d" agenda.db
    echo "Contato removido!"
    ;;
  
  listar|ls)
    if [ -s agenda.db ]; then
      cat agenda.db
    else
      echo "Agenda vazia!"
    fi
    ;;

  *)
    cat <<\EOF
As opções desse programa são:

listar
  imprime todos os contatos na agenda.

  Ex: ./agenda listar

adcionar
  adiciona o contato passado como parametros na agenda.

  Ex: ./agenda adicionar 'Aluno da Silva' 'aluno@server.doman'

remover
  remove um contato com o email passado por parametro.

  Ex: ./agenda remover 'aluno@server.domain'"
EOF
  exit 1
  ;;
esac

unset contato
