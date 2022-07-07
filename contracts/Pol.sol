// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 假设同一SP的[不同读写操作、不同资源], 属性requirement是一样的.

// Defining interface to interact with AP contract
interface IAP {
    function attrCheck(address addrSC, address addrSP) external view returns(bool);
}

// Defining interface to interact with TRS contract
interface ITRS {
    function repCheck(address addrSC, int repSP) external view returns (bool);
    function repUpdate(address addrSC, address addrSP, bool IsPos) external returns (bool);
    function getRepValue(address addr_) external view returns (int);
    function revToken(address addrSC, address addrSP, int rep_, uint exp_, uint l_, uint t_) external returns (bool);
}

// Defining interface to interact with SIG contract
// interface ISIG {
//     function verify(address _from, address _to, uint _r, uint _tao, bytes memory signature) external pure returns (bool); 
// }

// Only Source Provider(SP) or the Manager has the permissoin to modify the Policy(P).
contract POL {
    
    // Use variable-admin to store the address of AA
    address payable admin;

    // Initialize AP contract: set administrator
    constructor() {
        admin = payable(msg.sender);
    }

    // Modifier
    modifier onlyOwner() {
        require(
        msg.sender == admin,
        "This function is restricted to the contract's owner"
        );
        _;
    }

    // Structure for storing attributes
    struct attr {
        string attrName;
        string attrType;
        string attrValue;
    }

    struct attrs {
        int reputation;
        uint attrNum;
        mapping(uint => attr) attrmap;
    }

    mapping(address => attrs) public attributes;

    // Structure of MessageR: R=<addrSC,addrSP,r,tao,Sig_SC>
    struct MessageR {
        address addrSC;
        address addrSP;
        uint r; // the resource identifier,e.g., r = 0(resource 0), r = 1(resource 1), r =2(all resources).
        uint tao; // the allowed set of actions,e.g., tao = 0(read),tao = 1(write),tao = 2(stream),tao = 3(all).
        bytes sig_SC; // the signature of the request message, which is used for authentication.
    }

    // Structure of TokenR: Token_R=<addrSC,addrSP,Rep,Exp,l,t>
    struct TokenR {
        address addrSC;
        address addrSP;
        int rep;   // SC Repution
        uint exp;   // the available time for SC to access the resource
        uint l;     // throughput limit
        uint t;     // timestamp
    }
    
    TokenR public token;

    ////////////////////
    // Address for storing the address of attribute contract
    address public apAddr;

    // Address for storing the address of reputation contract
    address public trsAddr;

    // Address for storing the address of signature contract
    address public sigAddr;

    // Update the adresses of AP, TRS, SIG contracts
    function apAddrUpdate(address apAddr_) public onlyOwner returns (bool) {

        apAddr = apAddr_; 

        return true;
    }

    function trsAddrUpdate(address trsAddr_) public onlyOwner returns (bool) {

        trsAddr = trsAddr_; 
    
        return true;
    }

    function sigAddrUpdate(address sigAddr_) public onlyOwner returns (bool) {

        sigAddr = sigAddr_; 
    
        return true;
    }

    // Recive the attribute-policy of device and add them to the attribute list
    function attrAdd(address addr, attr memory attr_) public onlyOwner returns (bool) {

        attributes[addr].attrNum++;
        attributes[addr].attrmap[attributes[addr].attrNum - 1] = attr_;

        return true;
    }
    
    // Delete the attribute-policy of device
    function attrDel(address addr) public onlyOwner returns (bool) {

        delete attributes[addr];
    
        return true;
    }

    // Modify i-th attribute-policy of device
    function attrMod(address addr, uint index, attr memory attr_) external onlyOwner returns (bool) {

        attributes[addr].attrmap[index] = attr_;

        return true;
    }

    // Add / Modify the reputation-policy of device
    function repMod(address addr, int rep) external onlyOwner returns (bool) {

        attributes[addr].reputation = rep;

        return true;
    }

    // Return number of attribute-policy of device
    function getAttrNum(address addr) public view returns(uint) {

        return attributes[addr].attrNum;
    }

    // Return the attribute-policy of device
    function getAttr(address addr, uint index) public view returns(string memory, string memory, string memory) {

        attr memory attr_ = attributes[addr].attrmap[index];
        
        return(attr_.attrName, attr_.attrType, attr_.attrValue);
    }

    // Signature checking
    function sigVerify(MessageR memory message) public view returns (bool) {
        
        return true;
        // return ISIG(sigAddr).verify(message.addrSC, message.addrSP, message.r, message.tao, message.sig_SC); 
    }


    // Do AttrCheck by calling the corresponding function to CTR_AP
    function attrCheck(address consumer, address provider) public view returns (bool) {
        
        return IAP(apAddr).attrCheck(consumer ,provider);
    }

    // Do RepCheck by calling the corresponding function to CTR_TRS
    function repCheck(address consumer, int providerRep) public view returns (bool) {

        return ITRS(trsAddr).repCheck(consumer, providerRep);
    }

    // Create token
    event tokenCreated(address addrSC, uint timestamp);

    function tokenCreate(MessageR memory message) public returns (TokenR memory) {

        token.rep = ITRS(trsAddr).getRepValue(message.addrSC);
        token.addrSC = message.addrSC;
        token.addrSP = message.addrSP;

        if (token.rep >= 100){
            token.exp = 96;
            token.l = 100;
            token.t = block.timestamp;
        }
        else {
            token.exp = 48;
            token.l = 50;
            token.t = block.timestamp;
        }

        emit tokenCreated(message.addrSC, token.t);

        return token;
    }

    // Send token to TRS and SC
    function sendToken(MessageR memory message) public returns (bool, uint) {
        
        // Signature checking
        if (!sigVerify(message)) {return (false, 0);}

        // AttrCheck and repCheck
        if (attrCheck(message.addrSC, message.addrSP) && repCheck(message.addrSC, attributes[message.addrSP].reputation)) {

            // Token creation
            token = tokenCreate(message);

            // Update reputation
            ITRS(trsAddr).repUpdate(message.addrSC, message.addrSP, true);

            // Send token to trs
            ITRS(trsAddr).revToken(message.addrSC, message.addrSP, token.rep, token.exp, token.l, token.t);

            return (true, token.t);
        }
        else {
            // Update reputation
            ITRS(trsAddr).repUpdate(message.addrSC, message.addrSP, false);

            return (true, token.t);
        }
    }
 
    //-----------------------------------------------
    // Rep_min | A_p attributes | c_p<Exp,l>  | tao_p | r
    // 10      | pass           | 24h,10Mpps  | read  0            | resource 0
    // 50      | pass           | 48h,50Mpps  | read or write 0,1  | resource 0
    // 100     | pass           | 96h,100Mpps | all   3            | all      2

    // struct TokenR{
    //     uint Rep;   //SC Repution
    //     uint Exp;   //the available time for SC to access the resource
    //     uint l;     //throughput
    //     uint t;     //timestamp
    // }

    // Selfdestruct operation to remove the code and storage of the AP contract from the blockchain
    function destroy() external onlyOwner {

        selfdestruct(admin);
    }
}