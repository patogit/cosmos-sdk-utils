#!/bin/bash
# This script assumes it will be run by root.
# This script uses one argument: the name of the new user.
# If this script succeeds, but you did not have any SSH keys setup for logging in,
# then you will be locked out of your server.

NEWUSERNAME=$1

echo "Creating a new user named $NEWUSERNAME."
useradd -m $NEWUSERNAME 
usermod -a -G sudo $NEWUSERNAME

echo "Please set a password for $NEWUSERNAME:"
passwd $NEWUSERNAME

echo "Updating the system."
apt update && sudo apt upgrade
apt install build-essential jq -y

echo "Copying SSH keys to $NEWUSERNAME home directory."
rsync --archive --chown=$NEWUSERNAME:$NEWUSERNAME ~/.ssh /home/$NEWUSERNAME

echo "Disabling root login via SSH."
echo "Now you manually set PermitRootLogin no and PasswordAuthentication no."
echo "Press space to begin editing, and ctrl-x when done editing."
read -s -d ' '
nano /etc/ssh/sshd_config
service sshd restart

echo "Finished setup. Press space to reboot, or ctrl-c to exit this script."
read -s -d ' '
reboot now
