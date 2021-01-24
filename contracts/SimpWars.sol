// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./openzeppelin/token/ERC721/ERC721.sol";
import "./openzeppelin/access/Ownable.sol";
import "./openzeppelin/math/SafeMath.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract SimpWars is ERC721, Ownable {
    using SafeMath for uint256;
        
    address public proxyRegistryAddress = 0xF57B2c51dED3A29e6891aba85459d600256Cf317; // Rinkeby
    //address public proxyRegistryAddress = 0xa5409ec958c83c3f309868babaca7c86dcb077c1; // Mainnet
    
    string public contractURI = "https://simpwars.loca.lt"; // Rinkeby
    //string public contractURI = "https://simpwars.net"; // Mainnet
    
    constructor() ERC721("SimpWars", "SIMPS")  {
        _setBaseURI("https://simpwars.loca.lt/metadata/twitch/"); // Rinkeby
        //_setBaseURI("https://simpwars.net/metadata/twitch/"); // Mainnet
    }
    
    function price(uint256 streamerID) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(streamerID, blockhash(block.number)))) % 5 ether;
    }
    
    function updateBaseURI(string memory newURI) public onlyOwner {
        _setBaseURI(newURI);
    }
    
    function updateContractURI(string memory newURI) public onlyOwner {
        contractURI = newURI;
    }
    
    function purchase(uint256 streamerID) public payable {
         // Forward payment to contract owner
         payable(owner()).transfer(price(streamerID));
         
         // Reimburse buyer if paid too much
         msg.sender.transfer(msg.value.sub(price(streamerID)));
         
         // Mint the token
         _mint(msg.sender, streamerID);
    }
    
    function isApprovedForAll(address owner, address operator) 
        override public virtual view returns (bool) {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }
            
        return super.isApprovedForAll(owner, operator);
    }

    
}