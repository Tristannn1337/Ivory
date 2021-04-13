pragma solidity 0.8.2;

contract MockWithdrawal {

    enum ValidatorState {
        Nonexistant,
        Deposited,
        Exited,
        Withdrawn
    }

    struct Validator
    {
        ValidatorState state;
        address payable withdrawalAddress;
        uint256 balance;
    }

    mapping (uint256 => Validator) private _validators;

    function withdraw(address validatorPubkey) external {
        Validator v = _validators[validatorPubkey];
        require(v.state == ValidatorState.Exited, "Invalid validator state for withdrawal.");
        require(msg.sender == v.withdrawalAddress, "Withdrawal transactions must come from withdrawal address");
        
        uint256 balance = v.balance;
        v.state = ValidatorState.Withdrawn;
        v.balance = 0;

        v.withdrawalAddress.transfer(balance);
    }
}