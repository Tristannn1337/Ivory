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
    -   Opportunities for lower risk.
-   Better for Ethereum 
    -   No compromises on decentralization.
    -   Minimum possible trust.
    -   Market dictated risks and rewards.


## Overview
Central to the design of the Ivory Protocol is the **Validator Bond**, a pure cryptoeconomic agreement node operators can enter into and raise funds for running more validators.

The protocol is made up of three parts:
1. Standardize the **issuing and redeeming** of Validator Bonds with **Ivory Ink**.
2. Facilitate a market for **selling and purchasing** Validator Bonds with **Ivory Bazaar**.
3. Manage a **tokenized fund** of Validator Bonds with **Ivory Parade**.


## 1. Ivory Ink - Validator Bonds
Node Operator creates **Validator Bonds** with terms they desire(principal, maturity, APR) by making their validator deposits through the Ivory Ink dApp. This sends their validator into the activation queue and issues bond tokens back to the Node Operator. Upon validator exit and withdrawal, the validator balance is released back into Ivory Ink and portioned out between token holders and the Node Operator. 
-   To enforce liquidity for bondholders, Ivory Ink will penalize operators who exit their bonded validator either too early or too late. 
-   To reduce validator churn on the network, bond terms may be renewed by bondholders before maturity.

### Validator Bond Terms
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
Validator balance portioning between the bond holders and node operator upon validator exit and withdrawal.
-   `grace_period = 7 days` _Hardcoded and based roughly on the longest expected period of nonfinality in a worst case scenario (2 weeks)._
-   `principal_yield =  APR / (total_blocks / 1 year) * principal`
-   `normalized_time_to_maturity = max(blocks_until_maturity - grace_period, 0) / maturity_term`
-   `early_withdrawal_penalty = max(withdrawal_balance - 32 - principal_yield, 0) * pow(normalized_time_to_maturity, 2)` _If a validator balance is withdrawn before the maturity block, a penalty is applied based on the number of blocks left until the maturity block with a quadratic bias towards lower penalties. The operator doesn't lose any of their own stake unless they were slashed by the network, in which case the slash is magnified._
-   `excess_rewards = max(withdrawal_balance - 32, 0) / total_blocks * max(blocks_past_maturity - grace_period, 0)` _If a validator balance is withdrawn past the maturity block, all additional rewards are allocated to the bond holders on top of APR being applied to the total duration._
-   `rewards_total = principal_yield + early_withdrawal_penalty + excess_rewards`
-   `final_development_fee = principal + rewards_total < withdrawal_balance && is_dev_fee_active ? rewards_total * 0.005 : 0` *0.5% development fee is taken out as long as the bond doesn't fail to deliver and if is_dev_fee_active when less than 30 years have passed since contract deployment and less than 100,000 ether in fees have been collected.*
-   `final_bond_value = min(principal + rewards_total - final_development_fee, withdrawal_balance)`
-   `final_operator_balance = withdrawal_balance - final_bond_value`

### Design Considerations
-   The exact design and mechanics Ivory Ink hinges on the final withdrawal spec supporting the means for smart contracts to attribute a withdrawal balance to a specific validator. 
-   Could the Ivory Ink bonds be issued directly into an L2 shared with Ivory Bazaar and Ivory Parade?
-   Validators will likely be allowed to withdraw excess balance on each proposal.
-   Validator bond renewal
    -   Bondholders act as a mini-DAO for renewal proposals. 
    -   Renewal proposals may only be put up for a vote by the operator.
    -   May only occur before `maturity - grace_period - 14 days` and pass before `maturity - grace_period`.
    -   Require buyout of no-votes and absent votes by either operator or by yes-votes, with favor given to yes-votes.
    -   Renewal fails if voting ends without enough ether to cover buyout no-votes and absent votes.
-   Should bond tokens represent incements of 0.5 ether so that the maximum number of individual balances is <64?
    -   Not sure if necessary to put limits on maximum contract execution time
-   Escrow balances can be communicated through tokens read by wallets...
-   Emphasis on cryptoeconomics is placed on this piece of the protocol to ensure the highest level of security possible. There is no DAO, no investment token, the contracts are not upgradable. Ivory Ink is designed with the intention of being the bedrock and minimum viable protocol around which all other protocol features may be built.

### Web dApp
TODO: Replace with mockup
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


## 2. Ivory Bazaar - Bond Marketplace
Facilitates transparent and educated transactions of Ivory Ink validator bonds and gives buyers an avenue to generate demand for the specific terms they desire by placing buy orders that Node Operators can fill directly.

### Quality Rating
A score derived from bond terms to sort and simplify bond selection by individuals or by Ivory Parade.
-   Could be DAO driven
-   Could possibly be hardcoded
-   Could be replaced with something else entirely...

### IVRY Token
Intentions:
-   Promote and retain operators who are good at their job.
-   Incentivise an ecosystem of market makers on Ivory Bazaar.
-   Voting in the Ivory Bazaar Minimum-Governance-DAO.
    -   Only function currently designed is to manage the bond quality rating system.
-   Additionally, there are a couple more early-stage intentions:
    -   Incentivise early adopters to learn about and participate in the ecosystem through marketing events
        -   airdrops
        -   temporary good-behavior incentive boosts
    -   Fund development.

### Tokenomics
Incorporating an IVRY token incentivises participation in the protocol and funds development.

-   Required IVRY offering to list orders.
    -   Minimum 0.0001 IVRY
    -   Incentivises liquidity by paying people to fill orders.
    -   Orders are priority sorted based on the amount of IVRY offered.
        -   Orders with the highest IVRY offerings appear at the top of the order list.
        -   Orders with identical terms but less IVRY offered are not sold until all orders with higher IVRY are filled.

-   Stake IVRY to issue Ivory Ink bonds.
    -   On failure to deliver, staked IVRY is given to token holders.
    -   Amount of IVRY staked becomes a 4th configurible bond term

-   Reward operators who behave by minting `stake * (APR / maturity)` new IVRY into their account on withdrawal.
    -   Encourages operators to spend IVRY more freely when listing orders, effectively giving better operators better service.
        -   Kind of an interesting indirect reputation market.
    -   definition of behaving:
        -   did not fail to deliver
        -   did not withdraw early (outside of grace period)
        -   did not withdraw late (outside of grace period)

-   Quality Rating DAO Power
    -   Can suggest and vote on changes to the quality ratings applied to bonds

### Web dApp
TODO: Replace with mockup
-   **Order Book Visualizer**
    -   Quality Rating
    -   Intrinsic Value
    -   Buy existing sell order
        -   Simple swap
    -   Sell to an existing buy order
        -   Hook into Ivory Ink Deposit dApp and attempt to fill buy order in single transaction
-   **Open Orders**
    -   Cancel
    -   Modify
-   **Create new Buy Order**
    -   Define either desired terms or a general quality rating
    -   Limit precision of desired terms to encourage buy order bundling?
-   **Create new Sell Order**
    -   Hook into Ivory Ink Deposit dApp and create sell order in single transaction


## 3. Ivory Parade - Tokenized Fund
Facilitates tokenized staking by distilling the complexity of the Ivory Bazaar down into a single token that represents ownership over a pool of Ivory Ink validator bonds that are managed trustlessly by Agent Nodes who are incentivised to watch for opportunities and trigger parameterless Ivory Parade functions.
-   Purchases Ivory Ink validator bonds of varying quality ratings according to fund allocation settings and prioritizes bonds that distribute maturity dates evenly throughout time.
-   Votes yes on bond renewals when liquidity isn't needed by token holders with outstanding redemption orders.
-   Redeems bond balances back into the deposit pool when available.
-   Effectively acts as a market maker in the Ivory Bazaar.
-   NAV is calculated by the implied value of the underlying bonds plus the deposit pool balance over the number of tokens issued.
-   Minimal fund token inflation used to reward agent nodes who perform management duties.
    -   Using fund tokens as reward makes it easier for agent operators to participate in the Ivory Parade DAO

### Ivory Parade DAO
-   Fund Token holders may also participate in governance over the fund allocation by proposing and voting on fund allocation and management condition changes.

### Agent Node
-   A client running on hardware with access to block proposal transaction injection.
-   Watches for bonds that the fund would purchase when a sufficient deposit pool balance is available.
-   Watches for bonds that are ready to be redeemed.
-   Watches for bond renewal proposals that would the fund vote yes to, and potentially buy out no votes and absent votes on.
-   Triggers parameterless actions on the Ivory Parade contract and gets a small kickback that covers gas and incentive sufficient enough to convince operators to run it.
-   Failed actions cause agent to lose their gas money, intentionally penalizing them.

### Web dApp
TODO: Replace with mockup
-   **NAV Graph**
    -   Deposit Ether
-   **Inflow-Outflow Graph**
-   **Liquidity Calendar**
    -   Ivory Ink Bond Explorer
-   **Redemption Queue**
    -   Create Redemption Order
-   **Contract Activity Log**


## Additional Information
There's probably two phases of this project...
-   Phase 1 is just Ivory Ink and Ivory Bazaar
-   Phase 2 is Ivory Parade
    -   It's possible that Phase 2 could be scraped if an another existing protocol decides to take on tokenizing the fund.

-   Funding Idea: Sell NFT of protocol logo(s)?

Everything about this project is a work in progress and subject to change.

0x2894690AC5Fcdc82aaa372e8bf85797C7e7B577C