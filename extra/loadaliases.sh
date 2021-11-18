# Este script cria aliases a partir de arquivos em .config/aliases/
# No formato SSV (Semicolon Separated Values) e foi pensado para ser
# adicionado no arquivo run commands de sua shell (Ex: .bashrc e .zshrc)
# Ex: arquivo .config/aliases/hw conterá
# hw ; echo "Hello World!"

for f in $HOME/.config/aliases/*
do
  while read -r l
  do
    eval "$(echo $l | sed -E 's/(.+) ; (.+)/alias \1="\2"/ ; s/  +//g ; s/ =/=/ ; s/ "/"/')"
  done < $f
done
