pragma solidity ^0.5.13;

contract Mapping{
    mapping (uint => bool) public boolMapping;
    mapping (uint8 => address) public Address;
    mapping (address => bool) public whitelistedAddress;
    mapping (address => uint256) public holders;
    
    address owner;
    address contractAddress = address(this);
    uint256 public latestTxn;
    bool private contractPaused = false;
    
    function setBoolMapping(uint _index, bool _bool) public{
        boolMapping[_index] = _bool;
    }
    
    function setAddressMapping(uint8 _index, address _address) private {
        Address[_index] = _address;
    }
    
    function setAddressWhitelist(address _address) private {
        whitelistedAddress[_address] = true;
    }
    
    function pauseContract() public {
        require(msg.sender == owner);
        contractPaused = true;
    }
    
    function resumeContract() public {
        require(msg.sender == owner);
        contractPaused = false;
    }
    
    function addHolder(address _address, uint256 _amount) private {
        if(holders[_address] > 0){
            holders[_address] += _amount;
        } else {
            holders[_address] = _amount;
        }
    }
    
    constructor() public{
        owner = msg.sender;
        setAddressMapping(0, 0x0000000000000000000000000000000000000000);
        setAddressMapping(1, address(this));
        setAddressMapping(2, owner);
        
        // setAddressWhitelist(0xD6EA605729d56a4512B2E2d4Bb42C2912F80C0dB);
        // setAddressWhitelist(0xFCEe58764ac2D81b33b955a39d843245EC64aAcD)
    }
    
    function getContractBalance() public view returns(uint256){
        require(!contractPaused);
        return address(this).balance;
    }
    
    function getUserBalance() public view returns (uint256){
        require(!contractPaused);
        return holders[msg.sender];
    }
    
    function receiveFunds() public payable{
        require(!contractPaused);
        require(msg.sender != contractAddress);
        require(msg.value > 0, "Amount must be greater than 0");
        latestTxn = msg.value;
        addHolder(msg.sender, msg.value);
    }
    
    
    function ownerWithdrawAllFunds() public {
        require(!contractPaused);
        require(msg.sender == owner, "Only contract owner can withdraw all funds");
        address payable _to = msg.sender;
        _to.transfer(getContractBalance());
    }
    
    function destroyContract() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }
    
    function userWithdraw(uint _amount) public {
        uint256 amount = _amount * 10 ** 18;
        address payable _to = msg.sender;
        require(!contractPaused);
        require(holders[_to] >= amount, "Cannot withdraw more than its deposit");
        require(amount > 0);
        require(amount <= getContractBalance());
        holders[_to] -= amount;
        _to.transfer(amount);
    }
    
    function userWithdrawAll() public {
        address payable _to = msg.sender;
        uint256 holderBalance = holders[_to];
        require(holderBalance > 0, "Holder address has balance of zero");
        require(_to != Address[0], "Dead address cannot withdraw balance");
        require(_to != Address[1], "Contract address cannot withdraw balance");
        _to.transfer(holderBalance);
    }
    

    
    
    
    
}







