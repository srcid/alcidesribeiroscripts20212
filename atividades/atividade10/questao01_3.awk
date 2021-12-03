BEGIN {
    print "todas as vezes que alguém tentou fazer login via root através do sshd"
}

$0 ~ /sshd.+ (Disconnected|Accepted).+ root/ {
    print NR":"$0
}