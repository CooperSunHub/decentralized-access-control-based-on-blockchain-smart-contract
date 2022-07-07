// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract is only deployed by Attribute Authority(AA).
// Only AA has permission to add/delete/modify the attribute of device.  

// Defining interface to interact with POL contract
interface IPOL {
    function getAttrNum(address addr) external view returns(uint);
    function getAttr(address addr, uint index) external view returns(string memory, string memory, string memory);
}

// Defining interface to interact with POL contract
interface IBU {
    function attrAdd(address addr, string memory Name_, string memory Type_, string memory Value_) external returns (bool);
    function attrDel(address addr) external returns (bool);
    function attrMod(address addr, uint index, string memory Name_, string memory Type_, string memory Value_) external returns (bool);
    function getAttrNum(address addr) external view returns(uint);
    function getAttr(address addr, uint index) external view returns(string memory, string memory, string memory);
}

// Defining the AP contract
contract AP {
    
    // Use variable-admin to store the address of AA
    address payable admin;

    // Initialize AP contract: set administrator
    constructor() {
        admin = payable(msg.sender);
    }

    // Data structure for storing attributes
    struct attr {
        string attrName;
        string attrType;
        string attrValue;
    }

    // Address for storing the address of policy contract
    address public polAddr;

    // Address for storing the address of backup contract
    address public buAddr;

    // Modifier
    modifier onlyOwner() {
        require(
        msg.sender == admin,
        "This function is restricted to the contract's owner"
        );
        _;
    }

    // Updating the address of policy contract
    function polAddrUpdate(address polAddr_) public onlyOwner returns (bool) {

        polAddr = polAddr_;

        return true;
    }

    // Updating the address of backup contract
    function buAddrUpdate(address buAddr_) public onlyOwner returns (bool) {

        buAddr = buAddr_;

        return true;
    }

    // Interact with POL contract
    function getPolAttrNum(address addr) public view returns(uint) { 

        return IPOL(polAddr).getAttrNum(addr);
    }
    
    function getPolAttr(address addr, uint index) public view returns(string memory, string memory, string memory) {

        return IPOL(polAddr).getAttr(addr, index);
    }

    // Interact with BU contract
    function add(address addr, attr memory attr_) public onlyOwner() returns (bool) { 

        return IBU(buAddr).attrAdd(addr, attr_.attrName, attr_.attrType, attr_.attrValue);
    }
    
    function del(address addr) public onlyOwner() returns (bool) {

        return IBU(buAddr).attrDel(addr);
    }

    function mod(address addr, uint index, attr memory attr_) public returns (bool) {

        return IBU(buAddr).attrMod(addr, index, attr_.attrName, attr_.attrType, attr_.attrValue);
    }

    // Return number of attributes of device
    function getNum(address addr) public view returns(uint) {

        return IBU(buAddr).getAttrNum(addr);
    }

    // Return the attribute of device
    function get(address addr, uint index) public view returns(string memory, string memory, string memory) {

        return IBU(buAddr).getAttr(addr, index);
    }

    // Policy-attribute check
    function attrCheck(address addrSC, address addrSP) external view returns(bool) { 

        if (addrSC == addrSP) {return false;}
        
        uint attrPolNum = getPolAttrNum(addrSP);
        uint attrScNum = getNum(addrSC);
        bool success;
        string memory polAttrName;
        string memory polAttrType;
        string memory polAttrValue;
        
        string memory scAttrName;
        string memory scAttrType;
        string memory scAttrValue;

        for (uint i = 0; i < attrPolNum; i++) {
            success = false;

            (polAttrName, polAttrType, polAttrValue) = getPolAttr(addrSP, i);

            for (uint j = 0; j < attrScNum; j++) {

                (scAttrName, scAttrType, scAttrValue) = get(addrSC, j);

                if ((keccak256(abi.encode(polAttrName)) == keccak256(abi.encode(scAttrName))) 
                && (keccak256(abi.encode(polAttrType)) == keccak256(abi.encode(scAttrType))) 
                && (keccak256(abi.encode(polAttrValue)) == keccak256(abi.encode(scAttrValue)))){
                    success = true;
                    break;
                }
            }
            if (success == false) {
                return false;
            }
        }

        return true;
    }

    // Selfdestruct operation to remove the code and storage of the AP contract from the blockchain
    function destroy() external onlyOwner returns (bool) {

        selfdestruct(admin);

        return true;
    }
}