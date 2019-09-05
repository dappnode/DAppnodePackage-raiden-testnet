# DAppnodePackage-raiden-testnet
[![DAppNodeStore Available](https://img.shields.io/badge/DAppNodeStore-Available-brightgreen.svg)](http://my.admin.dnp.dappnode.eth/#/installer/raiden-testnet.dnp.dappnode.eth)

This is a package to deploy a [Raiden node](https://raiden.network/) in a DAppNode.

This package is for development purposes only, to be deployed on any testnet.

The Raiden Network is an off-chain scaling solution, enabling near-instant, low-fee and scalable payments. It’s complementary to the Ethereum blockchain and works with any ERC20 compatible token.

See the [documentation](https://raiden-network.readthedocs.io/en/stable/index.html) for more information.


# Build prerequisites

- git

   Install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) commandline tool.

- docker

   Install [docker](https://docs.docker.com/engine/installation). The community edition (docker-ce) will work. In Linux make sure you grant permissions to the current user to use docker by adding current user to docker group, `sudo usermod -aG docker $USER`. Once you update the users group, exit from the current terminal and open a new one to make effect.

- docker-compose

   Install [docker-compose](https://docs.docker.com/compose/install)
   
**Note**: Make sure you can run `git`, `docker ps`, `docker-compose` without any issue and without sudo command.


## Building

`docker-compose build`


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Note

This is early stage software

# How to use this package

Raiden is available in DAppNode on mainnet and the different testnets.

For the purposes of this use guide we will use Raiden testnet over Göerli using the Görli-Geth DappNode package.

If you do not have the Görli Geth Package installed it will automatically get installed when you install Raiden.

If you alreaddy have the Görli-Geth package installed just make sure that you are running it with these flags ```--rpcapi eth,net,web3,txpool``` set in the Environment Variables field of the package. 

In case Görli-Geth gets installed together with the Raiden package (they are bundled in the installation) the mentioned flags will be included in the Göerli installation by default.

## Steps summary

* Install the testnet Raiden package (bundled with Görli-Geth) in the installer section of your DAppNode's admin UI.

* Enter your WEB UI in  http://raiden-testnet.dappnode

* Join Networks and Open channels 

* Start sending tokens!


## Step by step 

### Installing Raiden and getting a prefunded keystore account in the blink of an eye

* Enter your DAppNode admin UI and go to installer 

* Install Raiden testnet package 

![](https://i.imgur.com/X1bJCJF.png)

* In the installation a new account is automatically created and funded for you to immediately start using the Raiden Network. 


If the steps have run correctly, you will see these logs within the Raiden testnet package (at the bottom of the screen).

![](https://i.imgur.com/tiThhBI.png)


Now you can access the [Raiden UI](http://raiden-testnet.dappnode) and start sending tokens.

## Running Raiden with different testnets

In case that you want to run the Raiden testnet package against a different testnet than Görli, you will have to substitute the endpoint and the network id for the concrete testnet you want to use, for example for Rinkeby, use as endpoint http://rinkeby.dappnode:8545 and as network id "rinkeby"(And remember to setup the same flags as in Görli in the environment variables of the testnet)

## Raiden UI

When you are connected to your DAppNode you can access your Raiden Testnet Web UI by typing http://raiden-testnet.dappnode

![](https://i.imgur.com/MW6PnvR.png)



In the tokens tab you will see the current token balances in that account:



![](https://i.imgur.com/ZKr63TQ.png)



## Joining networks and opening channels

To open channels and make instant payments with a certain token, you can do it by joining a network by clicking the button placed at the right of the token ticker and data, or by directly opening channels for a certain token with a certain address

In this case we will use the DAppNode Test Token Token that has a balance of 1000.

![](https://i.imgur.com/AXGAznc.png)


You will be asked the amount of tokens that you want to allocate. In this case we will allocate the whole balance.

![](https://i.imgur.com/ktIqrhm.png)




Once you have joined a network and allocated funds to it, Raiden will start to automatically open channels for you with 60 % of your available balance to provide routing capacity. The other 40% is allocated to fund channels with other nodes joining the network. Still, you will be able to send these tokens to different addresses with which you have opened channels, up to the amount you allocated to that network. 

You can access the complete Raiden Documentation in this [link](https://raiden-network.readthedocs.io/en/stable/), and you can also jump into the Raiden's gitter channel [here](https://gitter.im/raiden-network/) 


## Backup of your account

When you install the Raiden testnet package in your DAppNode a testnet account is automatically created and funded.

If you want to have a backup of that account follow these steps.

* Enter the Raiden Package in the packages tab and scroll down to File Manager
* Write "keystore" in the "Download from DNP" field 
* Hit download

![](https://i.imgur.com/PoALyud.png)


A compressed file called "keystore" will be dowloaded containing both the keystore file and the password (the latter as a hidden file)

## Using Raiden with different accounts

If you have a keystore with Gö-ETH and tokens and you prefer to use that one, you can do so by uploading your keystore file to the Raiden DAppNode Package (DNP) and by writing the address and password of your keystore in the environment variables field.

* Go to File manager
* Hit browse and select your keystore file
* Click upload without need to write anything in the path field

![](https://i.imgur.com/2NK4EV2.png)


Your keystore is now uploaded. Now we need to tell the package that you want to use that keystore

* Go to Environment Variables
* Type the password of your newly uploaded keystore (address is not needed, it will be automatically detected)
* Hit update environment variables

![](https://i.imgur.com/sjKiw1s.png)


You are done!

When you go to the [Raiden ADMIN UI](http://raiden-testnet.dappnode) you will see your custom account. 

As long as you have the keystore uploaded to the package you can use any account just by typing its password in  the Environment variables field of the package and hitting Update, just the password, you do not need to write the address, the account will be  recognized and you will be using that account when accessing the UI.

## Switching back to the default account created in the installation

Just go to Raiden package screen, delete the address and password from the fields and hit "Update environment variables". Your account in the UI will be now the one that was created in the installation.

If you have downloaded your default keystore and password, of course you can also type the password, but if you leave the address and password field blank it will also work. 

Now you are ready to enjoy fast, cheap, and scalable token transfers for Ethereum. 
