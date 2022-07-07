// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract is only deployed by Attribute Authority(AA).
// Only AA has permission to add/delete/modify the attribute of device.  

// Defining the BU contract
contract BU {
    
    // Use variable-admin to store the address of AA
    address payable admin;

    // Initialize BU contract: set administrator
    constructor() {
        admin = payable(msg.sender);
    }

    // Address for storing the address of attribute contract
    address public attrAddr;

    // Modifier
    modifier onlyOwner() {
        require(
        msg.sender == admin,
        "This function is restricted to the contract's owner"
        );
        _;
    }

    // Updating the address of policy contract
    function attrAddrUpdate(address attrAddr_) public onlyOwner returns (bool) {

        attrAddr = attrAddr_;

        return true;
    }

    // Data structure for storing attributes
    struct attr {
        string attrName;
        string attrType;
        string attrValue;
    }

    struct attrHash {
        bytes32 attrNameHash;
        bytes32 attrTypeHash;
        bytes32 attrValueHash;
    }

    struct attrs {
        uint attrNum;
        mapping(uint => attr) attrmap;
    }

    mapping(address => attrs) public attributes;


    // Recive the attributes of device and add them to the attribute list
    function attrAdd(address addr,string memory Name_, string memory Type_, string memory Value_) public returns (bool) {

        require(msg.sender == attrAddr);

        attributes[addr].attrNum++;
        attributes[addr].attrmap[attributes[addr].attrNum - 1].attrName = Name_;
        attributes[addr].attrmap[attributes[addr].attrNum - 1].attrType = Type_;
        attributes[addr].attrmap[attributes[addr].attrNum - 1].attrValue = Value_;

        return true;
    }

    // Delete all attributes of certain device
    function attrDel(address addr) public returns (bool) {

        require(msg.sender == attrAddr);

        delete attributes[addr];

        return true;
    }

    // Modify i-th attribute of device
    function attrMod(address addr, uint index, string memory Name_, string memory Type_, string memory Value_) public returns (bool) {

        require(msg.sender == attrAddr);

        attributes[addr].attrmap[index].attrName = Name_;
        attributes[addr].attrmap[index].attrType = Type_;
        attributes[addr].attrmap[index].attrValue = Value_;

        return true;
    }

    // Return the number of attributes of device
    function getAttrNum(address addr) public view returns (uint) {

        return attributes[addr].attrNum;
    }

    // Return the attributes of device
    function getAttr(address addr, uint index) public view returns (string memory, string memory, string memory) {

        attr memory attr_ = attributes[addr].attrmap[index];

        return(attr_.attrName, attr_.attrType, attr_.attrValue);
    }

    // Selfdestruct operation to remove the code and storage of the AP contract from the blockchain
    function destroy() external onlyOwner {

        selfdestruct(admin);
    }
}