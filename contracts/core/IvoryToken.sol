pragma solidity 0.8.2;

/**
 * Ivory Protocol
 */

contract IvoryToken is ERC1155, IvoryNFTInterface {

    uint256 _contractCount;

    function issueBond(address operator, uint256 principal) external returns (uint256)
    {
        bytes memory data; //TODO: WHAT DO I DO WITH THIS?
        uint256 id = _contractCount++;
        _mint(operator, id, principal, data);
        return id;
    }

}