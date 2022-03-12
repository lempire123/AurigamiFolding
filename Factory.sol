pragma solidity ^0.8.0;

import "./Folding.sol";

contract Factory {

    mapping(address => address) public userAddressToProxyAccount;

    function createProxyAccount() public {
        require(userAddressToProxyAccount[msg.sender] == address(0), "Already created a proxy account");
        AurigamiFolding proxyAccount = new AurigamiFolding(msg.sender);
        userAddressToProxyAccount[msg.sender] = address(proxyAccount);
    }
    
}
