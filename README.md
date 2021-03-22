![Ivory Protocol](https://github.com/Tristannn1337/Ivory/blob/main/LogoV1.png)

![One Page](https://github.com/Tristannn1337/Ivory/blob/main/one-page.png)


# The Ivory Protocol
Ethereum Validator Bond NFTs and Fund Tokens


Problem
-------------

Ethereum needs a pooled staking protocol that, if it were to be used by every single validator in the ecosystem, would not begin to challenge to Ethereum's legitimacy. All existing staking pools involve either a centralized authority or DAO governance, when all we need is a simple protocol that facilitates the market between node operators and ether holders. Specifically, we need a protocol that:

-   Involves minimum possible trust
-   Is fully decentralized
-   Allows the market to dictate risks and rewards
-   Facilitates stake liquidity back to ether holders
-   Facilitates tokenized staking for casual ETH holders


Proposal: Validator Bond NFTs and Fund Tokens
-------------

Standardize and facilitate the creation, selling, purchasing, and exercising of **Validator Bonds** between Ethereum Node Operators and ether holders and create a tokenized fund of bonds for the most casual ether holders.


Example Story
-------------

A Node Operator creates a new validator bond with the terms they desire(principal, maturity, yield, etc), they upload a typical staking deposit.json file and a send deposit of 32 ETH. This sends their validator into the activation queue and the Node Operator now possesses NFT tokens representing the principal of their bond that they may sell in the market. Likewise, an ether holder visits the validator bond market, finds one with a satisfying quality rating, and purchases either some or all of the principal.

Fast forward to the bond maturity date, the bonded validator has exited and the operator triggers a withdrawal transaction to pull the validator's balance into the protocol. The Node Operator withdraws their portion of the balance and starts over. Later, as bond rights holders see their funds are available, they exercise their rights to withdraw their portion of the balance.

In the background, there is a pool watching for high quality bonds and buying them as well as exercising rights to any that are ready. More casual investors are depositing funds into this pool in exchange for pool tokens and letting it's automatic purchasing and exercising do the hard work for them, knowing that they can submit an order at any time to redeem their pool tokens to collect back their deposit and yield.


# Phase 1 - Bond Marketplace


Contract Standard
-----------------

-   **Principal** (ETH)
    -   The amount of ETH that the operator is raising out of 32.
    -   Limited to increments of 1 ether?

-   **Maturity** (Block)
    -   The block that the operator is comitting to withdrawing the validator balance by.
    -   Enforced by a **Late Withdrawal Penalty** and a **Early Withdrawal Penalty** described in the cryptoeconomics section.

-   **APR** (%)
    -   The reward rate the operator expects from the network, discounted by their comission rate, and guaranteed to the bond holder.

-   **Grace Period** (Blocks)
    -   Number of blocks before and after the maturity block when an operator may withdraw without penalty.
    -   Should be hardcoded to one week. One week early and one week late.

-   **Qualtiy Rating** (Score)
    -   A value given to a bond to make the buying process easier (and for sorting???)
    -   Possibly calculated only on the front end, and not in-contract... unless useful for sorting...
    -   Facilitate fund autonomy???
    -   **TODO: calculation**


Cryptoeconomics
---------------

-   **Late Withdrawal Penalty**
    -   If a validator balance is withdrawn past the maturity block, all additional operator rewards are allocated to the bond on top of the APR being applied to the total duration.
        -   excess_rewards = (withdrawal_balance - 32) / total_blocks * max(blocks_past_maturity - grace_period, 0)
        -   principal_yield = principal * (APR / total_years)
        -   bond_value = min(principal + principal_yield + excess_rewards, withdrawal_balance)
        -   operator_balance = withdrawal_balance - bond_value

-   **Early Withdrawal Penalty**
    -   If a validator balance is withdrawn before the maturity block, a penalty is calculated against the operator's rewards based on the number of blocks left until the maturity block with a quadratic bias towards lower penalties. This means operators who exit early keep less of their accumulated rewards. This doesn't mean the operator would lose any of their stake,unless they were slashed by the network in which case the slash is magnified.
        -   principal_yield = principal * (APR / total_years)
        -   normalized_time_to_maturity = max(blocks_until_maturity - grace_period, 0) / maturity_term
        -   early_withdrawal_penalty = (withdrawal_balance - 32 - principal_yield) * pow(normalized_time_to_maturity, 2)
        -   bond_value = min(principal + principal_yield + abs(early_withdrawal_penalty), withdrawal_balance)
        -   operator_balance = withdrawal_balance - bond_value

-   **Temporary Development Fee on Withdrawal**
    -   When a validator's balance is withdrawn and the balance is portioned out to the operator and token holders, a small development fee may be taken from the realized profits.
    -   These fees expire after either a predetermined amount of time or if a ceiling has been reached for total fees extracted.
    -   The terms of this fee is subject to change, but currently stands at 0.5% for 30 years or until 100,000 ether has been collected.
    -   This fee is intentionally taken out at withdrawl, not at sale, in order to avoid profit from contracts that fail to deliver.


Design Considerations
-------------

-   This whole protocol hinges on the final withdrawal spec supporting the means for smart contracts to attribute a withdrawal balance to a specific validator. It doesn't much matter how that happens, but I would prefer a method that allows a single smart contract withdrawal address to be assigned to any number validators as to avoid needing to deploy a new smart contract for every validator that uses this protocol. Suggestions:
    -   Allow validator state to be queryable.
    -   Limit withdrawal transaction senders to the withdrawal address with a validator pubkey arg.
    
-   The Ivory Exchange should limit partial orders to increments of 0.01 ether


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


# Phase 2 - Tokenization via Bond Fund

-   Only purchases bonds with quality rating above a certain amount.
    -   Possibly also allowing a portion of the pool to come from lower quality ratings.
-   How are bond tokens valued?
    -   Simply by the implied value of the underlying bonds plus the deposit pool over the number of tokens issued?
-   No oracle is needed.
-   Insurance pool?
    -   Might be good for the fund to put aside it's own fee strictly for covering this scenario?
    -   Maybe the listed yield for the pool could be variable based on how large the insurance pool is...
        -   When the insurance pool is completely empty, the yield is at it's lowest
        -   When the insurance pool is maxed out, the yield is at it's highest
        -   The insurance pool size shoud probably be relative to the size of the fund
        -   **TODO: determine how large the insurance pool should be**
-   Token holders can place orders to redeem ETH from their tokens.
    - Filled when either someone else deposits ETH or when a bond in the pool is exercised.
-   Node
    -   Watches for viable bonds when a sufficient deposit pool balance is available.
    -   Watches for bonds that are ready to be exercised.
    -   Would trigger a parameterless action on the smart contract and get a small kickback to cover gas and some.
    -   To easily decentralize the node, hook into a beacon with validators that can inject potential transaction(s) upon being selected submitting a block proposal.
-   Limited Development fee similar to base protocol
    -   Not to be extracted unless insurance pool is maxed out.
