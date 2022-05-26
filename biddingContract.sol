// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract asset
{
    

    // DECLARATIONS
    struct bid
    {
        address addr;
        uint value;
    }

    struct owner
    {
        address addr;
    }
    address private constant registerAddress = 0xe5f0332CA42459333149b67aF2d0E486D03F8a83; //just a dummy address for now, feel free to change this

    //DO NOT CHANGE ANY FUNCTION HEADERS
    address[] pastOwners;
    string assetHash;

    owner current;
    uint minimumPrice;
    bid[] bids;

    constructor(string memory dataHash)
    {
        // Code here
        assetHash = dataHash;
        //"f31b20043b639d23b3e51800afbe33b4938c3a3e246d7c000fead1dffa49c610";
        current.addr = tx.origin;
        pastOwners.push(tx.origin);
        minimumPrice = 0;
    }

    function getHistoryOfOwners() public view returns(address[] memory)
    {
        // Code here
        // address[] memory temp; //Feel free to delete this
        return pastOwners;
    }

    function getOwner() public view returns(address)
    {
        // Code here
        address temp = current.addr;
        return temp;
    }

    function getDataHash() public view returns(string memory)
    {
        // Code here
        return assetHash;
    }

    function getMinimumPrice() public view returns(uint)
    {
        // Code here
        return minimumPrice;
    }

    
    function setMinimumPrice(uint price) public 
    {
        //Only the owner may call this function
        if(tx.origin != current.addr)
        {
            revert("Only owner can call this function");
        }
        else
        {
            minimumPrice = price;
            for(uint i = 0; i < bids.length; i++)
            {
                if(bids[i].value < minimumPrice)
                {
                    address payable receiver = payable(bids[i].addr);
                    receiver.transfer(bids[i].value);
                    bids[i].value = 0;
                }
            }
        }

        // Code here
        return;
    }

    function sell() public
    {
        //Only the owner may call this function
        //This function may only be called by the owner if there is at least one bid

        // Code here
     
        // require(bids.length > 0, "There the should be at least 1 bid");
        if(tx.origin != current.addr)
        {
            revert("Only owner can call this function");
        }
        else if(bids.length < 1)
        {
            revert("There should be at least 1 bid");
        }
        else
        {
            address  maxAddr = bids[0].addr;
            uint  maxValue = bids[0].value;
            for(uint i = 0; i < bids.length; i++)
            {
                if(bids[i].value != 0 )
                {
                    if(bids[i].value > maxValue)
                    {
                        maxAddr = bids[i].addr;
                        maxValue = bids[i].value;
                    }
                }
            }

            // selling  to the new owner
            address payable  currentOwner = payable(current.addr);
            currentOwner.transfer(maxValue);
            current.addr = maxAddr;
            
            pastOwners.push(maxAddr);

            Register r = Register(registerAddress);
            r.submit("22100253",maxValue);
            
            // refunding
            for(uint i = 0; i < bids.length; i++)
            {
                if(bids[i].addr != maxAddr)
                {
                    if(bids[i].value != 0)
                    {
                        address payable receiver = payable(bids[i].addr);
                        receiver.transfer(bids[i].value);
                        bids[i].value = 0;
                    }
                }
            }
            delete bids;
            
                    

        }
        return;
    }

    function viewBid(uint index) public view returns(bid memory)
    {
        //Only the owner may call this function
        //This function should revert with an error "That bid number does not exist" if you try to access a bid number that does not exist.
        
        // Code here
        bid memory temp;
        if(tx.origin != current.addr)
        {
            revert("Only owner can call this function");
        }
        else
        {
            temp = bids[index];
        }
        return temp;
    }

    function getNumberOfBids() public view returns(uint)
    {
        //Only the owner may call this function

        // Code here
        uint value;
        if(tx.origin != current.addr)
        {
            revert("Only owner can call this function");
        }
        value = bids.length;
        return value;
    }
    function addressExists(address adr) private view returns(uint)
    {
        for(uint i = 0; i < bids.length; i++)
        {
            if(adr == bids[i].addr)
            {
                return i;
            }
        }
        return 0;
    }
    function submitBid() public payable 
    {
        //The owner may not call this function
        //In addition, the bid must be higher than the minimum price defined by set minimum price as defined in the handout.
        // Code here
        uint i = addressExists(tx.origin);
        bool check = true;
        if(i == 0){ check = false;}

        if(check)
        {
            uint index = addressExists(tx.origin);
            if(tx.origin == bids[index].addr)
            {
                bids[index].value += msg.value;
                return;
            }
        }
        if(tx.origin == current.addr)
        {
            revert("Owner can't call this function");
        }
        if(msg.value < minimumPrice)
        {
            revert("Bids must offer more than minimumPrice");
        }
        else
        {   
            bid memory newBid;
            newBid.value = msg.value;
            newBid.addr = tx.origin;
            bids.push(newBid);
        }
        return;
    }

    function getOwnBidAmount() public view returns (uint)
    {
        // Code here
        
        for(uint i = 0; i < bids.length; i++)
        {
            if(tx.origin == bids[i].addr)
            {
                return bids[i].value;
            }
        }
        return 0;
    }


}


//DO NOT CHANGE ANYTHING IN THIS
contract Register
{
    struct submission
    {
        string rollNumber;
        uint Value;
    }

    function getHistory(uint index) public view returns (submission memory) {}
    
    function submit(string memory rollNumber, uint Value) public {}
}
