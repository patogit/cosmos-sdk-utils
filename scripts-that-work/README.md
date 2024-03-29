When I create a new server, I specify that my SSH key should be used for login (if your host doesn't offer this option, then you can put your public key there manually with [these instructions](https://linuxhandbook.com/add-ssh-public-key-to-server/), then I login as root and run `new-server-user-setup.sh`. That disables password login and root login, so make sure the SSH keys are in `~/.ssh/authorized_keys` or else you'll get locked out of your server. That script reboots the server, and I login as the new user, and run `go-install.sh`, then reboot. Then run `regen-1-mainnet-install-cosmovisor-regen.sh` to install `regen-ledger` and `cosmovisor`. That script finishes with some recommendations for further steps.

Change the stuff at https://github.com/regen-network/mainnet/tree/main/regen-1#step-1-initialize-the-chain from regen-1 to devnet-5 if your putting the node on the devnet, and also look at https://github.com/regen-network/testnets#regen-devnet-5 for the faucet address, so that you can get tokens before running the create validator commands described here (change chaind-id to regen-1 or devnet-5): https://github.com/regen-network/testnets/tree/master/aplikigo-1#configure-your-validator.

UPDATE:
Script 1 now assumes Ubuntu. I'm using Ubuntu 20.04, haven't tested it elsewhere.
Script 2-go-install.sh is lo longer needed (it's distro agnostic, though, so you can use it if you don't use Ubuntu), so on Ubuntu use 2-go-path-setting.sh. Script 3 for Sentinel is working great!
Script 3 for Desmos is working great!
