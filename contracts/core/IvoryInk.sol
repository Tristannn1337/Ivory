pragma solidity 0.8.2;

/**
 * Ivory Protocol
 */

contract IvoryInk {

    uint256 constant ONE_YEAR = 52 weeks + 1 days; // close enough

    uint256 constant PRINCIPAL_MIN = 1 ether;
    uint256 constant PRINCIPAL_MAX = 30 ether;

    uint256 constant MATURITY_MIN = 4 weeks; // long enough for a validator to run for one week, put up a two week vote for renewal, and resolve before the one week grace period to maturity.
    uint256 constant MATURITY_MAX_START = ONE_YEAR; // maximum at contract deployment
    uint256 constant MATURITY_MAX_END = ONE_YEAR * 30; // maximum after MATURITY_INTERP_TIME as passed since contract deployment
    uint256 constant MATURITY_INTERP_TIME = ONE_YEAR * 10; // period over which the real MATURITY_MAX is interpolated into it's final value

    uint256 constant GRACE_PERIOD = 7 days; // value is both before and after maturity block, effectively doubling the real grace period to two weeks, or roughly the longest expected period of non-finality in a worst case scenario.

    uint256 constant APR_MIN = 0.01 ** 18; // 1%
    uint256 constant APR_MAX = 0.10 ** 18; // 10%

    uint256 constant DEV_FEE = 0.005 ** 18; // taken at withdrawal
    uint256 constant DEV_FEE_LIFETIME = ONE_YEAR * 30; // until the fee expires
    uint256 constant DEV_FEE_LIMIT = 100000 ether; // or the fee limit is reached

    uint256 private _deployBlock; // block when this contract was deployed, used to test against DEV_FEE_LIFETIME
    uint256 private _devFeesAccumulated; // counter for testing against DEV_FEE_LIMIT
    address private _devFeesAddress; // address that dev fees will be sent to

    struct BondTerms {
        uint256 principal;
        uint256 maturity;
        uint256 apr;
    }

    struct ValidatorData {
        address operator;
        address validator;
        BondTerms bondTerms;
        uint256 depositBlock;
        uint256 withdrawBlock;
    }

    mapping (uint256 => ValidatorData) private _tokenValidatorData;
    mapping (address => uint256) private _validatorTokenId;
    
    address private _ivoryEscrowAddress;
    address private _ivoryTokenAddress;

    constructor(
        address devFeesAddress
    ) public 
    {
        _devFeesAddress = devFeesAddress;
        _deployBlock = block.number;
        _ivoryTokenAddress = address(new IvoryToken());
        _ivoryEscrowAddress = address(new IvoryEscrow(_ivoryTokenAddress));
    }

    function depositStakeAndIssueBond(
        BondTerms bondTerms,
        bytes calldata validatorPubkey, 
        bytes calldata validatorSignature, 
        bytes32 depositDataRoot
    ) external returns (uint256)
    {
        require(bondTerms.principal >= PRINCIPAL_MIN && bondTerms.principal <= PRINCIPAL_MAX, "Invalid principal.");
        uint256 maturityMax = min(lerp(MATURITY_MAX_START, MATURITY_MAX_END, (_deployBlock - block.number) / MATURITY_INTERP_TIME), MATURITY_MAX_END);
        require(bondTerms.maturity >= MATURITY_MIN && bondTerms.maturity <= maturityMax, "Invalid maturity.");
        require(bondTerms.apr >= APR_MIN && bondTerms.apr <= APR_MAX, "Invalid APR.");
        require(_validatorTokenId[validatorPubkey] > -1, "Validator has already been assigned to a bond.");

        IvoryEscrowInterface escrow = IvoryEscrowInterface(_ivoryEscrowAddress);
        escrow.beaconDeposit(validatorPubkey, validatorSignature, depositDataRoot);
        // TODO: put the following lines into vault.deposit?
        // require(vault.Balance(msg.sender) >= 32 ether, "A balance of at least 32 Ether is required.");
        // _etherBalance[msg.sender] -= 32 ether;
        // DepositInterface casperDeposit = DepositInterface(getContractAddress("casperDeposit"));
        // casperDeposit.deposit{value: 32}(validatorPubkey, _withdrawalCredentials, validatorSignature, depositDataRoot);

        IvoryTokenInterface ivoryToken = IvoryTokenInterface(_ivoryTokenAddress);
        uint256 tokenId = ivoryToken.issueBond(msg.sender, bondTerms.principal);
        _tokenValidatorData[tokenId] = ValidatorData({
            operator: msg.sender,
            validator: validatorPubkey, 
            bondTerms: bondTerms, 
            depositBlock: block.number, 
            withdrawBlock: 0
        });
        _validatorTokenId[validatorPubkey] = tokenId;
        
        return tokenId;
    }

    // TODO: Move into interface class
    event WithdrawStake(uint256 indexed tokenId);

    function withdrawStake(
        uint256 tokenId
    ) external
    {
        ValidatorData data = _tokenValidatorData[tokenId];

        IvoryEscrowInterface escrow = IvoryVaultInterface(_ivoryEscrowAddress);
        uint256 withdrawalBalance = escrow.beaconWithdraw(data.validator);
        data.withdrawBlock = block.number;

        //TODO: do you really need the max() wrappers if you're using uint? Also `blocksToMaturity * -1` assumes signed int...
        uint256 totalBlocks = bond.withdrawBlock - bond.depositBlock;
        uint256 principalYield = bond.apr / (totalBlocks / ONE_YEAR) * bond.principal;
        uint246 blocksToMaturity = bond.depositBlock + bond.maturity - block.number;
        uint256 normalizedTimeToMaturity = max(blocksToMaturity - GRACE_PERIOD, 0) / bond.maturity;
        uint256 earlyWithdrawalPenalty = max(withdrawalBalance - 32 ether - principalYield, 0) * (normalizedTimeToMaturity ** 2);
        uint256 excessRewards = max(withdrawalBalance - 32 ether, 0) / totalBlocks * max(blocksToMaturity * -1 - GRACE_PERIOD, 0);
        uint256 rewardsTotal = principalYield + earlyWithdrawalPenalty + excessRewards;
        bool isDevFeeActive = _devFeesAccumulated < DEV_FEE_LIMIT && block.number < _deployBlock + DEV_FEE_LIFETIME;
        bool isNotFailToDeliver = bond.principal + rewardsTotal < withdrawalBalance;
        uint256 finalDevelopmentFee = isNotFailToDeliver && isDevFeeActive ? rewardsTotal * 0.005 ** 18 : 0;
        uint256 finalBondValue = min(bond.principal + rewardsTotal - finalDevelopmentFee, withdrawalBalance);
        uint256 finalOperatorBalance = withdrawalBalance - finalBondValue;

        escrow.depositAccountByAddress(_devFeesAddress, finalDevelopmentFee);
        escrow.bulkDepositAccountsByTokenId(tokenId, finalBondValue);
        escrow.depositAccountByAddress(data.operator, finalOperatorBalance);

        emit WithdrawStake(tokenId);
    }


}
