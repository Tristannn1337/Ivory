pragma solidity 0.8.2;

/**
 * Ivory NFT Protocol
 */

contract IvoryMain is IvoryMainInterface {

    uint256 constant ONE_YEAR = 52 weeks; //close enough

    uint256 constant LIFETIME_MIN = 4 weeks; //basically the bare minimum
    uint256 constant LIFETIME_MAX = ONE_YEAR * 30; // maybe the upper limit can be a function of time? Say the limit starts at like 1 year, after 1 year it becomes 2, and by the 5th year then 30 year is allowed.

    uint256 constant BOND_MIN = 2 ether;
    uint256 constant BOND_MAX = 31 ether;

    uint256 constant GUARANTEE_MIN; // (32-bond) + (32-bond) * 0.005 * lifetimeInYears
    uint256 constant GUARANTEE_MAX; // (32-bond) + (32-bond) * 0.1 * lifetimeInYears //current rate is <9%... if the rate ever climbs back above that, we're in some kind of trouble. 

    /**
     * @dev Returns the percent fee taken from withdrawStake profits. Returns 0 after
     * the total development fees collected reaches it's maximum or the fee expiration block is
     * reached.
     */
    uint256 constant DEV_FEE = 0.05 ** 18;

    /**
     * @dev the lifetime of the development fee in blocks when the development fee would expire if the total development
     * fees collected doesn't reach a maximum first. Compared against when a contract deposit is made, not when it expires.
     */
    uint256 constant DEV_FEE_LIFETIME = ONE_YEAR * 30;

    /**
     * @dev Returns the maximum amount of ETH that will ever be collected be development fees
     * if the development fee expiration block isn't reached first.
     */
    uint256 constant DEV_FEE_LIMIT = 100000 ether;


    struct ValidatorContract {
        address operator;
        uint256 bond;
        uint256 guarantee;
        uint256 lifetime;
        uint256 depositBlock;
        uint256 withdrawBlock;
    }
    mapping (address => IvoryContract) private _validatorContracts;
    mapping (uint256 => address) private _contractValidators;

    address private _withdrawalCredentials;
    address private _developmentFeeAddress;

    constructor(
        address developmentFeeAddress
    ) public 
    {
        _developmentFeeAddress = developmentFeeAddress;

        // Generate the Withdrawal Credentials use for all contracts
        // Parameters
        uint256 credentialsLength = 32;
        uint256 addressLength = 20;
        uint256 addressOffset = credentialsLength - addressLength;
        byte withdrawalPrefix = 0x01;
        // Calculate & return
        bytes memory ret = new bytes(credentialsLength);
        bytes20 addr = bytes20(address(this));
        ret[0] = withdrawalPrefix;
        for (uint256 i = 0; i < addressLength; i++) {
            ret[i + addressOffset] = addr[i];
        }
        _withdrawalCredentials = ret;
    }

    /**
     * @dev Returns the penalty added onto an operator's withdrawal at `blocksPastExpiration`
     * before withdrawStake is successfully called.
     */
    function calcLeakAmount(
        uint256 blocksPastExpiration
    ) external pure view returns (uint256);

    /**
     * @dev Calculate the value of any contract with a given set of parameters.
     */
    function calcContractValue(
        uint256 bond, 
        uint256 guarantee, 
        uint256 lifetime, 
        uint256 depositBlock, 
        uint256 atBlock
    ) external pure view returns (uint256);


    function getContractValidator(
        uint256 contractId
    ) external view returns (address) 
    {
        return _contractValidators[contractId];
    }

    function getValidatorContract(
        address validatorPubkey
    ) external view returns (ValidatorContract) 
    {
        return _validatorContracts[validatorPubkey];
    }


    // TODO: Move into interface class
    event CommitStakeAndMintContract(
        address validator, 
        uint256 contractId, 
        address indexed from, 
        uint256 bond, 
        uint256 guarantee, 
        uint256 indexed expirationBlock
    );

    /**
     * @dev Drafts an NFT contract with a `bond` amount of ETH being put up by the operator
     * and a `guarantee` of how much the NFT will be worth after `lifetime` blocks have passed 
     * after the deposit transaction. Returns ID of NFT draft.
     * @dev A deposit of 32 ETH that is then forwarded to the formal eth2.0 deposit contract 
     * with a withdrawal address pointing to the Ivory Vault. A successful transaction results 
     * in minting 32-bond `contractId` tokens to the operator's address. Further interaction
     * with `contractId` tokens is to be made directly with the Ivory NFT smart contract.
     */
     // TODO: switch to a system where accounts have an ETH balance, and people can send to and withdraw from the contract
     // and use that account balance to pull funds for staking. This allows someone who wants to make a lot of contracts
     // to reduce gas by sending all the ETH they want to use at once. This also allows NFT holders to call the withdraw
     // method where the operator's funds will be sitting in their account.
    function commitStakeAndMintContract(
        uint256 bond, 
        uint256 guarantee, 
        uint256 lifetime, 
        bytes calldata validatorPubkey, 
        bytes calldata validatorSignature, 
        bytes32 depositDataRoot
    ) external returns (uint256) 
    {
        require(_validatorContracts[validatorPubkey].operator == address(0x0), "Validator has already been assigned to an existing contract.");
        require(_etherBalance[msg.sender] >= 32 ether, "A balance of at least 32 Ether is required.");

        _etherBalance[msg.sender] -= 32 ether;
        DepositInterface casperDeposit = DepositInterface(getContractAddress("casperDeposit"));
        casperDeposit.deposit{value: 32}(validatorPubkey, _withdrawalCredentials, validatorSignature, depositDataRoot);

        bytes memory data; //TODO: WHAT DO I DO WITH THIS!?
        uint256 contractId = IvoryNFT.createContract(msg.sender, data);
        _contractValidators[contractId] = validatorPubkey;
        _validatorContracts[validatorPubkey] = ValidatorContract(msg.sender, bond, guarantee, lifetime, block.number, 0);
        
        emit CommitStakeAndMintContract(validatorPubkey, contractId, msg.sender, bond, guarantee, block.number + lifetime);

        return contractId;
    }


    /**
     * @dev Attempt to withdraw stake from formal eth2.0 withdrawal contract, assign the
     * exercise value of `contractId`, and pass the operator's portion of the total back.
     * 
     * Additionally, if the stake is withdrawn before the development fee reaches it's maximum,
     * the fee expiration block is reached, and the contract holder profited, set aside a 
     * development fee of 0.5% of the profit. In the event that the operator does not profit,
     * the fee comes entirely out of the contract holder's profits.
     * 
     * Anyone can call this method on any contract without limitation, although it will
     * fail if the validator hasn't exited.
     */
    function withdrawStake(
        uint256 contractId
    ) external;

}
