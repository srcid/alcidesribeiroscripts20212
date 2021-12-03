BEGIN {
    print "todas as linhas com mensagens que indicam um login de sucesso via sshd cujo nome do usuário começa com a letra j"
}

$0 ~ /sshd.+ session opened for user j/ {
    print NR":"$0
}