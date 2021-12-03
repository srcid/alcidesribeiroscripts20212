BEGIN {
    print "todas as vezes que alguém conseguiu fazer login com sucesso nos dias 11 ou 12 de Outubro."
}

$0 ~ /Oct (11|12) .+ sshd.+ Accepted/ {
    print NR":"$0
}