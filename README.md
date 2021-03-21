![Ivory Protocol](https://github.com/Tristannn1337/Ivory/blob/main/LogoV1.png)

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

-   **Maturity** (Block)
    -   The block that the operator is comitting to withdrawing the validator balance by.
    -   Enforced by a **Late Withdrawal Penalty** and a **Early Withdrawal Penalty** described in the cryptoeconomics section.

-   **Annualized Yield** (%)
    -   The yield operator expects from the network, discounted by their comission rate, and guaranteed to the bond holder.

-   **Penalty Multiplier** (%)
    -   The yield multiplier applied to determine pentalty rates for withdrawing early or late.
    -   Allows operators to adjust risk propositions and justify different comission rates.

-   **Grace Period** (Blocks)
    -   Number of days before and after the maturity block when an operator may withdraw without penalty.

-   **Qualtiy Rating** (Score)
    -   A value given to a bond to make the buying process easier (and for sorting???)
    -   Possibly calculated only on the front end, and not in-contract... unless useful for sorting...
    -   Facilitate fund autonomy???
    -   **TODO: calculation**


Cryptoeconomics
---------------

-   **Late Withdrawal Penalty**
    -   If a validator balance is withdrawn past the maturity block, a penalty is calculated based on the number of blocks that have past since the maturity block.
    -   The intent is that the penalty would start negligibly low and increase over time, consuming any additional operator profit being earned within a few days, and start cutting into the operator's profits within a week.
    -   Calculated by interpolating between yield and multiplied yield over X number of blocks after the grace period.
        -   Over how many blocks does the yield interpolate? Grace period? So grace period serves two purposes?

-   **Early Withdrawal Penalty**
    -   If a validator balance is withdrawn before the maturity block, a penalty is calculated based on the number of blocks left until the maturity block.
    -   The intent is that the penalty would start out at it's highest and lower over time, reducing to nothing within days of the maturity block.
    -   **TODO: penalty equation** ... maybe an interpolation between either a hardcoded value or a multiple of the contract yield over the number of blocks until maturity, minus 5 days?

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
-   No insurance pool.
    -   **TODO: What happens if bonds fail to deliver?**
-   Token holders can place orders to redeem ETH from their tokens.
    - Filled when either someone else deposits ETH or when a bond in the pool is exercised.
- Node
    -   Watches for viable bonds when a sufficient deposit pool balance is available.
    -   Watches for bonds that are ready to be exercised.
    -   Would trigger a parameterless action on the smart contract and get a small kickback to cover gas and some.
    -   To easily decentralize the node, hook into a beacon with validators that can inject potential transaction(s) upon being selected submitting a block proposal.
