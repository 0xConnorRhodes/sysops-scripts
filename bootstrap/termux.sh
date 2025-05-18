#!/usr/bin/env bash
# run on phone with curl -sSL sfs.connorrhodes.com/bootstrap/termux.sh | bash

echo 'first run termux-change-repo (default options are sufficient)'
sleep 5

yes | pkg upgrade

pkg add -y openssh python

echo 'set password with password, then run sshd'
