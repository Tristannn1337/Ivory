# The Ivory Protocol
Ethereum Staking Validator Contracts

Problem
=======

All existing examples of ETH2.0 Staking Pools involve either dependence on a centralized authority or DAO governance. While neither of these poses an immediate risk, time tends to favor singular solutions and network dominance of either of these types of pools would be devastating. We need a protocol that gives node operators the power to participate in the staking pool market while remaining independent of any larger organization. We need a protocol that, if it were to be used by every single validator in the ecosystem, would not create a challenge to Ethereum's legitimacy. More specifically, we need a protocol that:

-   Involves minimum trust
-   Is fully decentralized
-   Allows for market-driven risk and rewards
-   Facilitates tokenized staking for casual ETH holders
-   Facilitates stake liquidity
-   Does not involve a node operator DAO

And as a bonus, while this proposal's primary intention is to facilitate contracts between strangers, it can just as easily be used to facilitate contracts between people who know each other.

Proposal: Validator Contract NFTs
=================================

Standardize and facilitate the creation, selling, purchasing, and exercising of contracts between Ethereum Node Operators and Ethereum holders via smart contracts.

Example Story
-------------

A node operator mints a new Validator Contract NFT through the dApp with the terms they desire, a typical staking deposit.json file, and a deposit of 32 ETH that is then forwarded to the formal deposit contract with a withdrawal address pointing to the Ivory Vault. Upon success, the operator possesses a Validator Contract NFT with a token balance of 32 minus their bond. The operator may then sell the NFT tokens to one or more buyers.

Fast forward to some time near the expiration date of the contract when the operator exits their validator. Once exited, the operator triggers a withdrawal through the dApp which communicates with the ETH2.0 withdrawal contract to pull the funds into their dApp ETH balance and close the Validator Contract. Later, the Validator Contract NFT holder sees the contract has been closed and burns their NFT balance to withdraw their portion of the stake from the Ivory dApp.

Contract Standard
-----------------

-   Operator Bond (ETH)
    -   The amount of ETH that the operator is committing out of 32

-   Reward Guarantee (ETH)
    -   The reward size that the operator is guaranteeing.
    -   This amount would be some percentage point below what the operator expects to make.
    -   If the operator fails by exiting early, network non-finality, getting slashed, or too much downtime... the operator bears the entire burden of the guarantee.
    -   The only way a guarantee will fail to deliver is if the entire withdrawn stake isn't enough to cover it.

-   Expiration Date (YYMMDD)
    -   The validator stake must be withdrawn by the expiration date or face penalties as described by the Failure to Withdraw Leak Rate.

Contract Notation
-----------------

-   16S 0.3R E220301 -> 16ETH Stake(16ETH Bond), 0.3 ETH Guaranteed Reward, Expires March 1st, 2022.
-   28S 0.5R E210601 -> 28ETH Stake(4ETH Bond), 0.5 Guaranteed Reward, Expires July 1st, 2021

Cryptoeconomics
---------------

-   Failure to Withdraw Leak
    -   Additional reward rights are given to NFT from the Operator's portion of the rewards for each block that the operator is late exiting.

Scenarios
---------

-   A validator never exits and keeps validating indefinitely, never releasing funds. No one wins, the operator continues to spend electricity to keep the node validating. Highly unlikely to ever occur.
-   Operator fails at their job, the validator is forced to exit, and the Ivory NFT fails to deliver on its reward guarantee. It would take a spectacular failure for this to occur, and the risk can be controlled by only purchasing higher bond Ivory NFTs.

Ecosystem Expansion
===================

1.  **Dedicated Marketplace dApp**
    1.  A dedicated marketplace for Validator Contract NFTs is necessary for demand transparency.

3.  **Tokenization via crypto-ETF**
    1.  Supports a market for low-bond contracts by diluting the risk associated with them.
    2.  Allows casual investors to participate without needing to actively manage Ivory NFTs.
    3.  Token redemption and minting are solvable but outside the scope of this document. 

Funding
=======

-   Implement a small house fee on validator withdrawal.
-   There is a maximum amount of fees and end date where they are no longer collected and the contract effectively auto-exits-to-the-community.
-   Once you're ready with a whitepaper and a website, sell the rights to x percent of the first y amount of ETH that is made in fees. So, maybe sell 60% of the first 200 ETH for 40ETH... or something exponential where the first people who fund you have the biggest incentive while the last people have the smallest. And try to give yourself like... maybe 300k in funding? And a public investment target that will allow you to quit your current job and work on this full time?
-   Additional fees can be extracted from the exchange marketplace and possibly the crypto-ETF.

Hosted Website
==============

-   [P0] **Quick Introduction**
-   [P0] **Link to dApp**
-   [P0] **Documentation**

    -   Vision/Mission
    -   How it works

-   [P0] **Social Links**

IPFS dApp
=========

-   [P0] **Dashboard**
    -   ETH Balance
        -   Deposit
        -   Withdraw
    -   Active Validator Contracts *(maybe only visible to people who have identified themselves as operators somehow?)*
        -   Value, Expiration, Validator link
        -   Trigger Withdrawal
        -   Create New Validator Contract
            -   Mirror of the official Ethereum deposit introduction
            -   Define terms, upload deposit.json, commit stake
    -   NFT Balances
        -   Value, Expiration, Validator link
        -   Trigger Withdrawal
        -   Burn for ETH

-   [P1] **Order Book**
    -   Visualizer
    -   Buy NFTs
        -   Fill existing sell orders
        -   Create new buy orders
    -   Sell NFTs
        -   Fill existing buy orders
        -   Create new sell orders

-   [P2] **ETF Token** (separate dApp, requires oracle/node/DAO)
    -   Validator Contract Terms distribution
    -   Token Value
    -   Mint Instantly
        -   Auto-generates buy orders owned by ETF if no burn-orders are active.
    -   Create burn order
        -   Allocates ETH from Burns to orders until filled
        -   Allocates ETH from Mints to orders until filled
