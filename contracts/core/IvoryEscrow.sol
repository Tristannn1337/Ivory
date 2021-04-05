pragma solidity 0.8.2;

/**
 * Ivory Protocol
 */

contract IvoryEscrow is Escrow {

    address private _withdrawalCredentials;
    address private _ivoryTokenAddress;

    constructor(
        address ivoryTokenAddress
    ) public 
    {
        _ivoryTokenAddress = ivoryTokenAddress;

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

    function beaconDeposit(        
        bytes calldata validatorPubkey, 
        bytes calldata validatorSignature, 
        bytes32 depositDataRoot
    );

    function beaconWithdraw(
        bytes calldata validatorPubkey
    );

    function depositAccountByAddress(
        address account, 
        uint256 amount
    );

    function bulkDepositAccountsByTokenId(
        uint256 tokenId, 
        uint256 amount
    );

}