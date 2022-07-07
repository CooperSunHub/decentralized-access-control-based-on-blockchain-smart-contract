// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ABDK Libraries: Math 64.64
import "../abdk-libraries-solidity/ABDKMath64x64.sol" as MathTool; 

// This contract is only deployed by Attribute Authority(AA).
// Only AA has permission to add/delete/modify the attribute of device.  

// Defining interface to interact with POL contract
interface IPOL {
    //function getAttrNum(address addr) external view returns(uint);
    //function getAttr(address addr, uint index) external view returns(string memory, string memory, string memory);
}

// Defining the TRS contract
contract TRS {

    // Parameters
    int BETAPOS = 10;
    int BETANEG = -20;
    int NUMERATOR = 95;
    int DENOMINATOR = 100;

    // Use variable-admin to store the address of AA
    address admin;

    // Initialize AP contract: set administrator
    constructor() {
        admin = msg.sender;
    }

    // Modifier
    modifier onlyOwner() {
        require(
        msg.sender == admin,
        "This function is restricted to the contract's owner"
        );
        _;
    }

    // Address for storing the address of policy contract
    address public polAddr;

    // Updating the address of policy contract
    function polAddrUpdate(address polAddr_) public onlyOwner {

        polAddr = polAddr_;
        admin = 0x0000000000000000000000000000000000000000; // change the owner address to an empty address
    }

    // Data structure for storing reputations
    struct rep {
        int nPeers; 
        mapping(address => bool) recordSP;
        int reputation;
    }

    mapping(address => rep) public reputations;
    
    // function testrep(address addr_) public view returns (int, int) {
    //     return (reputations[addr_].nPeers, reputations[addr_].reputation);
    // }

    // Data structure for storing Token
    struct token {
        address addrSP;
        int rep;
        uint exp;
        uint l;
        uint t;
    }

    mapping(address => mapping(uint => token)) public tokens; // Searching a certain token by the hash of token(timestamp) 

    // Updating reputation
    function repUpdate(address addrSC, address addrSP, bool IsPos) public returns (bool) {

        //require(msg.sender == polAddr, "This function is restricted to the POL contract");

        if (reputations[addrSC].recordSP[addrSP] == false) {
            reputations[addrSC].recordSP[addrSP] = true;
            reputations[addrSC].nPeers++;
        }

        if (IsPos == true) {
            reputations[addrSC].reputation = reputations[addrSC].reputation * NUMERATOR / DENOMINATOR + BETAPOS;
        }
        else {
            reputations[addrSC].reputation = reputations[addrSC].reputation * NUMERATOR / DENOMINATOR + BETANEG;
        }   

        return true;
    }

    // Return the reputation of certain device 
    function getRepValue(address addr_) public view returns (int) {

        int repSC;
        int ln_nPeers;
        int128 int128_ln_nPeers;
        int64 int64_ln_nPeers;

        if (reputations[addr_].nPeers == 0) {return 0;}

        int128_ln_nPeers = MathTool.ABDKMath64x64.fromInt(reputations[addr_].nPeers);
        int64_ln_nPeers = MathTool.ABDKMath64x64.toInt(MathTool.ABDKMath64x64.ln(int128_ln_nPeers));
        ln_nPeers = int(int64_ln_nPeers);

        repSC = reputations[addr_].reputation * ln_nPeers;

        return repSC;
    }

    // Check whether the reputation of SC meets the requirement of SP
    function repCheck(address addrSC, int repSP) external view returns (bool) {

        int repSC = getRepValue(addrSC);

        if (repSC >= repSP) {
            return true;
        }
        else {
            return false;
        }
    }
    
    // Recive a token from POL contract
    function revToken(address addrSC, address addrSP, int rep_, uint exp_, uint l_, uint t_) public returns (bool) {
    
        //require(msg.sender == polAddr, "This function is restricted to the POL contract");

        tokens[addrSC][t_].addrSP = addrSP;
        tokens[addrSC][t_].rep = rep_;
        tokens[addrSC][t_].exp = exp_;
        tokens[addrSC][t_].l = l_;
        tokens[addrSC][t_].t = t_;

        return true;
    }

    // Return a token of device
    function getToken(address addr, uint t_) public view returns (address, address, int, uint, uint, uint) {

        return(addr, tokens[addr][t_].addrSP, tokens[addr][t_].rep, tokens[addr][t_].exp, tokens[addr][t_].l, tokens[addr][t_].t);
    }
}