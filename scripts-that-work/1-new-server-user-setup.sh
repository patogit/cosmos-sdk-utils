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
sudo add-apt-repository ppa:longsleep/golang-backports
apt update && apt upgrade -y
apt install build-essential jq fail2ban golang-go -y

echo "Copying SSH keys to $NEWUSERNAME home directory."
rsync --archive --chown=$NEWUSERNAME:$NEWUSERNAME ~/.ssh /home/$NEWUSERNAME

echo "Disabling root login via SSH."
echo "Now you manually set PermitRootLogin no and PasswordAuthentication no and custom port."
echo "Press space to begin editing, and ctrl-x when done editing."
read -s -d ' '
nano /etc/ssh/sshd_config
service sshd restart

echo "Setting up Fail2Ban - enabled ssh, bantime, maxretry"
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
echo "Press space to begin editing, and ctrl-x when done editing."
read -s -d ' '
nano /etc/fail2ban/jail.local
sudo service fail2ban start && sudo service fail2ban enable
echo "The following should reflect the new fail2ban rules"
iptables -L

echo "Finished setup. Press space to reboot, or ctrl-c to exit this script."
read -s -d ' '
reboot now
