#!/usr/bin/env bash
# Correção: 2,0. Tudo OK!!!

# Um comando grep que encontre todoas as linhas com mensagens que não são do sshd
grep -v 'sshd' auth.log

# Um comando grep que encontre todas as linhas com mensagens que indicam um login de sucesso via sshd cujo nome do usuário começa com a letra j
egrep 'sshd.+ session opened for user j' auth.log
# ou ainda
egrep 'sshd.+ Accepted .+ for j' auth.log

# Um comando grep que encontre todas as vezes que alguém tentou fazer login via root através do sshd
egrep 'sshd.+ (Disconnected|Accepted).+ root' auth.log

# Um comando grep que encontre todas as vezes que alguém conseguiu fazer login com sucesso nos dias 11 ou 12 de Outubro
egrep 'Oct (11|12) .+ sshd.+ Accepted' auth.log
