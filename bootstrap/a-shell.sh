config -s 20
config -p

echo 'y' | pkg install git

ssh-keygen -a 100 -t ed25519

cat ~/Documents/.ssh/id_ed25519.pub
