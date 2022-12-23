// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Receptor is Ownable {

    struct Deposit {
        string txHash;
        bool claimed;
        uint256 amount;
        bool set;
    }

    mapping(string => Deposit) public depositId;

    function depositEther(string memory _id) public payable {
        require(msg.value > 0,"cant deposit zero ether");
        require(depositId[_id].set == false, "Deposit Id already exists");
        depositId[_id].amount = msg.value;
        depositId[_id].set = true;
    }

    function claimDeposit(string memory _id, string memory _txHash) public {
        require(depositId[_id].amount != 0, "Deposit amount is empty");
        require(depositId[_id].set == true, "Deposit Id does not exist");
        require(depositId[_id].claimed == false, "Already claimed");
        depositId[_id].claimed = true;
        depositId[_id].txHash = _txHash;
    }

    function withdrawDeposit(address payable to, uint256 amount) public payable onlyOwner returns (bool){
        (bool success,) = to.call { value:amount, gas: 30000 }(''); // amount in wei
        require(success, "Withdraw failed");
        return success;
    }

    receive() external payable {}

     // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}