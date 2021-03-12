pragma solidity 0.8.2;

/**
 * Ivory NFT Protocol
 */

contract IvoryNFT is ERC1155, IvoryNFTInterface {

    uint256 _contractCount;

    function createContract(address operator, bytes memory data) external returns (uint256)
    {
        uint256 id = _contractCount++;
        _mint(operator, id, 10**18, data);
        return id;
    }

}