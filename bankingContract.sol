// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract BankingSystem {
    // DECLARATIONS

     struct userDetails { 
      string firstname;
      string lastname;
      uint loan;
      uint balance;
   }
    // CODE

    uint private clientCount;
    // store the client's information in structure as mapping
    mapping (address => userDetails) public users;
    // funds in bank
    uint public funds = 0;
    
    // store the current calling client
    address public client;
    // store the deployers account
    address public deployer;
    // store account creator address
    address[] public clients;
    


    // Constructor
    constructor() {
        client = tx.origin;
        deployer = tx.origin;
        users[deployer].firstname = "sajid";
        users[deployer].lastname = "karim";
        users[deployer].balance = 0;
        users[deployer].loan = 0;
        clientCount = 0;
    }

    // check if caller is deployer
    function checkOwner(address caller) public view returns(bool check){
        if(caller == deployer)
            return true;
        else
            return false;
    }


    // TASK 1
    function openAccount(string memory firstName, string memory lastName) public {
        // Code Here!!
        client = tx.origin;
        // check if deployer is trying to create an account
        if (checkOwner(tx.origin)) {
            revert("Error, Owner Prohibited");
        }
        else if (client != deployer){
            if(getClients(client))
                revert("Account already exists");
            else {
                clientCount++;
                users[tx.origin] = userDetails(firstName, lastName, 0, 0);
                clients.push(tx.origin);
            }
        }
    }

    // check whether the user has an account
    function getClients(address clientInput) public view returns (bool check) {

        uint8 j = 0;
        while(j < clients.length)
        {
            if(clientInput == clients[j])
            {
                return true;
            }
            j++;
        }
        return false;

    }
    
    // TASK 2
    function getDetails() public view returns (uint balance, string memory first_name, string memory last_name, uint loanAmount) {   
        // Code Here!!
        if(getClients(tx.origin))
            return (users[tx.origin].balance, users[tx.origin].firstname, users[tx.origin].lastname, users[tx.origin].loan);
        else
            revert("No Account");
    }


    // TASK 3
    // minimum deposit of 1 ether.
    // 1 ether = 10^18 Wei.   
    function depositAmount() public payable {    
        // Code Here!!
        if(getClients(tx.origin))
        {
            if(msg.value < 10**18)
            {
                revert("Low Deposit");
            }
            else
            {
                users[tx.origin].balance += msg.value;
            }
        }
        else
        {
            revert("No Account");
        }
        
        if(checkOwner(tx.origin))
        {
            revert("Error, Owner Prohibited");
        }
    }

    
    // Task 4
    function withDraw(uint withdrawalAmount) public {                
        // Code Here!!
        if(checkOwner(tx.origin))
        {
            revert("Error, Owner Prohibited");
        }
        
        if(getClients(tx.origin))
        {
            if(withdrawalAmount > users[tx.origin].balance)
            {
                revert("Insufficient Funds");
            }
            else
            {
                users[tx.origin].balance -= withdrawalAmount;
                payable(tx.origin).transfer(withdrawalAmount);
            }

        }
        else
        {
            revert("No Account");
        }
    }
    
        
    // Task 5
    function TransferEth(address payable reciepent, uint transferAmount) public {
        // Code Here!!
        if(checkOwner(tx.origin))
        {
            revert("Error, Owner Prohibited");
        }
        
        if(getClients(tx.origin))
        {
            if(transferAmount > users[tx.origin].balance)
            {
                revert("Insufficient Funds");
            }
            else
            {
                if(getClients(reciepent))
                {
                    users[tx.origin].balance -= transferAmount;
                    users[reciepent].balance += transferAmount;
                }
            }
        }
        else
        {
            revert("No Account");
        }
    }


    // Task 6.1
    function depositTopUp() public payable {
        // Code Here!!
        if(checkOwner(tx.origin))
        {
            funds = funds + msg.value; 
        }
        else
        {
            revert("Only owner can call this function");
        }
    }


    // Task 6.2
    function TakeLoan(uint loanAmount) public {
        // Code Here!!
        if(checkOwner(tx.origin))
        {
            revert("Error,Owner Prohibited");
        }
        if(getClients(tx.origin))
        {
            if ( loanAmount > funds)
            {
                revert("Insufficent Loan Funds");
            }
            else if( loanAmount >= 2*users[tx.origin].balance)
            {
                revert("Loan Limit Exceeded");
            }
            else
            {
                users[tx.origin].loan += loanAmount;
                payable(tx.origin).transfer(loanAmount);
                funds = funds - loanAmount;
            }
        }
        else
        {
            revert("No Account");
        }
    }
        

    // Task 6.3
    function InquireLoan() public view returns (uint loanValue) {
        // Code Here!!
        if(getClients(tx.origin))
        {
            if (users[tx.origin].loan != 0)
                return (users[tx.origin].loan);
        }
        else
        {
            revert("No Account");
        }
        
    }


    // Task 7 
    function returnLoan() public payable  {
        // Code Here!!
        if(getClients(tx.origin))
        {
            if(users[tx.origin].loan == 0)
            {
                revert("No Loan");
            }
            else if( msg.value > users[tx.origin].loan)
            {
                revert("Owed Amount Exceeded");
            }
            else
            {
                funds += msg.value;
                users[tx.origin].loan -= msg.value;
            }
        }
        else
        {
            revert("No Account");
        }
        
    }


    function AmountInBank() public view returns(uint) {
            // DONT ALTER THIS FUNCTION
            return address(this).balance;
    }
     

    
}   
