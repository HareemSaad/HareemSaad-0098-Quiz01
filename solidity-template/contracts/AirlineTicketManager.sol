// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

//factory contract
contract AirlineTicketManagerFactory {
    //modifier
    address owner;

    modifier Owner {
        require(msg.sender == owner, "not eligible");
            _;
    }
    constructor() {
        owner = msg.sender;
    }
    
    //factory function
    AirlineTicketManager[] factoryObjects;
    function newAirlineTicketManager () public Owner{
        AirlineTicketManager ATM = new AirlineTicketManager();
        factoryObjects.push(ATM);
    }

}

contract AirlineTicketManager {

    //task 1 structs and mapping
    
    struct reservation {
        address passportId;
        string name;
        string destination;
        Class choice;
    }

    uint256 reservationsCount = 0;
    mapping (uint => reservation) public reservations; //uint represents reservation id same user can make multiple reservations
    
    //task 2 enums
    enum Class{FIRST_CLASS, BUSINESS, ECONOMY }

    Class choice = Class.ECONOMY;

    //functions to let user choose class, choice is updated in choice variable
    function setFirstClass() public {
        choice = Class.FIRST_CLASS;
    }
    function setBusinessClass() public {
        choice = Class.BUSINESS;
    }
    function setEconomy() public {
        choice = Class.ECONOMY;
    }
    function getChoice() public view returns (string memory) {
        if(choice == Class.BUSINESS) {
            return "business";
        } else if(choice == Class.ECONOMY) {
            return "economy";
        } else if(choice == Class.FIRST_CLASS) {
            return "first class";
        }
        return "economy";
    }
    // function setClassChoice(Class _choice) public {
    //     choice = _choice;
    // }

    //task 3 set price
    uint Economy_price = 0.005 ether;
    uint Business_price = 0.007 ether;
    uint FirstClass_price = 0.01 ether;

    //task 4 payments
    event Received(address, uint);

    //method receives ether and sends the extra ether back
    function pay() internal {
        uint moneyToReturn;
        if(reservations[reservationsCount].choice == Class.FIRST_CLASS) {
            require (msg.value >= FirstClass_price);
            emit Received(msg.sender, msg.value);
            moneyToReturn = msg.value - FirstClass_price; 
        } else if(reservations[reservationsCount].choice == Class.BUSINESS) {
            require (msg.value >= Business_price);
            emit Received(msg.sender, msg.value);
            moneyToReturn = msg.value - Business_price; 
        } else if(reservations[reservationsCount].choice == Class.ECONOMY) {
            require (msg.value >= Economy_price);
            emit Received(msg.sender, msg.value);
            moneyToReturn = msg.value - Economy_price; 
        }
        if(moneyToReturn > 0)
                payable(msg.sender).transfer(moneyToReturn);
    }

    //main function: sets user address as passportid chosen choice, and inputs _name and _destination
    function makeReservation (string memory _name, string memory _destination) public payable{
        reservationsCount += 1;
        reservations[reservationsCount] = reservation(msg.sender, _name, _destination, choice);
        pay();
    }

    /*------------------------------------------------------------*/
    //task 5
    address owner;

    modifier Owner {
        require(msg.sender == owner, "not eligible");
            _;
    }

    constructor() {
        owner = msg.sender;
    }

    mapping (address => bool) private isAllowed; //if an address is true its whitelisted.

    function addUser(address _user) public Owner{
        isAllowed[_user] = true;
    }

    function removeUser(address _user) public Owner{
        delete isAllowed[_user];
    }

    function getAllowed(address _user) public view Owner returns (bool){
       return isAllowed[_user];
    }
}

