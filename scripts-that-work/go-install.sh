#!/bin/bash

# This script is part of a set of scripts that set up a node for the regen-1 mainnet of regen-ledger.
# Run this as a user that can sudo.
# This script puts things in ~/.profile with the assumption that you will run it from a non-login shell.
# If you prefer to do your operations from a login shell, change .profile to .bashrc.
# 1) Set up a non-root user and log in as that user.
# 2) Run this go-install.sh script.
# 3) Reboot.
# 4) Run the script to install regen-ledger and cosmovisor.

echo "If you want your go workspace in /home/dev/go-space,"
echo "give these answers when the script asks you:"
echo "Where would you like your Go Workspace folder to be? (example: /home)"
echo "Path: /home/dev"
echo "Give the folder a name: go-space"
echo "Press space to continue."
read -s -d ' '

cd ~
wget https://raw.githubusercontent.com/jim380/node_tooling/master/cosmos/scripts/go_install.sh
chmod +x go_install.sh
./go_install.sh -v 1.15.6
. ~/.profile
echo "export GOBIN=$GOPATH/bin" >> ~/.profile
. ~/.profile
echo "PATH is:" $PATH
echo "GOPATH is:" $GOPATH
echo "GOBIN is:" $GOBIN
echo "go version is:"
go version
echo "Check the go version printed above:"
echo "if it's empty, reboot before you run software that requires go."
