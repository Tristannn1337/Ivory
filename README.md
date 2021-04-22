# The Ivory Protocol


## Mission Statement
Staking pools democratize participation in network operation incentives, but time tends to favor centralization and Ethereum relies deeply on decentralization. Ethereum needs a pooled staking protocol that democratizes participation while every validator in the network using it would not begin to challenge Ethereum's legitimacy.

Compared to existing pools, the Ivory Protocol's goal is to be...
-   Better for Operators
    -   Raise more principal and run more validators.
    -   Level playing field for all operators in the protocol.
    -   No 3rd party governance overhead.
-   Better for Pool Stakers
    -   Better guarantee of liquidity.
    -   Opportunities for higher yield.
        -   Because operators commit to an APR of their own choosing, transaction fees can be included 
    -   Opportunities for lower risk.
-   Better for Ethereum 
    -   No compromises on decentralization.
    -   Minimum possible trust.
    -   Market dictated risks and rewards.


## Overview
Central to the design of the Ivory Protocol is the **Validator Bond NFT**, a tokenized cryptoeconomic agreement node operators can enter into for raising funds to run more validators.

The protocol is made up of three basic parts:
1. Standardize the **issuing and redeeming** of Validator Bonds with **Ivory Ink**.
2. Facilitate a market for **buying and selling** Validator Bonds with **Ivory Bazaar**.
3. Pool together in a **tokenized fund** of Validator Bonds with **Ivory Parade**.

### IVRY Token
Intentions:
-   **Reputation**: Promote and retain operators who are good at their job in Ivory Bazaar.
-   **Curation**: Assign and adjust bond term derived quality ratings in Ivory Bazaar.
-   **Governance**: Community fund management of Ivory Parade.
-   Additional early-stage intentions:
    -   Incentivise early adopters to learn about and participate in the ecosystem
        -   airdrops
        -   temporary incentive boosts
    -   Fund development.

The IVRY Token is not directly involved with Ivory Ink in order to keep the protocol's foundation as simple and secure as possible.


## 1. Ivory Ink
Node Operator creates a **Validator Bond NFT** with terms they desire(principal, maturity, APR) by making their validator deposits through the Ivory Ink dApp. This sends their validator into the activation queue and issues the NFT to the Node Operator. Upon validator exit and withdrawal, the validator balance is released back into Ivory Ink and portioned out between the NFT bondholder and the Node Operator. 
-   To enforce liquidity for the bondholder, Ivory Ink penalizes operators who exit their bonded validator too early or too late. 
-   To reduce validator churn on the network, bond terms may be renewed by the bondholder before maturity.

Emphasis on cryptoeconomics is placed on this piece of the protocol to ensure the highest level of security possible. There is no DAO, no investment token, and the contracts are not upgradable. Ivory Ink is designed with the intention of being the bedrock and minimum viable protocol around which all other Ivory Protocol features may be built or creative use by other protocols.

### Bond Terms
-   **Principal** (ETH)
    -   The amount of ETH that the operator is raising out of 32.
    -   Limited to increments of 0.5 ether?
    -   Maximum of 30, minimum of 1
-   **Maturity** (Blocks)
    -   The number of blocks after deposit that the operator is committing to withdrawing the validator balance by.
    -   Enforced by penalties described in the cryptoeconomics withdrawal calculations section.
    -   Operator is given a grace period of +/- 7 days.
    -   Maximum of 30 years, minimum of 1 month
        -   May be smart to make the maximum be a function of how long the contract has existed... for example, upon deployment the maximum could be 1 year and over the course of the next 5-10 years the maximum would be interpolated to it's final value of 30. Would allow the contract to stand the test of time before allowing people to make such long term commitments.
-   **APR** (%)
    -   The reward rate the operator expects from the network, presumably discounted by their commission rate, and guaranteed to the bondholder.
    -   Maximum of 0.10, minimum of 0.01

### Withdrawal Calculations
Validator balance portioning between the NFT bondholder and node operator upon validator exit and withdrawal.
-   `grace_period = 7 days` _Hardcoded and based roughly on the longest expected period of nonfinality in a worst case scenario (2 weeks)._
-   `principal_yield =  APR / (total_blocks / 1 year) * principal`
-   `normalized_time_to_maturity = max(blocks_until_maturity - grace_period, 0) / maturity_term`
-   `early_withdrawal_penalty = max(withdrawal_balance - 32 - principal_yield, 0) * pow(normalized_time_to_maturity, 2)` _If a validator balance is withdrawn before the maturity block, a penalty is applied based on the number of blocks left until the maturity block with a quadratic bias towards lower penalties. The operator doesn't lose any of their own stake unless they were slashed by the network, in which case the slash is magnified._
-   `excess_rewards = max(withdrawal_balance - 32, 0) / total_blocks * max(blocks_past_maturity - grace_period, 0)` _If a validator balance is withdrawn past the maturity block, all additional rewards are allocated to the bondholder on top of APR being applied to the total duration._ **TODO: remove the additional APR penalty so that we avoid a situation where a validator may become valueless. IVRY stake already introduces a committed market penalty.**
-   `rewards_total = principal_yield + early_withdrawal_penalty + excess_rewards`
-   `final_development_fee = principal + rewards_total < withdrawal_balance && is_dev_fee_active ? rewards_total * 0.005 : 0` *0.5% development fee is taken out as long as the bond doesn't fail to deliver and if is_dev_fee_active when less than 30 years have passed since contract deployment and less than 100,000 ether in fees have been collected.*
-   `final_bond_value = min(principal + rewards_total - final_development_fee, withdrawal_balance)`
-   `final_operator_balance = withdrawal_balance - final_bond_value`

### Bond Renewal
-   Renewal proposals may only be put up for a vote by the operator.
-   May only occur before `maturity - grace_period - 14 days` and pass before `maturity - grace_period`.
-   A bondholder who rejects the proposal may be bought out by the node operator.

### Web dApp
**TODO: mockup**
-   **ETH Wallet**
    -   Deposit
    -   Withdraw
-   **Active Validator Bonds**
    -   Validator address
        -   Current Balance
    -   Terms (Principal, Maturity, APR)
    -   Token Balance
        -   Implied Value
    -   Trigger Withdrawal
    -   Renewals
        - Propose/Vote
        - Buyout no-votes and absent-votes
-   **Create New Validator Bond**
    -   Mirror of the official Ethereum deposit introduction
    -   Define terms, upload deposit.json, commit stake


## 2. Ivory Bazaar
Surface fundamental market demands.
-   Fractionalized Buy/Sell Orders
    -   Simple fractionalization of bond NFTs
-   Buy/Sell Order Ratings
    -   IVRY DAO controlled score derived from bond terms
-   Perpetual Renewal Voting
    -   bond fractions can be staked to force liquidation, or not to imply and allow automatic renewal
    -   unstaked fractions may still get liquidated
    -   liquidated fractions sit idle until claimed
-   Requires IVRY stake to list orders.
    -   Amount of IVRY staked becomes a 4th meta-bond term
    -   Orders are priority sorted based on the amount of IVRY staked.
        -   Orders with the highest IVRY stakes appear at the top of the order list.
        -   Orders with identical terms but less IVRY offered are not sold until all orders with higher IVRY stakes are filled.
    -   Reward operators who behave by minting `IVRY_stake * (APR / maturity)` new IVRY into their account on withdrawal.
    -   Encourages operators to spend IVRY more freely when listing orders, effectively giving better operators better service.
    -   Definition of behaving:
        -   did not fail to deliver
        -   did not withdraw early (outside of grace period)
        -   did not withdraw late (outside of grace period)
    -   Operators who fail to behave forfeit their IVRY stake to the bondholder.

### Web dApp
**TODO: mockup**


## 3. Ivory Parade
The frontier of casual tokenized pooled staking.
-   Indexed
    -   Flexible buy/sell orders with clamped term requirements and different target allocations
    -   (min/?)Max principal
    -   Min(/max?) APR
    -   Min(/max?) IVRY stake (Passed to insurance stakers on failure to behave)
-   Tokenized
    -   Running value counter and discounted average APR to tokenize stake
-   Liquidity Maximizing
    -   Target maturity date interval allocations
-   Fee-Farm Insurance Staking
    -   Pool Token holders may stake their tokens to provide insurance to the pool
    -   Token stakers earn an additional APR on their stake equal to the total token discount over total staked
    -   This means that if the insurance stake is 10% of the total pool, someone who stakes half of the insurance gets an extra 5%
    -   In the event that a bond fails to deliver, the insurance pool soaks up the damages before the rest of the pool does.
    -   Requires a time lock commitment, which may be renewed automatically or not.
-   IVRY DAO Controlled
    -   Index allocation, maturity interval, discount percentage, insurance time lock duration, and IVRY stake dials.
    -   May trigger a shutdown on further deposits, disabling bond renewal votes, forcing liquidation, and allowing only token redemption.
    -   May vote to relenquish all or individual controls, with an auto-relenquish of all controls over N years if no dial is adjusted or if a shutdown is triggered.
-   Not upgradible
    -   Instead of upgrades, new pools may be added to Ivory Bazaar and old pools may have a shutdown triggered.

### Web dApp
**TODO: mockup**


## Additional Information
-   As much of this that can be on an L2 should be. (Looking at you zkSync)
-   The exact design and mechanics Ivory Ink hinges on finalization of the post-merge withdrawal spec.
-   Validators will likely be allowed to assign the transaction fee coinbase to any address they wish for a period of time after withdrawals are enabled.

Everything about this project is a work in progress and subject to change.

0x2894690AC5Fcdc82aaa372e8bf85797C7e7B577C

### More Bond Product Ideas
-   Alternative Asset Denominated Orders?
    -   What if you could stake token, say DAI, and get the APR guarantee like you would in any other product listed. When the bond is redeemed, you could end up taking more or less than your share of the validator's balance, whatever is required to fulfill the order. Would possibly require a variation of the Ivory Ink contract.
-   Tokenized Quadratic Order Index
    -   Pool target allocation derived from weighted quadratic popularity of basic market orders
-   Keeper-driven Pool
    -   Incentivise Keepers to draw orders directly from the basic order market into a pool
    -   Avoids potentially manipulating/splintering the basic market, but requires much more complexity