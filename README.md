![Ivory Protocol](https://github.com/Tristannn1337/Ivory/blob/main/LogoV1.png)

# The Ivory Protocol
Ethereum Staking Validator Contracts

Problem
-------------

Ethereum needs a pooled staking protocol that, if it were to be used by every single validator in the ecosystem, would not begin to challenge to Ethereum's legitimacy. All existing staking pools involve either a centralized authority or DAO governance, when all we need is a simple protocol that facilitates the market between node operators and ether holders.  More specifically, we need a protocol that:

-   Involves minimum possible trust
-   Is fully decentralized
-   Allows the market to dictate risks and rewards
-   Facilitates stake liquidity back to ether holders
-   Facilitates tokenized staking for casual ETH holders


Proposal: Validator Contracts
-------------

Standardize and facilitate the creation, selling, purchasing, and exercising of **Validator Contracts** between Ethereum Node Operators and ether holders through smart contracts.

Example Story
-------------

A Node Operator creates a new Validator Contract with the terms they desire, such as the bond they're comitting, the expiration date of the contract, and what the value guarantee is of the contract at expiration. Then, they upload a typical staking deposit.json file and a send deposit of 32 ETH. Upon success, their validator has entered the activation queue and the Node Operator possesses NFT tokens from their Validator Contract that they may sell in the Validator Contract market. Likewise, an ether holder may visit the Validator Contract market, purchasing some with terms they agree to for the price that the contract is selling for.

Fast forward to the expiration date set in the terms of a Validator Contract. The validator bonded to the contract has exited and the operator triggers a withdrawal transaction to pull the validator's balance into the protocol. The Node Operator withdraws their portion of the balance and starts over. Later, as Validator Contract token holders see their funds are available, they exercise their token balance to withdraw their portion.


Contract Standard
-----------------

-   **Operator Bond** (ETH)
    -   The amount of ETH that the operator is committing out of 32

-   **Reward Guarantee** (ETH)
    -   The reward size that the operator is guaranteeing for the tokens.
    -   This amount would be some percentage point below what the operator expects to make.
    -   If the operator fails by exiting early, network non-finality, getting slashed, or too much downtime... the operator bears the entire burden of the guarantee.
    -   The only way a guarantee will fail to deliver is if the entire withdrawn stake isn't enough to cover it.

-   **Expiration Date** (YYMMDD)
    -   The validator stake must be withdrawn by the expiration date or face penalties as described by the Failure to Withdraw Leak Rate.


Cryptoeconomics
---------------

-   **Failure to Withdraw Leak**
    -   Additional reward rights are given to NFT from the Operator's portion of the rewards for each block that the operator is late exiting.

-   **Temporary Development Fee on Withdrawal**
    -   When a validator's balance is withdrawn and the balance is portioned out to the operator and token holders, a small development fee may be taken from the realized profits.
    -   These fees expire after either a predetermined amount of time or if a ceiling has been reached for total fees extracted.
    -   The terms of this fee is subject to change, but currently stands at 0.5% for 30 years or until 100,000 ether has been collected.
    -   This fee is intentionally taken out at withdrawl, not at sale, in order to avoid ever profiting from contracts that fail to deliver.


Design Considerations
-------------

-   This whole protocol hinges on the final withdrawal spec supporting the means for smart contracts to attribute a withdrawal balance to a specific validator. It doesn't much matter how that happens, but I would prefer a method that allows a single smart contract withdrawal address to be assigned to any number validators as to avoid needing to deploy a new smart contract for every validator that uses this protocol. Suggestions:
    -   Allow validator state to be queryable.
    -   Limit withdrawal transaction senders to the withdrawal address with a validator pubkey arg.

-   Things to graph/create a claculator for
    -   At what point would the expiration date be so far out that the operator bond wouldn't cover an exit tomorrow?
    -   Risk
        -   Assuming a validator is slashed immediately and leaks into exiting, how much of the guarantee would be fulfilled?
            -   If all with plenty left over, then risk is considered very low
            -   If there's just enough to cover it, then risk is considered low
            -   Risk also increases with lower bonds to reflect the higher probability of the contracts being used in an attack
                -   probably an exponential increase
    -   Value
        -   Guarantee - price
        -   Could the premium `price-(32-bond)` get locked up only to be realized at withdrawal?
        -   Or does it matter? I mean... that's kinda cool that, as a node operator, you get a small payment up front. But does that open up an attack vector or anything? You'd have to make something like a 3 year contract where you take 30% with a 1ETH bond to maybe potentially exploit it... maybe that's a good enough reason to set the minimum bond at 2ETH?
    -   Minimum predicted APY
        - (Guarantee-(32-Bond))/lifetime
    -   Failure to Withdraw leak
    -   Bond coverage to lifetime ratio
        -   Longer lifetimes will require larger bonds to cover potential loss
        -   Shorter lifetimes require less bond to cover potential loss
        -   What does this relationship look like?


Worst Case Scenarios
---------

-   A validator never exits and keeps validating indefinitely, never releasing funds. No one wins, the operator continues to spend electricity to keep the node validating. Highly unlikely to ever occur.

-   Operator fails at their job, the validator is forced to exit, and the Ivory NFT fails to deliver on its reward guarantee. It would take a spectacular failure for this to occur, and the risk can be controlled by only purchasing higher bond Ivory NFTs.


Development Phases
-------------

1.  **Phase 1 - Validator Contracts + Marketplace**
    -   Website/dApp
    -   Simple Smart Contract Wallet
    -   Base Protocol implementation
    -   A dedicated marketplace built specifically for buying and selling Validator Contracts.
    -   Necessary for giving ether holders a voice in the market.
    -   Will likely involve another temporary development fee on transactions.

2.  **Phase 2 - Tokenization via crypto-ETF**
    -   Supports a larger market for low-bond contracts by diluting the risk associated with them.
    -   Allows casual investors to passively participate.
    -   Will require a DAO and Oracle(s).
    -   Will involve a permanent DAO fee.
    -   May be better handled by an existing crypto-ETF protocol/DAO.


Hosted Website
-------------

-   **Quick Introduction**
-   **Link to dApp**
-   **Documentation**
    -   Vision/Mission
    -   How it works

-   **Social Links**


IPFS dApp
-------------

-   **Dashboard**
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

-   **Order Book**
    -   Visualizer
        -   Risk
        -   Intrinsic Value
        -   Historical Sale Price
    -   Buy NFTs
        -   Fill existing sell orders
        -   Create new buy orders
    -   Sell NFTs
        -   Fill existing buy orders
        -   Create new sell orders

-   **ETF Token** (separate dApp? requires oracle/node/DAO)
    -   Validator Contract Terms distribution
    -   Token Value
    -   Mint Instantly
        -   Auto-generates buy orders owned by ETF if no burn-orders are active.
    -   Create burn order
        -   Allocates ETH from Burns to orders until filled
        -   Allocates ETH from Mints to orders until filled
