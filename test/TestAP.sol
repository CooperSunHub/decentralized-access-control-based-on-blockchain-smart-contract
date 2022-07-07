pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// first two imports are referring to global Truffle files
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AP.sol";

contract TestAP {

    // The address of the AP contract to be tested
    AP ap = AP(DeployedAddresses.AP()); // Cast the address to the AP type

    // Data structure for storing attributes
    struct attr {
        string attrName;
        string attrType;
        string attrValue;
    }

    struct attrs {
        uint attrNum;
        mapping(uint => attr) attrmap;
    }

    // The addresses and attributes that will be used for testing
    address addr1 = 0x4586d8773cA7363174e8c3d6A0e0Ce1Ce7793B98;
    address addr2 = 0xc75Cd18D96B3eab0207C2FB89f723cb31d5B8Fbd;
    attr attr0 = attr('0', '0', '0');
    attr attr1 = attr('1', '1', '1');
    attr attr2 = attr('2', '2', '2');

    // Testing the attrAdd() function
    
    bool public success;
    function testattrAdd() public {
        
        bytes memory data = abi.encodeWithSignature("attrAdd(address, attr)", addr1, addr2);
        success = address(ap).call(data);
        //ap.attrAdd(addr1, attr1);
        //Assert.equal(ap.getAttr(addr1)["attrName"] ,attr1, "hahaha");
    }




//   // The id of the pet that will be used for testing
//   uint expectedPetId = 8;

//   // Testing the adopt() function
//   function testUserCanAdoptPet() public {
//       uint returnedId = adoption.adopt(expectedPetId);
//       // 通过Asset来判断
//       Assert.equal(returnedId, expectedPetId, "Adoption of the expected pet should match what is returned.");
//   }

//   // Testing retrieval of a single pet's owner
//   function testGetAdopterAddressByPetId() public {
//       address adopter = adoption.adopters(expectedPetId);

//       Assert.equal(adopter, expectedAdopter, "Owner of the expected pet should be this contract.");
//   }

//   // Testing retrieval of all pet owners
//   function testGetAdopterAddressByPetIdInArray() public {
//   // Store adopters in memory rather than contract's storage
//     address[16] memory adopters = adoption.getAdopters();

//     Assert.equal(adopters[expectedPetId], expectedAdopter, "Owner of the expected pet should be this contract");
//   }

//   // The expected owner of adopted pet is this contract
//   address expectedAdopter = address(this);
}


    // // Use variable-admin to store the address of AA
    // address payable admin;

    // // Initialize AP contract: set administrator
    // constructor() {
    //     admin = payable(msg.sender);
    // }

    // // Modifier
    // modifier onlyOwner() {
    //     require(
    //     msg.sender == admin,
    //     "This function is restricted to the contract's owner"
    //     );
    //     _;
    // }

    // // Data structure for storing attributes
    // struct attrs {
    //     string attrName;
    //     string attrType;
    //     string attrValue;
    // }

    // mapping(address => attrs[]) public attributes;

    // // Recive the attributes of some devices and add them to the attribute list
    // function attrAdd(address addr, attrs[] memory attr) public onlyOwner{
    //     for(uint i=0; i<attr.length; i++) {
    //         attributes[addr].push(attrs(attr[i].attrName, attr[i].attrType, attr[i].attrValue));
    //     }
    // }

    // // Delete the attributes of some devices
    // function attrDel(address addr) public onlyOwner{
    //     delete attributes[addr];
    // }

    // // Modify the attributes of some devices
    // function attrMod(address addr, attrs[] memory attr) external onlyOwner{
    //     attrDel(addr);
    //     attrAdd(addr, attr);
    // }

    // // Return the attributes of some devices
    // function getAttrCount(address addr) public view returns(uint) {
    //     return attributes[addr].length;
    // }

    // function getAttr(address addr, uint index) public view returns(string memory, string memory, string memory) {
    //     attrs memory attr = attributes[addr][index];

    //     return(attr.attrName, attr.attrType, attr.attrValue);
    // }

    // // Selfdestruct operation to remove the code and storage of the AP contract from the blockchain
    // function destroy() external onlyOwner {
    //     selfdestruct(admin);
    // }