// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CarRental {
    //struct to represent a car
    struct Car {                            
        uint256 id;
        string name;
        bool isAvailable;
        uint256 rentalPrice;
    }

    mapping(uint256 => Car) public cars;     //mapping to store car data using carId
    address public owner;                     //address of the contract  owner
    mapping(address => uint256) public balances;   // Store user balances
    uint256[] public addedCardIds;              // store added car IDs

    event CarRented(uint256 carId, address renter, uint rentalPrice);  //event to log car rental

    constructor() {                         //constructor to set the contract oener
        owner = msg.sender;
    }

     // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function addCar(uint256 _id, string memory _name, uint256 _rentalPrice) public onlyOwner {
        require(!cars[_id].isAvailable, "Car with this ID already exists");

         cars[_id] = Car(_id, _name, true, _rentalPrice);
         addedCardIds.push(_id);        //add the car ID to the list
    }

        function getAddedIds() public view returns(uint256[] memory){
            return addedCardIds;        //Return the list of added carIds
        }


     //function to rent a car
    function rentCar(uint256 carId) public payable {       
        require(cars[carId].isAvailable, "Car is not available for rent");
        uint256 rentalPrice = cars[carId].rentalPrice;
        require(msg.value>= rentalPrice,"Insufficient payment");
        
        address payable carOwner=payable(owner);              // Transfer funds to the car owner
        carOwner.transfer(rentalPrice);

        balances[msg.sender]+=msg.value-rentalPrice;            // update the user balance
        cars[carId].isAvailable = false;                        // Mark car as Unavailable

       emit CarRented(carId, msg.sender,rentalPrice);          //Emit an  event to log the car rental
    }


    // Function to return a car (only callable by the contract owner)
    function returnCar(uint256 carId) public {           
        require(msg.sender == owner, "Only the owner can return the car");
        cars[carId].isAvailable = true;                 // mark car as available
    }

    function withdrawBalance() public {    
        uint256 balance = balances[msg.sender];
        require(balance > 0,"no balance to withdraw");
    
         balances[msg.sender]=0;                        //reset the user's balnce

        payable (msg.sender).transfer(balance);         //transfer fund to the user

    }
}
