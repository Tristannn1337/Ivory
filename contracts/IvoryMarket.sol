pragma solidity 0.8.2;

contract IvoryMarket {

    struct Order {
        uint256 contractBond;
        uint256 contractGuarantee;
        uint256 contractLifetime;
        uint256 orderPrice;
        uint256 orderExpiration;
    }
    mapping (uint256 => Order[]) _ordersAtExpiration; //can't use expiration... or lifetime really... how should this data be organized???

    function createBuyOrder(
        uint256 contractBond, 
        uint256 contractGuarantee, 
        uint256 contractLifetime, //use lifetime and not expiration to avoid value decay changing over time
        uint256 orderPrice, 
        uint256 orderExpiration
    ) external 
    {

    }

}