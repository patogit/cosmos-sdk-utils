#!/bin/bash

# This script is part of a set of scripts that set up a node for the regen-1 mainnet of regen-ledger.
# Run this as a user that can sudo.
# This script puts things in ~/.profile with the assumption that you will run it from a non-login shell.
# If you prefer to do your operations from a login shell, change .profile to .bashrc.
# 1) Set up a non-root user and log in as that user.
# 2) Run the go-install.sh script.
# 3) Reboot.
# 4) Run this script to install regen-ledger and cosmovisor.
# ./2-sentinel-mainnet-install.sh v0.5.0 sentinelhub-1 "\"Akik Takat P2P 1\""

# Set versions of cosmos-sdk (for cosmovisor) and regen-ledger before running this script.
VERSION=$1
CHAINID=$2
MONIKER=$3

# Prepare the environment, fetch code, make and install regen-ledger

mkdir -p $GOPATH/src/github.com/sentinel-official
cd $GOPATH/src/github.com/sentinel-official
git clone https://github.com/sentinel-official/hub.git
cd hub
git fetch
git checkout $VERSION
make install

sentinelhubcli version
sentinelhubd version

# sentinelhubcli keys add --recover <name>
# sentinelhubd tendermint show-validator
# sentinelhubd init <moniker> --chain-id sentinelhub-1

echo "sentinel tools" $VERSION "built and installed. Press space to continue."
read -s -d ' '

# Create systemd service:
DAEMON_PATH=$(which sentinelhubd)

echo "[Unit]
Description=sentinelhubd daemon
After=network-online.target
[Service]
User=${USER}
ExecStart=${DAEMON_PATH} start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" >sentinelhubd.service

sudo mv sentinelhubd.service /lib/systemd/system/sentinelhubd.service

# After this command is run, cosmovisor is ready to start.
# If you reboot, cosmovisor will start -- be careful, since you might not be ready to start yet.

sudo systemctl daemon-reload && sudo systemctl enable sentinelhubd.service

sentinelhubd init --chain-id=$CHAINID $MONIKER

echo "Get mainnet genesis"
curl -s https://raw.githubusercontent.com/sentinel-official/launch/sentinelhub-1/sentinelhub-1/genesis.json > ~/.sentinelhubd/config/genesis.json
echo "Checksums"
sha256sum ~/.sentinelhubd/config/genesis.json
echo "79a2b73ed7ef35f767d1591a78086d594b11c65af75945e615371d35b94b613d"

echo "Verify that the two strings above are equal. Press space to continue."
read -s -d ' '

echo "Copy this string and push space when you're ready to paste it into the seeds section"
echo "c7859082468bcb21c914e9cedac4b9a7850347de@167.71.28.11:26656"
read -s -d ' '
nano ${HOME}/.sentinelhubd/config/config.toml

echo "edit app.toml to your liking"
read -s -d ' '
nano ${HOME}/.sentinelhubd/config/app.toml

sentinelhubd unsafe-reset-all

sudo systemctl start sentinelhubd.service

echo "---------------"
echo "---------------"
echo "Installation of sentinel tools complete."
echo "sentinelhub-1 mainnet now syncing."
echo "journalctl -u sentinelhubd -f will show you recent logs."

echo "---------------"
echo "If this is validator node or otherwise needs keys:"
echo "regen keys add <your-new-key>"
echo "Make sure you back up the mnemonics !!!"
echo "Or if you have the mnemonic for a key, you can import it with"
echo "regen keys add <key-name> --recover"
echo "---------------"

echo "To configure your node further, see"
echo "https://github.com/sentinel-official/docs/blob/master/guides/mainnets/sentinelhub-1/README.md"
echo "and"
echo "https://github.com/sentinel-official/launch"
echo "---------------"

echo "Before starting your validator, review the utility scripts at"
echo "https://github.com/swidnikk/regen-utils"
echo "---------------"


echo "If you want to make any changes to you config,"
echo "restart sentinelhubd.service after making changes."
echo "---------------"

echo "To fetch a data backup via scp, you might use"
echo "scp -v user@ip.address:/home/user/.regen/data-backup.tar.gz ."
echo "---------------"

echo "To the Earth!"
echo "---------------"
