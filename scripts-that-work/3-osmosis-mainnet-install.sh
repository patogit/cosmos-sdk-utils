#!/bin/bash

# This script is part of a set of scripts that set up a node for the osmosis-1 mainnet of the Osmosis Network.
# Run this as a user that can sudo.
# This script puts things in ~/.profile with the assumption that you will run it from a non-login shell.
# If you prefer to do your operations from a login shell, change .profile to .bashrc.
# 1) Set up a non-root user and log in as that user. You can use script 1 from this repo for that purpose.
# 2) Run the 2-go-path-settings.sh script.
# 3) Run . ~/.profile.
# 4) Run this script to install osmosis and initialize on the chain of your choosing.
#
# ./3-osmosis-mainnet-install.sh <git project directory> <branch-or-tag> <chain-id> <moniker>
# for example:
# ./3-osmosis-mainnet-install.sh "osmosis-labs/osmosis" "v1.0.1" osmosis-1 "My Validator Name"
# make sure your moniker has no spaces. You can change the moniker later if you want to add spaces.

# Provide these arguments:
PROJECT=$1
VERSION=$2
CHAINID=$3
MONIKER=$4

# Prepare the environment, fetch code, make and install regen-ledger

git clone -b $VERSION https://github.com/$PROJECT.git $GOPATH/src/github.com/$PROJECT
cd $GOPATH/src/github.com/$PROJECT
make install

$GOPATH/bin/osmosisd version

$GOPATH/bin/osmosisd config chain-id osmosis-1

echo "osmosis" $VERSION "built and installed. Press space to continue."
read -s -d ' '

# Install cosmovisor
git clone -b v0.42.5 https://github.com/cosmos/cosmos-sdk.git $GOPATH/src/github.com/cosmos/cosmos-sdk
cd $GOPATH/src/github.com/cosmos/cosmos-sdk
make cosmovisor
cp cosmovisor/cosmovisor $GOPATH/bin/cosmovisor


$GOPATH/bin/osmosisd init --chain-id=$CHAINID $MONIKER

$GOPATH/bin/osmosisd config chain-id $CHAINID

mkdir -p ~/.osmosisd/cosmovisor/genesis/bin
mkdir -p ~/.osmosisd/cosmovisor/upgrades

echo "# Setup Cosmovisor" >> ~/.profile
echo "export DAEMON_NAME=osmosisd" >> ~/.profile
echo "export DAEMON_HOME=$HOME/.osmosisd" >> ~/.profile
echo "export PATH=\"$DAEMON_HOME/cosmovisor/current/bin:\$PATH\"" >> ~/.profile
source ~/.profile

mv $GOPATH/bin/osmosisd ~/.osmosisd/cosmovisor/genesis/bin

curl https://media.githubusercontent.com/media/osmosis-labs/networks/main/osmosis-1/genesis.json > ~/.osmosisd/config/genesis.json


# Create systemd service:

sudo tee /etc/systemd/system/osmosisd.service > /dev/null <<EOF  
[Unit]
Description=Osmosis Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) start
Restart=always
RestartSec=3
LimitNOFILE=4096

Environment="DAEMON_HOME=$HOME/.osmosisd"
Environment="DAEMON_NAME=osmosisd"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

[Install]
WantedBy=multi-user.target
EOF

# After this command is run, cosmovisor is ready to start.
# If you reboot, cosmovisor will start -- be careful, since you might not be ready to start yet.

sudo systemctl daemon-reload && sudo systemctl enable osmosisd.service

echo "These are the addresses for the persistent peers for osmosis-1:"
echo "ffc82412c0261a94df122b9cc0ce1de81da5246b@15.222.240.16:26656,9faf468b90a3b2b85ffd88645a15b3715f68bb0b@195.201.122.100:26656,3fea02d121cb24503d5fbc53216a527257a9ab55@143.198.145.208:26656,23142ab5d94ad7fa3433a889dcd3c6bb6d5f247d@95.217.193.163:26656,785bc83577e3980545bac051de8f57a9fd82695f@194.233.164.146:26656"
echo "Copy these addresses so that you can paste it into the persistent peers section of config.toml"
echo "Make any other changes, such as state sync info, etc."
echo "Push space when you have copied it and you're ready to edit."
read -s -d ' '
nano ${HOME}/.osmosisd/config/config.toml

echo "Now you will edit app.toml to your liking, perhaps adding minimum-gas-prices 0.025uosmo."
echo "Press space when you are ready to edit."
read -s -d ' '
nano ${HOME}/.osmosisd/config/app.toml

$GOPATH/bin/osmosisd unsafe-reset-all

echo "Setup is complete. Ready to sync the chain. No keys or validator created yet."
echo "Press space to start synchronizing with the network, or press ctrl-c to exit without starting."
read -s -d ' '

sudo systemctl start osmosisd.service

echo "---------------"
echo "---------------"
echo "Installation of osmosis complete."
echo "osmosis-1 mainnet now syncing."
echo "It may take up to ten minutes for blocks to start syncing."
echo "journalctl -u osmosisd -f will show you recent logs."

echo "---------------"
echo "If this is validator node or otherwise needs keys:"
echo "osmosisd keys add <your-new-key>"
echo "Make sure you back up the mnemonics !!!"
echo "Or if you have the mnemonic for a key, you can import it with"
echo "osmosisd keys add <key-name> --recover"
echo "---------------"

echo "To configure your node further, see"
echo "https://github.com/osmosis-labs/networks/blob/main/genesis-validators.md"
echo "and"
echo "https://github.com/Staketab/tools/tree/main/cosmovisor/osmosis"
echo "---------------"

echo "Before starting your validator, review the utility scripts at"
echo "https://github.com/patogit/cosmos-sdk-utils"
echo "and the repositories linked there."
echo "See also the block explorer at https://osmosis.aneka.io/"
echo "---------------"

echo "If you want to make any changes to you config,"
echo "restart osmosisd.service after making changes."
echo "---------------"

echo "To fetch a data backup via scp, you might use"
echo "scp -v user@ip.address:/home/user/.osmosisd/data-backup.tar.gz ."
echo "---------------"

echo "To the Earth!"
echo "---------------"
