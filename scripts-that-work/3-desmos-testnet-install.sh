#!/bin/bash

# This script is part of a set of scripts that set up a node for the morpheus-apollo-1 testnet of the Desmos Network.
# Run this as a user that can sudo.
# This script puts things in ~/.profile with the assumption that you will run it from a non-login shell.
# If you prefer to do your operations from a login shell, change .profile to .bashrc.
# 1) Set up a non-root user and log in as that user. You can use script 1 from this repo for that purpose.
# 2) Run the 2-go-path-settings.sh script.
# 3) Run . ~/.profile.
# 4) Run this script to install desmos and initialize on the chain of your choosing.
#
# ./3-desmos-testnet-install.sh <hub-version> <chain-id> <moniker>
# for example:
# ./3-desmos-testnet-install.sh "tags/v0.16.0" morpheus-apollo-1 akik-takat-morpheus-testnet-node-01
# make sure your moniker has no spaces. You can change the moniker later if you want to add spaces.

# Provide these arguments:
VERSION=$1
CHAINID=$2
MONIKER=$3

# Prepare the environment, fetch code, make and install regen-ledger

mkdir -p $GOPATH/src/github.com/desmos-labs
cd $GOPATH/src/github.com/desmos-labs
git clone https://github.com/desmos-labs/desmos.git
cd desmos
git fetch
git checkout $VERSION
make install

desmos version

echo "desmos" $VERSION "built and installed. Press space to continue."
read -s -d ' '

# Create systemd service:
DAEMON_PATH=$(which desmos)

echo "[Unit]
Description=desmos daemon
After=network-online.target
[Service]
User=${USER}
ExecStart=${DAEMON_PATH} start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" > desmos.service

sudo mv desmos.service /lib/systemd/system/desmos.service

# After this command is run, cosmovisor is ready to start.
# If you reboot, cosmovisor will start -- be careful, since you might not be ready to start yet.

sudo systemctl daemon-reload && sudo systemctl enable desmos.service

desmos init --chain-id=$CHAINID $MONIKER

echo "Get morpheus-apollo-1 testnet genesis"
curl -s https://raw.githubusercontent.com/desmos-labs/morpheus/master/morpheus-apollo-1/genesis.json > ~/.desmos/config/genesis.json
echo "Checksums"
jq -S -c -M '' ~/.desmos/config/genesis.json | shasum -a 256
echo "0f531ba4298a0c23e5ba13fa0a6c1aee62c5a9f1204e98b9ba792cf825b1aaa0"

echo "Verify that the two strings above are equal. Press space to continue."
read -s -d ' '

echo "These are the addresses for the seed nodes for morpheus-apollo-1:"
echo "be3db0fe5ee7f764902dbcc75126a2e082cbf00c@seed-1.morpheus.desmos.network:26656,4659ab47eef540e99c3ee4009ecbe3fbf4e3eaff@seed-2.morpheus.desmos.network:26656,1d9cc23eedb2d812d30d99ed12d5c5f21ff40c23@seed-3.morpheus.desmos.network:26656"
echo "Copy this address so that you can paste it into the seeds section of config.toml"
echo "Push space when you have copied it and you're ready to edit."
read -s -d ' '
nano ${HOME}/.desmos/config/config.toml

echo "Now you will edit app.toml to your liking, perhaps adding minimum-gas-prices 0.025udaric."
echo "Press space when you are ready to edit."
read -s -d ' '
nano ${HOME}/.desmos/config/app.toml

desmos unsafe-reset-all

sudo systemctl start desmos.service

echo "---------------"
echo "---------------"
echo "Installation of desmos complete."
echo "morpheus-apollo-1 testnet now syncing."
echo "It may take up to ten minutes for blocks to start syncing."
echo "journalctl -u desmos -f will show you recent logs."

echo "---------------"
echo "If this is validator node or otherwise needs keys:"
echo "desmos keys add <your-new-key>"
echo "Make sure you back up the mnemonics !!!"
echo "Or if you have the mnemonic for a key, you can import it with"
echo "desmos keys add <key-name> --recover"
echo "---------------"

echo "To configure your node further, see"
echo "https://docs.desmos.network/fullnode/setup.html"
echo "and"
echo "https://github.com/desmos-labs/morpheus/tree/master/morpheus-apollo-1"
echo "---------------"

echo "Before starting your validator, review the utility scripts at"
echo "https://github.com/patogit/cosmos-sdk-utils"
echo "and the repositories linked there."
echo "---------------"


echo "If you want to make any changes to you config,"
echo "restart desmos.service after making changes."
echo "---------------"

echo "To fetch a data backup via scp, you might use"
echo "scp -v user@ip.address:/home/user/.desmos/data-backup.tar.gz ."
echo "---------------"

echo "To the Earth!"
echo "---------------"
