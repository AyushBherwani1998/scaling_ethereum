

![Build Status](https://img.shields.io/badge/build-passing-green?style=for-the-badge&logo=build)
![Solidity](https://img.shields.io/badge/solidity-yellow?style=for-the-badge&logo=solidity)
![SwiftUI](https://img.shields.io/badge/swiftui-yellowgreen?style=for-the-badge&logo=SwfitUI)
![Curvegrid](https://img.shields.io/badge/Curvegrid-blue?style=for-the-badge&logo=Curvegrid)
![EthSign](https://img.shields.io/badge/EthSign-orange?style=for-the-badge&logo=EthSign)
![ERC 4337](https://img.shields.io/badge/4337-lightgrey?style=for-the-badge)






<h3 align="center">Sage Wallet</h3>
<img src="https://imgur.com/P50ie70.png" title="source: imgur.com" /></a>

## Overview

Sage is an ERC 4337 wallet with MPC(TSS) key management that uses attestation, device and Oauth factors for better UX and a highly secure experience



## Description


Sage wallet looks to bring together the goodness of MPC and AA wallets and builds on top to solve the following

Pain Point: Single storage of mnemonics/PK
Solution: Utilizing MPC (TSS) technology, Sage disperses keys across multiple factors chosen by the user.

Pain Point: Claiming ownership to import/recover only via mnemonics
Solution: Claim ownership by integrating OAuth authentication with encrypted Attestations, ensuring secure wallet import and recovery.

Pain Point: Exposing the EOA to interact and connect to protocols
Solution: ERC 4337 wallet using smart contracts to interact with protocols



## How it's Made

<img src="https://imgur.com/8mapy8P.png" title="source: imgur.com"/></a>

First, we authenticate use using the Firebase Google login and obtain the Firebase credentials. The next step is to authenticate the credentials on the Web3Auth Network and generate an OAuth Private key using JWT. Once, the OAuth private key (Single Factor Auth) flow is completed, we use it as one of the factors for the MPC. We used a low-level SDK of Web3Auth for MPC and TSS singing. For the first-time user, we generate the device factor and add it as a second factor for the MPC. The user can retrieve the MPC account on that device using the OAuth login.

Once, a new MPC account is created, we make the ERC 4337 wallet using the MPC account. For ERC4337 we have used the eth infinitism account abstraction contracts. We also use the CurveGrid Cloud wallet as a paymaster to drop some native tokens to cover the fee to create the ERC4337 wallet.

Users can add additional factors to the MPC account, like on-chain attestation. For on-chain attestation, we have used the Sign Protocol. Adding an on-chain attestation allows the user to claim the account on any other device by the OAuth login. This significantly improves the UX and reduces the entry barrier for non-tech people.

The most difficult thing was to make this all work on native iOS. The Sage Wallet is a mobile wallet built using the native iOS. There were a lot of difficulties in interacting and managing the AA wallet in iOS, as no SDKs were maintained. All the sponsors had the JS SDKs, so we had to write the barebone to make this wallet come to life.






