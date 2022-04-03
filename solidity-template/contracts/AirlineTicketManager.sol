// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract AirlineTicketManagerFactory {
    address owner;

    modifier Owner {
        require(msg.sender == owner, "not eligible");
            _;
    }
    constructor() {
        owner = msg.sender;
    }
    AirlineTicketManager[] factoryObjects;
    function newAirlineTicketManager () public Owner{
        AirlineTicketManager ATM = new AirlineTicketManager();
        factoryObjects.push(ATM);
    }

}

contract AirlineTicketManager {
    
    struct reservation {
        address passportId;
        string name;
        string destination;
        Class choice;
    }

    uint256 reservationsCount = 0;
    mapping (uint => reservation) public reservations;
    
    enum Class{FIRST_CLASS, BUSINESS, ECONOMY }

    Class choice = Class.ECONOMY;

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

    uint Economy_price = 0.005 ether;
    uint Business_price = 0.007 ether;
    uint FirstClass_price = 0.01 ether;

    event Received(address, uint);

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

    function makeReservation (string memory _name, string memory _destination) public payable{
        reservationsCount += 1;
        reservations[reservationsCount] = reservation(msg.sender, _name, _destination, choice);
        pay();
    }

    /*------------------------------------------------------------*/
    address owner;

    modifier Owner {
        require(msg.sender == owner, "not eligible");
            _;
    }

    constructor() {
        owner = msg.sender;
    }

    mapping (address => bool) private isAllowed;

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

