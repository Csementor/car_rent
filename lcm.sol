
 //‘Pied Piper’ has emerged as the winning team in the Arena, the annual web3 multi-player gaming fest. The winning prize of the tournament is a huge amount of money, which will be given in form of credits. For this,  Arena will be sharing the credits in form of a smart contract based shared wallet.

// How will the wallet be shared?

// This wallet will be in form of a smart contract.
// The smart contract will be deployed by the Arena Judge.
// After deploying the smartcontract, the deployer will initialize the smart contract with all the addresses of the members of Pied Piper and the winning prize credit amount by running a one time accessible function of smartcontract.
// Now, the smart contract will be ready for the winning team members to use.

// How will the winning team use this smart contract?
// After the smart contract is completely set to use for the winning team members, the members of the team can create transaction requests inside the smart contract to spend the credits from the smart contract.
// There is no limit on the number of transaction requests that can be created in the smart contract.
// Any transaction request needs approval from at least 70% of the team members to be completed.
// Once a transaction request gets enough approvals, the request will be completed successfully and the credits from the wallet will be spent.
// A transaction request can also be rejected by the team members. If a transaction request gets rejections by more than 30% of the team members, then the transaction request will be marked as failed, and the credits will not be spent for that transaction.
// Any transaction request which has a spending amount greater than the current available credits in the wallet must automatically fail.

 
  // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 

contract SharedWallet {
    address public deployer;
    address[] public members;
    uint public totalCredits;
    
    enum TransactionStatus { Pending, Debited, Failed }
    
    struct Transaction {
        uint amount;
        TransactionStatus status;
        uint approvals;
        mapping(address => bool) hasVoted;
    }
    
    Transaction[] public transactions;
    mapping(address => bool) public isMember;
    
    modifier onlyDeployer() {
        require(msg.sender == deployer, "Only the deployer can call this function");
        _;
    }
    
    modifier onlyMembers() {
        require(isMember[msg.sender], "Only team members can call this function");
        _;
    }
    
    constructor(address[] memory _members, uint _credits) {
        require(_members.length > 0, "At least one member is required");
        require(_credits > 0, "Credits must be greater than 0");
        deployer = msg.sender;
        members = _members;
        totalCredits = _credits;
        
        for (uint i = 0; i < _members.length; i++) {
            require(_members[i] != deployer, "Deployer cannot be a team member");
            isMember[_members[i]] = true;
        }
    }
    
    function setWallet(address[] memory _members, uint _credits) public onlyDeployer {
        require(members.length == 0, "Wallet is already set");
        require(_members.length > 0, "At least one member is required");
        require(_credits > 0, "Credits must be greater than 0");
        
        members = _members;
        totalCredits = _credits;
        
        for (uint i = 0; i < _members.length; i++) {
            require(_members[i] != deployer, "Deployer cannot be a team member");
            isMember[_members[i]] = true;
        }
    }
    function spend(uint _amount) public onlyMembers {
    require(_amount > 0, "Amount must be greater than 0");

    Transaction storage newTransaction = transactions.push();
    newTransaction.amount = _amount;
    newTransaction.status = TransactionStatus.Pending;
    newTransaction.approvals = 1; // Approval from the sender by default
}

    function approve(uint _n) public  onlyMembers {
        require(_n < transactions.length, "Transaction does not exist");
        require(!transactions[_n].hasVoted[msg.sender], "You have already voted on this transaction");
        
        transactions[_n].approvals++;
        transactions[_n].hasVoted[msg.sender] = true;
        
        if (transactions[_n].approvals * 100 >= members.length * 70) {
            transactions[_n].status = TransactionStatus.Debited;
            if (transactions[_n].amount <= totalCredits) {
                totalCredits -= transactions[_n].amount;
            } else {
                transactions[_n].status = TransactionStatus.Failed;
            }
        }
    }
    
    function reject(uint _n) public onlyMembers {
        require(_n < transactions.length, "Transaction does not exist");
        require(!transactions[_n].hasVoted[msg.sender], "You have already voted on this transaction");
        
        transactions[_n].hasVoted[msg.sender] = true;
        
        if (transactions[_n].approvals * 100 > members.length * 30) {
            transactions[_n].status = TransactionStatus.Failed;
        }
    }
    
    function credits() public view onlyMembers returns (uint) {
        return totalCredits;
    }
    
    function viewTransaction(uint _n) public view onlyMembers returns (uint, string memory) {
        require(_n < transactions.length, "Transaction does not exist");
        
        if (transactions[_n].status == TransactionStatus.Pending) {
            return (transactions[_n].amount, "pending");
        } else if (transactions[_n].status == TransactionStatus.Debited) {
            return (transactions[_n].amount, "debited");
        } else {
            return (transactions[_n].amount, "failed");
        }
    }
    
}



