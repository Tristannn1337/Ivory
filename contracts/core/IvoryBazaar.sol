pragma solidity 0.8.2;

/**
 * Ivory Protocol
 */

contract IvoryBazaar {

    struct BuyOrderData {
        address owner;
        BondData bondTerms;
    }

    struct SellOrderData {
        address owner;
        ValidatorData validator;
    }
    
    mapping (uint256 => BuyOrderData[]) private _gradeBuyOrders;
    mapping (uint256 => SellOrderData[]) private _gradeSellOrders;

    function gradeBond(BondData bondData)
    {

    }

    function createBuyOrder(
        uint256 contractBond, 
        uint256 contractGuarantee, 
        uint256 contractLifetime, //use lifetime and not expiration to avoid value decay changing over time
        uint256 orderPrice, 
        uint256 orderExpiration
    ) external 
    {

    }


    function gradeUintToString(uint256 grade) external pure returns (string)
    {
        if (grade == 0) return "ERROR";
        if (grade == 1) return "A+";
        if (grade == 2) return "A";
        if (grade == 3) return "B";
        if (grade == 4) return "C";
        if (grade == 5) return "D";
        if (grade == 6) return "E";
        return "F";
    }

}