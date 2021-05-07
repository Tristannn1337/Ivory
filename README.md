# The Ivory Protocol

NOTE: This project has been abandonded for the time being. Without control over directing transaction fees or MEV into the validator balance, it becomes possible at that proposing blocks has greater value to the operator than the operator's initial stake. It's unclear at this time if there is a stake high enough to offset this, if more operator value will ever be directed into the validator balance, or if the ultimate solution to the goals of this project will be influnced by near-future protocol-level changes that open up better potential designs.

## Mission Statement
Staking pools democratize participation in network operation incentives but do a poor job of decentralizing infrastructure. History has shown that time tends to favor pool centralization and Ethereum relies deeply on infrastructure decentralization. Ethereum needs a pooled staking protocol that democratizes participation while also decentralizing infrastructure such that every validator in the network using it would not begin to challenge Ethereum's legitimacy.

Compared to existing pools, the Ivory Protocol's goal is to...
-   Create a single open market where all operators, solo and small business, can compete for staker ether.
-   Allow solo operators to raise more principal and run more validators.
-   Minimize governance overhead.
-   Offer stakers a better guarantee of liquidity.
-   Offer stakers opportunities for higher yield and/or lower risk.
-   Decentralize infrastructure.
-   Minimize trust.


## Overview
Compared to the typical service-oriented relationship that most if not all existing pools have with stakers, the Ivory Protocol reframes the relationship as operators raising money by issuing bonds to investors.
Central to the design of the Ivory Protocol is the **Validator Bond NFT**, a tokenized cryptoeconomic agreement node operators can enter into for raising funds to run more validators.

The protocol is made up of three parts:
1. The **issuing and redeeming** of Validator Bonds with **Ivory Ink**.
2. A market for **buying and selling** Validator Bonds with **Ivory Bazaar** .
3. A **tokenized fund** of Validator Bonds with **Ivory Parade**.

### IVRY
Emphasis on cryptoeconomics is placed on Ivory Ink to ensure the highest level of security possible. Ivory Ink involves no DAO, no protocol token, and the contracts are not upgradable. Ivory Ink is designed with the intention of being the bedrock and minimum viable protocol around which other protocol features can be built which will involve a DAO, a protocol token, and may invovle upgradable contracts. That said, it is the sincere intention behind the entire design to minimize the influence and necessity of these 3rd parties.

Token Intentions:
-   **Reputation**: Operators may pay IVRY to create and update their Ivory Bazaar NFT profile.
-   **Curation**: Assign and adjust bond-term-derived quality ratings in Ivory Bazaar.
-   **Governance**: Ivory Parade Fund management.
-   **Growth**: Fund development of the protocol, reward early adopters, and incentivise community participation.

DAO Intentions:
-   **TODO**


## 1. Ivory Ink
Node Operator creates a **Validator Bond NFT** with terms they desire(principal, maturity, APR) by making their validator deposits through the Ivory Ink dApp. This sends their validator into the activation queue and issues the NFT to the Node Operator. Upon validator exit and withdrawal, the validator balance is released back into Ivory Ink and portioned out between the NFT bondholder and the Node Operator. 
-   To enforce liquidity for the bondholder, Ivory Ink penalizes operators who exit their bonded validator too early or too late. 
-   To reduce validator churn on the network, bond terms may be renewed by the bondholder before maturity.

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
    -   Minimum of 0.01, unbounded maximum

### Withdrawal Calculations
**TODO: convert to code block**
Validator balance portioning between the NFT bondholder and node operator upon validator exit and withdrawal.
-   `grace_period = 7 days` _Hardcoded and based roughly on the longest expected period of nonfinality in a worst case scenario (2 weeks)._
-   `principal_yield =  APR / (min(total_blocks, maturity) / 1 year) * principal` _We only count blocks up until maturity for principal yield. After maturity, all additional rewards are collected in excess_yield and allocated to the bondholder._
-   `excess_yield = max(withdrawal_balance - 32, 0) / total_blocks * max(maturity - total_blocks - grace_period, 0)` _If a validator balance is withdrawn past the maturity block, all additional rewards are allocated to the bondholder._
-   `normalized_time_to_maturity = max(blocks_until_maturity - grace_period, 0) / maturity_term`
-   `early_withdrawal_penalty = max(withdrawal_balance - 32 - principal_yield, 0) * pow(normalized_time_to_maturity, 2)` _If a validator balance is withdrawn before maturity, a penalty is applied based on the number of blocks left until maturity with a quadratic bias towards lower penalties. This penalty will not deduct from the operator's own stake unless they were slashed by the network._
-   `rewards_total = principal_yield + excess_yield + early_withdrawal_penalty`
-   `final_development_fee = principal + rewards_total < withdrawal_balance && is_dev_fee_active ? rewards_total * 0.005 : 0` *0.5% development fee is taken out as long as the bond doesn't fail to deliver and if is_dev_fee_active when less than 30 years have passed since contract deployment and less than 100,000 ether in fees have been collected.*
-   `final_bond_value = min(principal + rewards_total - final_development_fee, withdrawal_balance)`
-   `final_operator_balance = withdrawal_balance - final_bond_value`

### Bond Renewal
-   Renewal proposals may only be put up for a vote by the operator.
-   May only occur before `maturity - grace_period - 14 days` and pass before `maturity - grace_period`.
-   A bondholder who rejects the proposal may be bought out by the node operator.

### Web dApp
**TODO: mockup**


## 2. Ivory Bazaar
Surface fundamental market demands.
-   Fractionalized Buy/Sell Orders
    -   Simple fractionalization of bond NFTs
-   Buy/Sell Order Ratings
    -   IVRY DAO controlled score derived from bond terms
-   Support for Operator Profiles
    -   Operators may pay IVRY to create a Profile NFT
    -   Includes name and link to metadata for an image, description, maybe a website, maybe more
    -   Hook into Kleros for assigning a verified tag?
    -   Hook into Proof of Humanity for democratized KYC?
    -   Could also include a reputation of some kind... probably derived from history of good behavior
    -   Allows proven operators to get better terms over time and for the ecosystem to support larger ratios of ether to operators.
-   Perpetual Renewal Voting
    -   Bond fractions can be staked to force liquidation. 
    -   Without a bond fraction being staked, the operator may trigger an automatic renewal.
    -   Unstaked fractions may still get liquidated and liquidated fractions sit idle until claimed.

### Web dApp
**TODO: mockup**


## 3. Ivory Parade
Tokenized fund managed by the IVRY DAO for casual investors and easy integration with the greater DeFi ecosystem.

Operator and staker interaction with Ivory Parade from a UX perspective looks almost identical to an Ivory Bazaar Buy/Sell order. Stakers can deposit directly into the fund and stake their tokens for liquidity. Operators can sell bonds directly to the fund and trigger renewal votes when there are no tokens outstanding tokens staked for liquidity. Unlike an Ivory Bazaar Buy/Sell order, stakers may also stake their tokens to collect underwriter fees.

Not upgradible - Instead of upgrades, new pools may be added to Ivory Bazaar and old pools may have a shutdown triggered.

### Managed
The IVRY DAO is responsible for managing the fund by...
-   Maintaining Allocation Tiers
    -   (min/?)Max principal
    -   Min(/max?) APR
    -   reputation-related conditions/restrictions
-   Controlling maturity distribution requirements to maintain regular opportunities for staker liquidity.
-   Controlling the underwriter fee
-   Underwriter time lock duration
-   Tagging bonds at risk of delivery failure and choosing when to give up on bonds that have gone on past maturity **TODO: switch to a keeper incentive?**
-   Controlling the management fee (within strict limitations) **TODO: define limitations**
    -   Spend ether collected from management fees for IVRY buybacks.
-   May trigger a shutdown on further deposits, disabling bond renewal votes, forcing liquidation, and allowing only token redemption.
-   May vote to relenquish all or individual controls, with an auto-relenquish of all controls over N years if no dial is adjusted or if a shutdown is triggered. **TODO: separate the description of IVRY DAO from IVRY Parade**

### Tokenized
Valued without an oracle by keeping a running tally using average APR.
-   Each time a bond is matched to ether for ParadeETH tokens (ParadeETH is not minted until it has been matched)
    -   **TODO: token value isn't taking into account the underwriter and managment fees**
    -   **TODO: convert to code block**
    -   `total_bond_count += 1`
    -   `average_apr += (bond_apr - average_apr) / min(total_bond_count, FACTOR)` _from https://stackoverflow.com/a/50854247, FACTOR would be IVRY DAO controlled._
    -   `total_principal += bond_principal`
    -   `token_value += average_apr / ((last_update_block - current_block) / 1 year) * total_principal`
    -   `for each depositor while bond_principal > 0,`
        -   `match_amount = min(depositor.ether_balance, bond_principal)`
        -   `depositor.token_balance += match_amount / token_value`
        -   `depositor.ether_balance -= match_amount`
        -   `bond_principal -= match_amount`
    -   `last_update_block = current_block` 
-   Each time a bond is liquidated
    -   **TODO: check for delivery failure**
    -   **TODO: convert to code block**
    -   `token_value += average_apr / ((last_update_block - current_block) / 1 year) * total_principal`
    -   `total_principal -= bond_principal`
    -   `average_apr -= (bond_apr - average_apr) / min(total_bond_count, FACTOR)` _from https://stackoverflow.com/a/50854247, FACTOR would be IVRY DAO controlled._
    -   `total_bond_count -= 1`
    -   `bond_rewards = final_bond_value - bond_principal`
    -   `underwriter_fee = bond_rewards * underwriter_fee`
    -   `management_fee = bond_rewards * management_fee`
    -   `fund_ether_balance += bond_rewards - underwriter_fee - management_fee`
    -   `dao_ether_balance += management_fee`
    -   `underwriters_ether_balance += underwriter_fee` **TODO: this ain't quite right**
    -   `last_update_block = current_block`
    
### Underwriter Staking
-   Pool Token holders may stake their pool tokens to collect underwriter fees.
-   In the event that a bond fails to deliver, underwriters soak up damages before the pool does.
-   Requires a time lock commitment which the underwriter may choose to have renewed automatically.
-   In the event that the IVRY DAO flags a bond as being at risk of delivery failure, all underwriters will be locked in until the bond resolves.
-   A bond that has exceeded it's grace period for liquidation may be tagged by the IVRY DAO as failing to deliver, which...
    -   Burns underwriter tokens in proportion to its expected value.
    -   Removes the bond from the pool and redistributes it to the underwriters in proportion to their pool tokens burned.
    -   Underwriters are allowed to exit and, if they're lucky, will see the bond eventually deliver granting them all of it's excess rewards.
-   A bond that has been withdrawn but failed to deliver will work the same, with the bad bond redistributed to the underwriters as proof of their losses.

### Web dApp
**TODO: mockup**


## Additional Information and Thoughts
-   The exact design and mechanics Ivory Ink hinges on finalization of the post-merge withdrawal spec.
-   Would it be possible to release something before withdrawals are unlocked?
    -   It's possible that it could be done with an upgradible Ivory Ink contract whose key is tossed after withdrawals are enabled and any subsequently necessary modifications are made.
    -   Might want to make an Ivory Ink V2 contract without the lingering upgradible pieces for gas price improvements
-   As much of this that can be on an L2 should be. (Looking at you zkSync)
-   Validators will likely be allowed to assign the transaction fee coinbase to any address they wish for a period of time after withdrawals are enabled.
-   The miner of today who is incentivised to contribute to the network for the price of operating hardware is replaced by the staker of tomorrow who is incentivised to contribute to the network by endorsing a pool at any price they can afford. The market between these stakers and operators should be centralized into a ecosystem of operators playing under on common terms for the contributions of sophisticated and casual stakers alike.

Everything about this project is a work in progress and subject to change.

0x2894690AC5Fcdc82aaa372e8bf85797C7e7B577C

### More Bond Product Ideas
-   Reputation Index Pool
    -   A pool comprised of bonds from operators of a high reputation or who are verified.
-   Alternative Asset Denominated Orders?
    -   What if you could stake token, say DAI, and get the APR guarantee like you would in any other product listed. When the bond is redeemed, you could end up taking more or less than your share of the validator's balance, whatever is required to fulfill the order. Would possibly require a variation of the Ivory Ink contract.
-   Tokenized Quadratic Order Index
    -   Pool target allocation derived from weighted quadratic popularity of basic market orders
-   Keeper-driven Pool
    -   Incentivise Keepers to draw orders directly from the basic order market into a pool
    -   Avoids potentially manipulating/splintering the basic market, but requires much more complexity
-   Non-tokenized staking for folks who are looking to avoid tax issues
    -   It could be presented as a savings account with a time lock
