#!/bin/bash
# This script uses one argument: the name of the new user.

NEWUSERNAME=$1

echo "Creating a new user named $NEWUSERNAME."
useradd -m $NEWUSERNAME 
usermod -a -G sudo $NEWUSERNAME

echo "Please set a password for $NEWUSERNAME:"
passwd $NEWUSERNAME

echo "Copying SSH keys to $NEWUSERNAME home directory."
rsync --archive --chown=$NEWUSERNAME:$NEWUSERNAME ~/.ssh /home/$NEWUSERNAME

echo "Disabling root login via SSH."
echo "Set PermitRootLogin no and PasswordAuthentication no."
echo "Press space to begin editing, and ctrl-x when done editing."
read -s -d ' '
nano /etc/ssh/sshd_config
service sshd restart

echo "Updating the system."
apt update && sudo apt upgrade
apt install build-essential jq -y

# echo "Switching to new user's home directory."
# cd /home/$NEWUSERNAME

# echo "Fetching Regen Network testnets repo."
# git clone https://github.com/regen-network/testnets.git
# chmod a+x testnets/scripts/{devnet-val-setup.sh,gen_val_keys.sh}

echo "Finished setup. Press space to reboot, or ctrl-c to exit this script."
read -s -d ' '
sudo reboot now
