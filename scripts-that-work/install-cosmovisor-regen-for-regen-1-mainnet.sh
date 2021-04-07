#!/bin/bash

# This script is part of a set of scripts that set up a node for the regen-1 mainnet of regen-ledger.
# Run this as a user that can sudo.
# This script puts things in ~/.profile with the assumption that you will run it from a non-login shell.
# If you prefer to do your operations from a login shell, change .profile to .bashrc.
# 1) Set up a non-root user and log in as that user.
# 2) Run the go-install.sh script.
# 3) Reboot.
# 4) Run this script to install regen-ledger and cosmovisor.

# Set versions of cosmos-sdk (for cosmovisor) and regen-ledger before running this script.
COSMOSSDKVERSION="v0.41.0"
REGENVERSION="v1.0.0-rc2"

# Prepare the environment, fetch code, make and install cosmovisor

mkdir -p $GOBIN ${HOME}/.regen/cosmovisor/genesis/bin

mkdir -p $GOPATH/src/github.com/cosmos && cd $GOPATH/src/github.com/cosmos && git clone https://github.com/cosmos/cosmos-sdk && cd cosmos-sdk/cosmovisor && git checkout $COSMOSSDKVERSION && make cosmovisor

mv cosmovisor $GOBIN

echo "Cosmovisor" $COSMOSSDKVERSION "built and installed. Press space to continue."
read -s -d ' '

# Prepare the environment, fetch code, make and install regen-ledger

mkdir $GOPATH/src/github.com/regen-network && cd $GOPATH/src/github.com/regen-network && git clone https://github.com/regen-network/regen-ledger && cd regen-ledger && git fetch && git checkout $REGENVERSION && make build

mv build/regen ${HOME}/.regen/cosmovisor/genesis/bin

${HOME}/.regen/cosmovisor/genesis/bin/regen version

echo "regen-ledger" $REGENVERSION "built and installed. Press space to continue."
read -s -d ' '

ln -s -T ${HOME}/.regen/cosmovisor/genesis ${HOME}/.regen/cosmovisor/current

echo "export PATH=/home/$USER/.regen/cosmovisor/current/bin:\$PATH" >> ~/.profile
. /home/$USER/.profile

# Create systemd service:

echo "[Unit]
Description=Regen Node
After=network-online.target
[Service]
User=${USER}
Environment=DAEMON_NAME=regen
Environment=DAEMON_RESTART_AFTER_UPGRADE=true
Environment=DAEMON_HOME=${HOME}/.regen
ExecStart=$(which cosmovisor) start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" >cosmovisor.service

sudo mv cosmovisor.service /lib/systemd/system/

# After this command is run, cosmovisor is ready to start.
# If you reboot, cosmovisor will start -- be careful, since you might not be ready to start yet.

sudo systemctl daemon-reload && sudo systemctl enable cosmovisor.service


echo "---------------"
echo "---------------"
echo "Installation of regen-ledger and cosmovisor complete."
echo "Now, to join the regen-1 mainnet, you can run"
echo "regen init --chain-id=regen-1 <your_moniker>"
echo "and then"
echo "regen keys add <your-new-key> -i"
echo "Make sure you back up the mnemonics !!!"
echo "Or if you have the mnemonic for a key, you can import it with"
echo "regen keys add <key-name> --recover"
echo "---------------"

echo "To configure your node before starting, see"
echo "https://github.com/patogit/mainnet/tree/main/regen-1"
echo "---------------"

echo "Before starting your node, review the utility scripts at"
echo "https://github.com/swidnikk/regen-utils"
echo "---------------"


echo "If you want to make any changes to you config,"
echo "do that before starting cosmovisor,"
echo "otherwise you'll have to restart after making changes."
echo "---------------"

echo "If you run"
echo "which regen"
echo "and don't get a path, then run:"
echo ". /home/$USER/.profile"
echo "and then try \"which regen\" again."
echo "---------------"

echo "To fetch a data backup via scp, you might use"
echo "scp -v user@ip.address:/home/user/.regen/data-backup.tar.gz ."
echo "---------------"

echo "After your key is installed, and you have reviewed those scripts,"
echo "and you have put any backup data in ~/.regen/data,"
echo "you can start running your node with:"
echo "sudo systemctl start cosmovisor.service"
echo "---------------"

echo "To the Earth!"
echo "---------------"
