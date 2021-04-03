![Ivory Protocol](https://github.com/Tristannn1337/Ivory/blob/main/LogoV1.png)


# The Ivory Protocol
An Ethereum Validator Bond Ecosystem


## Problem
Ethereum needs a pooled staking protocol that, if it were to be used by every single validator in the ecosystem, would not begin to challenge to Ethereum's legitimacy. All existing staking pools involve either a centralized authority or DAO governance, when all we need is a simple protocol that facilitates a market between node operators and ether holders. Specifically, we need a protocol that:

-   Involves minimum possible trust
-   Is fully decentralized
-   Is minimally regulated, allowing the market to dictate risks and rewards
-   Facilitates stake liquidity back to ether holders
-   Facilitates tokenized staking for casual ETH holders


## Proposal
Allow Node Operators to raise funds by selling Validator Bonds to individuals who wish to benefit from Validator staking without running a node of their own. The protocol is made up of three parts:
1. Standardize the **issuing and redeeming** of Validator Bonds with **Ivory Ink**.
2. Facilitate a market for **selling and purchasing** Validator Bonds with **Ivory Bazaar**.
3. Create a **tokenized fund** of Validator Bonds with **Ivory Parade**.


## 1. Ivory Ink - Validator Bonds
Allows a Node Operator to create a Validator Bonds with terms they desire(principal, maturity, APR) by making their validator deposits through the Ivory Ink dApp. This sends their validator into the activation queue and issues bond tokens back to the Node Operator. Upon validator exit and withdrawal, the validator balance is released back into Ivory Ink and portioned out between token holders and the Node Operator. 
-   To enforce liquidity for bond holders, Ivory Ink will penalize operators who exit their bonded validator either too early or too late. 
-   To reduce validator chrun on the network, bond terms may be renewed by bond holders before maturity.

### Bond Terms

-   **Principal** (ETH)
    -   The amount of ETH that the operator is raising out of 32.
    -   Limited to increments of 1 ether?

-   **Maturity** (Block)
    -   The block that the operator is comitting to withdrawing the validator balance by.
    -   Enforced by penalties described in the cryptoeconomics withdrawal calculations section.
    -   Operator is given a grace period of +/- 7 days.

-   **APR** (%)
    -   The reward rate the operator expects from the network, presumibly discounted by their comission rate, and guaranteed to the bond holder.

### Cryptoeconomics

-   **Quality Rating** (Score)
    -   Derived from the bond configuration
    -   Used to sort bonds
    -   Facilitates easy bond selection
    -   May be used to automate fund bond selection
    -   **TODO: calculation**

-   **Withdrawal Calculations** - how validator balance is portioned out upon exit and withdrawal
    -   `grace_period = 50000` _Hardcoded to +/- 7 days, based roughly on the longest expected period of nonfinality in a worst case scenario (2 weeks)._
    -   `principal_yield =  APR / (total_blocks * 12 / 60 / 60 / 24 / 365) * principal`
    -   `normalized_time_to_maturity = max(blocks_until_maturity - grace_period, 0) / maturity_term`
    -   `early_withdrawal_penalty = (withdrawal_balance - 32 - principal_yield) * pow(normalized_time_to_maturity, 2)` _If a validator balance is withdrawn before the maturity block, a penalty is applied based on the number of blocks left until the maturity block with a quadratic bias towards lower penalties. The operator doesn't lose any of their own stake unless they were slashed by the network, in which case the slash is magnified._
    -   `excess_rewards = (withdrawal_balance - 32) / total_blocks * max(blocks_past_maturity - grace_period, 0)` _If a validator balance is withdrawn past the maturity block, all additional rewards are allocated to the bond holders on top of APR being applied to the total duration._
    -   `rewards_total = principal_yield + abs(early_withdrawal_penalty) + excess_rewards`
    -   `development_fee = principal + rewards_total < withdrawal_balance && is_dev_fee_active ? rewards_total * 0.005 : 0` *0.5% development fee is taken out as long as the bond doesn't fail to deliver and if is_dev_fee_active when less than 30 years have passed since contract deployment and less than 100,000 ether in fees have been collected.*
    -   `final_bond_value = min(principal + rewards_total - development_fee, withdrawal_balance)`
    -   `final_operator_balance = withdrawal_balance - final_bond_value`

### Design Considerations
-   Ivory Ink's exact design and mechanics hinge on the final withdrawal spec supporting the means for smart contracts to attribute a withdrawal balance to a specific validator. 
-   Could the Ivory Ink bonds be issued directly into an L2 shared with Ivory Bazaar and Ivory Parade?
-   Validators will likely be allowed to withdraw excess balance on each proposal
    -   How would the contract know which validator the ether came from?
        -   Seems likely the msg.sender would be the validator
    -   Makes exiting less necessary...
        -   But partial NFT ownership over NFT's share of rewards becomes tricky...
        -   Should play with solutions in code
-   Validator bond renewal
    -   Bond holders act as a mini-DAO for renewal proposals. 
    -   Renewal proposals may only be put up for vote by the operator.
    -   May only occur before `maturity - grace_period - 14_days` and pass before `maturity - grace_period`.
    -   Require buyout of no-votes and absent votes by either operator or by yes-votes, with favor given to yes-votes.
    -   Renewal fails if voting ends without enough ether to cover buyout no-votes and absent votes.

### Web dApp
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


## 2. Ivory Bazaar - bond marketplace
Facilitates transparent and educated transactions of Ivory Ink validator bonds and gives buyers an avenue to generate demand for the specific terms they desire by placing buy orders that Node Operators can fill directly.

### Web dApp
-   **Order Book Visualizer**
    -   Risk
    -   Intrinsic Value
    -   Historical Sale Price
    -   Buy Validator Bonds
        -   Fill existing sell orders
        -   Create new buy orders
    -   Sell Validator Bonds
        -   Fill existing buy orders
        -   Create new sell orders


## 3. Ivory Parade - tokenized fund
Facilitates tokenized staking by distilling the complexity of the Ivory Bazaar down into a single token that represents ownership over a pool of Ivory Ink validator bonds that are managed trustlessly by Agent Nodes who do nothing more than watch for opportunities to trigger parameterless Ivory Parade functions when it would result in a reward to the operator.
-   Purchases Ivory Ink validator bonds a varying quality ratings according to fund allocation settings and prioritizes bonds that distribute maturity dates evenly throughout time.
-   Votes yes on bond renewals when liquidity isn't needed by token holders with outstanding redemption orders.
-   Redeems bond balances back into deposit pool when available.
-   NAV calculated by implied value of the underlying bonds plus the deposit pool balance over the number of tokens issued.
-   Minimal management fee regularly taken from fund profits to support and incentivise agent nodes.

### Agent Node
-   A client running on hardware with access to block proposal transaction injection.
-   Watches for bonds that the fund would purchase when a sufficient deposit pool balance is available.
-   Watches for bonds that are ready to be redeemed.
-   Watches for bond renewal proposals that would the fund vote yes to, and potentially buy out no votes and absent votes on.
-   Triggers a parameterless actions on the Ivory Parade contract and to get a small kickback that covers gas and incentive sufficient enough to convince operators to run it.

### Web dApp
-   **NAV Graph**
    -   Deposit Ether
-   **Inflow-Outflow Graph**
-   **Liquidity Calendar**
    -   Ivory Ink Bond Explorer
-   **Redemption Queue**
    -   Create Redemption Order
-   **Contract Activity Log**


## Additional Information
Absolutely everything about this is a work in progress.
0x2894690AC5Fcdc82aaa372e8bf85797C7e7B577C