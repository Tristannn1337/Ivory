# The Ivory Protocol

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
Compared to the typical service-oriented relationship that most if not all existing pools have with stakers, the Ivory Protocol reframes the relationship as operators raising money by issuing bonds to investors collateralized by their withdrawal balance.
Central to the design of the Ivory Protocol is the **Validator Bond NFT**, a tokenized cryptoeconomic agreement that node operators can enter into for raising funds to run more validators.

The protocol is made up of three parts:
1. The **issuing and redeeming** of Validator Bonds with **Ivory Ink**.
2. A market for **buying and selling** Validator Bonds with **Ivory Bazaar** .
3. A **tokenized fund** of Validator Bonds with **Ivory Parade**.

Ivory Ink involves no DAO, no protocol token, the contracts are not upgradable, and is designed with the intention of being the minimum viable protocol around which Ivory Bazaar and Ivory Parade may be built. By creating this separation between Ivory Ink and the rest of the protocol, we create a secure foundational commitment to the ecosystem and place fundamental limitations on the power that any member or developer has.

Ivory Bazaar and Ivory Parade will involve the IVRY Token and DAO.
The intentions behind the IVRY Token are:
-   **Reputation**: Operators may pay IVRY to create and update their Ivory Bazaar NFT profile.
-   **Curation**: Adjust bond-term-derived quality ratings in Ivory Bazaar and Ivory Parade Fund Management.
-   **Growth**: Fund development of the protocol, reward early adopters, and incentivise community participation.
-   **Governance**: Approval power over smart contract upgrades, IVRY spending, IVRY buybacks, and fee management.
-   **Administration**: Trigger emergency procedures in time sensitive situations to make time for governance to respond.

It will be important early on for the IVRY DAO to curate Ivory Bazaar using strict quality ratings in order to appropriately offset the risk that an operator could sell high principal validator bonds without the intention of ever exiting with a balance remaining, a side effect of transaction fees not being directed into a validator's balance and the potential for MEV to play into a significant portion of a validator's profit. It may be necessary to completely censor certain bond terms from appearing in Ivory Bazaar.

**TODO: Quadratic DAO?**

## 1. Ivory Ink
Using Ivory Ink, a Node Operators create a **Validator Bond NFT** with terms they desire(principal, maturity, APR) by making their validator deposits through the Ivory Ink dApp. Their validator is forwarded into the activation queue and the bond NFT is issued to the Node Operator. Upon validator exit and withdrawal, the validator balance is released back into Ivory Ink and portioned out between the NFT bondholder and the Node Operator. 
-   To enforce liquidity for the bondholder, Ivory Ink penalizes operators who exit their bonded validator too early or too late.
-   To reduce validator churn on the network, bond terms may be renewed by the bondholder before maturity.

### Bond Terms
-   **Principal** (ETH)
    -   The amount of ETH that the operator is raising out of 32.
-   **APR** (%)
    -   The reward rate the operator expects from the network, presumably discounted by their commission rate, and guaranteed to the bondholder.
-   **Maturity** (Blocks)
    -   The number of blocks after deposit that the operator is committing to withdrawing the validator balance by.
    -   Enforced by penalties described in the withdrawal calculations section.
-   **Grace Period** (Blocks)
    -   The number of blocks before and after the maturity block where an operator is allowed to exit without penalty.
    -   In practice, this value will be set for the operator by Ivory Bazaar and dictated by IVRY DAO.


### Withdrawal Calculations
Validator balance portioning between the NFT bondholder and node operator upon validator exit and withdrawal.

```Solidity
// NOTE: This pseudocode uses floating point math for readability.

// We only count blocks up until maturity for principal yield.
// After maturity, all additional rewards are collected in excess_yield and allocated to the bondholder.
principal_yield = APR / (min(total_blocks, maturity) / 1 years) * principal

// If a validator balance is withdrawn past the maturity block, all additional rewards are allocated to the bondholder.
// Determined by taking average rewards per block mulultipied by number of blocks past maturity
// At a minimum, these rewards include attestation rewards, proposal rewards, and some transaction fees (0x02).
// MEV may also be included if the operator choses. Incentive to do so should come from the Ivory Bazaar reputation system if possible. (flashbots verified?)
excess_yield = max(withdrawal_balance - 32, 0) / total_blocks * max(maturity - total_blocks - grace_period, 0)

// If a validator balance is withdrawn before maturity, a penalty is applied based on the number of blocks left until maturity
// with a quadratic bias towards lower penalties. This penalty will not deduct from the operator's own stake unless they were
// slashed by the network.
_normalized_time_to_maturity = max(blocks_until_maturity - grace_period, 0) / maturity_term
early_withdrawal_penalty = max(withdrawal_balance - 32 - principal_yield, 0) * pow(_normalized_time_to_maturity, 2)

// Complete totalling of rewards for portioning between the operator, bond, and the development fee
rewards_total = principal_yield + excess_yield + early_withdrawal_penalty

// A 0.5% development fee is taken out as long as the bond doesn't fail to deliver when is_dev_fee_active.
// is_dev_fee_active when less than 30 years have passed since contract deployment and less than 100,000 ether in fees have been collected.
final_development_fee = principal + rewards_total < withdrawal_balance && is_dev_fee_active ? rewards_total * 0.005 : 0

final_bond_value = min(principal + rewards_total - final_development_fee, withdrawal_balance)

final_operator_balance = withdrawal_balance - final_bond_value
```


### Bond Renewal
-   All bonds default to being `renewable`.
-   A bondholder who wishes to liquidate must submit a transaction to change the NFT's state to `unrenewable`.
-   Bond state is locked starting at `maturity - grace_period` and may only unlock after `maturity + grace_period` if the locked state is `renewable`. 
-   (TODO) An operator may, at any time, choose to recover the NFT by paying for it directly. The recovery cost is equal to...


## 2. Ivory Bazaar
Surface fundamental market demands, create a platform for operator reputation, grade bonds to reflect changing risk profiles in the larger Ethereum protocol and ecosystem over time, and possibly curate bonds of extreme risk from appearing at all.
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
-   Term Curation
    -   Principal limited to increments of 0.5 ether for listing simplicity?
    -   Principal maximum of 30, minimum of 1? Needs to be based on analysis of validator balance value over time given projected EV.
    -   APR Minimum of 0.01, unbounded maximum.
    -   Grace period of +/- 7 days, roughly based on the amount of time expected in a state of non-finality.
    -   Maturity maximum of 30 years, minimum of 1 month.
        -   Make the maximum be a function of how long the contract has existed... for example, upon deployment the maximum could be 1 year and over the course of the next 5-10 years the maximum would be interpolated to it's final value of 30. Would allow the contract to stand the test of time before allowing people to make such long term commitments.
    -   More complex relationships between terms will be necessary... a bond with a low principal may be allowed longer maturity while high principal bonds require short maturity in order to satisfy EV projections relative to stake.



## 3. Ivory Parade
Tokenized fund managed by the IVRY DAO for casual investors and easy integration with the greater DeFi ecosystem. This section describes what could be the first iteration, but more ideas for future iterations are listed in the "More Bond Product Ideas" section.

Operator and staker interaction with Ivory Parade from a UX perspective looks almost identical to an Ivory Bazaar Buy/Sell order. Stakers can deposit directly into the fund and stake their tokens for liquidity. Operators can sell bonds directly to the fund and trigger renewal votes when there are no outstanding tokens staked for liquidity. Unlike an Ivory Bazaar Buy/Sell order, stakers may also stake their tokens to collect underwriter fees.

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
-   May trigger a shutdown on further deposits or token redeemptions and disabling bond renewal votes.

### Tokenized
Valued without an oracle by keeping a running tally using average APR.
-   Each time a bond is matched to ether for ParadeETH tokens (ParadeETH is not minted until it has been matched)
    ```Solidity
    // TODO: token value isn't taking into account the underwriter and managment fees

    // from https://stackoverflow.com/a/50854247, FACTOR would be IVRY DAO controlled.
    total_bond_count += 1
    average_apr += (bond_apr - average_apr) / min(total_bond_count, FACTOR)
    
    total_principal += bond_principal
    token_value += average_apr / ((last_update_block - current_block) / 1 year) * total_principal

    // TODO: try to switch from a loop that modifies state to a couple tallies and blockstamps + don't forget that multiple transactions could happen in same block.
    for each depositor in pending_depositors while bond_principal > 0
        match_amount = min(depositor.ether_balance, bond_principal)
        depositor.token_balance += match_amount / token_value
        depositor.ether_balance -= match_amount
        bond_principal -= match_amount
    last_update_block = current_block
    ```
-   Each time a bond is liquidated
    ```Solidity
    // TODO: check for delivery failure

    token_value += average_apr / ((last_update_block - current_block) / 1 year) * total_principal
    total_principal -= bond_principal

    // from https://stackoverflow.com/a/50854247, FACTOR would be IVRY DAO controlled.
    average_apr -= (bond_apr - average_apr) / min(total_bond_count, FACTOR)
    total_bond_count -= 1

    bond_rewards = final_bond_value - bond_principal
    underwriter_fee = bond_rewards * underwriter_fee
    management_fee = bond_rewards * management_fee
    fund_ether_balance += bond_rewards - underwriter_fee - management_fee
    dao_ether_balance += management_fee
    underwriters_ether_balance += underwriter_fee // TODO: this ain't quite right
    last_update_block = current_block

    // TODO: distribute fund_ether_balance to pending_redeemers, then check if there are pending bonds that could be matched.
    // Worry about needing to break everything up into separate transactions later.
    ```
    
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


## Additional Information and Thoughts
-   The exact design and mechanics Ivory Ink hinges on finalization of the post-merge withdrawal spec.
    -   This would utilize 0x02 withdrawal credentials.
-   Would it be possible to release something before withdrawals are unlocked?
    -   It's possible that it could be done with an upgradible Ivory Ink contract whose key is tossed after withdrawals are enabled and any subsequently necessary modifications are made.
    -   Might want to make an Ivory Ink V2 contract without the lingering upgradible pieces for gas price improvements
-   As much of this that can be on an L2 should be. (Looking at you zkSync)

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
