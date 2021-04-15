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
REGENVERSION="v1.0.0"

# Prepare the environment, fetch code, make and install regen-ledger

mkdir -p $GOPATH/src/github.com/regen-network
cd $GOPATH/src/github.com/regen-network
git clone https://github.com/regen-network/regen-ledger
cd regen-ledger
git fetch
git checkout $REGENVERSION
make build

regen version

echo "regen-ledger" $REGENVERSION "built and installed. Press space to continue."
read -s -d ' '

# Create systemd service:
DAEMON_PATH=$(which regen)

echo "[Unit]
Description=regen daemon
After=network-online.target
[Service]
User=${USER}
ExecStart=${DAEMON_PATH} start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" >regen.service

sudo mv regen.service /lib/systemd/system/regen.service

# After this command is run, cosmovisor is ready to start.
# If you reboot, cosmovisor will start -- be careful, since you might not be ready to start yet.

sudo systemctl daemon-reload && sudo systemctl enable regen.service


echo "---------------"
echo "---------------"
echo "Installation of regen-ledger complete."
echo "Now, to join the regen-1 mainnet, you can run"
echo "regen init --chain-id=regen-1 <your_moniker>"
echo "and then (if this is validator node or otherwise needs keys)"
echo "regen keys add <your-new-key>"
echo "Make sure you back up the mnemonics !!!"
echo "Or if you have the mnemonic for a key, you can import it with"
echo "regen keys add <key-name> --recover"
echo "---------------"

echo "To configure your node before starting, see"
echo "https://github.com/regen-network/mainnet/tree/main/regen-1"
echo "and"
echo "https://github.com/regen-network/mainnet"
echo "---------------"

echo "Before starting your node, review the utility scripts at"
echo "https://github.com/swidnikk/regen-utils"
echo "---------------"


echo "If you want to make any changes to you config,"
echo "do that before starting regen.service,"
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

echo "Get mainnet genesis"
echo "curl -s https://raw.githubusercontent.com/regen-network/mainnet/main/regen-1/genesis.json > ~/.regen/config/genesis.json"
echo "Verify that"
echo "jq -S -c -M '' ~/.regen/config/genesis.json | shasum -a 256"
echo "curl https://raw.githubusercontent.com/regen-network/mainnet/main/regen-1/checksum.txt"

echo "regen version --long"
echo "should = commit: 1b7c80ef102d3ae7cc40bba3ceccd97a64dadbfd"

echo "Persistent peers"
echo "69975e7afdf731a165e40449fcffc75167a084fc@104.131.169.70:26656,d35d652b6cb3bf7d6cb8d4bd7c036ea03e7be2ab@116.203.182.185:26656,ffacd3202ded6945fed12fa4fd715b1874985b8c@3.98.38.91:26656"
echo "seed"
echo "aebb8431609cb126a977592446f5de252d8b7fa1@104.236.201.138:26656"

echo "After your key is installed, and you have reviewed those scripts,"
echo "and you have put any backup data in ~/.regen/data,"
echo "you can start running your node with:"
echo "sudo service regen start"
echo "---------------"

echo "To the Earth!"
echo "---------------"
