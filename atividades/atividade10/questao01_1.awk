# Correção: 0,5
BEGIN {
    print "Todas as linhas que não são do ssh"
}

$5 !~ /sshd.+/ {
    print NR":"$0
}