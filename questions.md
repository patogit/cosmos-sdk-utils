# Open Questions

How can I put more than 5k tx in a single block?

How can I put more than 5k messages in a single tx?

Where is a script to do both of those things?

What sequence of commands will build an transaction with multiple messages in a single transaction and then broadcast it in a single block? Something like regen tx bank send --offline --generate-only | regen tx sign - --offline | regen tx encode - --offline | regen tx broadcast - --broadcast-mode block but with more variables and maybe a loop in there somewhere.

What does each type of --broadcast-mode do? (sync, async, block) (I see that block works the best right now but async supposedly allows multiple tx in a single block)

What flags actually apply to each command? (the regen tx broadcast --help page, for example, has a bunch of flags that I think probably don't apply)

How can I find out the account number and sequence number for my address? regen query account <my-delegator-address>

When does it make sense to use the different --sign-modes? 

How can I make the transaction go with a single command, without having to type in my keyring passphrase? echo <mypassword> | regen tx bank ....

What are some examples of when we might use sign and when sign-batch?

What would happen if I make 5k wallets on a single node and then run a tx send from each wallet to itself? (I think @gotjoshua tried to do this)

What are the mempool settings? How can I see them? How can I change them?

What limits the number of tx my validator will process in a single block? How can I change that?

What are other projects using Cosmos SDK that already have documentation about these things or other stuff? Akash, Kava, Terra, EthereumBridge. https://github.com/lightiv/SkyNet/wiki , https://github.com/enigmampc/EthereumBridge/commit/d15310c11c5951282536d6a07bb247a0b32983f7, https://medium.com/kava-labs/guide-to-joining-the-kava-testnet-9e697d381e07, https://github.com/terra-project/terra.js/wiki/Transactions

How can we use golang to construct a block?

What are different ways to classify nodes? What are types of node in each class?

What happened with that alternative TxClient interface? Can I use it? Does it require building a new regen binary?

In production, when might offline block construction be useful?
