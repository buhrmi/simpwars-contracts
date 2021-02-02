// SPDX-License-Identifier: WTFPL

// Tokenized Streamers

pragma solidity >=0.6.0 <0.8.0;

import "./openzeppelin/token/ERC721/ERC721.sol";
import "./openzeppelin/token/ERC20/ERC20Burnable.sol";
import "./openzeppelin/access/Ownable.sol";
import "./openzeppelin/math/SafeMath.sol";


contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract Pricing {
    function price(uint256 streamerId, uint256 blocknumber) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(streamerId, blocknumber))) % 5 ether;
    }

    function price(uint256 streamerId) public view returns (uint256) {
        return price(streamerId, block.number);
    }

    function getPrice(uint256 streamerId) public view returns (uint256) {
        uint256 effectivePrice = price(streamerId);
        
        // If the price was lower in previous block, use the price of previous block
        uint256 prevPrice = price(streamerId, block.number - 1);
        if (prevPrice < effectivePrice) effectivePrice = prevPrice;
        
        return effectivePrice;
    }
}


contract SimpWars is ERC721, Ownable {
    using SafeMath for uint256;
    
    Pricing public pricer = new Pricing();

    mapping(uint => uint) public upgrades;
    mapping(uint => uint) public timestamps;
    mapping(uint => bool) public upgradesAccepted;

    event SimpUpgraded(uint indexed streamerId, uint256 amount);

    address public sutAddress;
    address public proxyRegistryAddress = 0xF57B2c51dED3A29e6891aba85459d600256Cf317; // Rinkeby
    //address public proxyRegistryAddress = 0xa5409ec958c83c3f309868babaca7c86dcb077c1; // Mainnet
    
    string public contractURI = "https://simpwars.loca.lt"; // Rinkeby
    //string public contractURI = "https://simpwars.net"; // Mainnet
    
    constructor(address _sutAddress) ERC721("SimpWars", "SIMPS") {
      sutAddress = _sutAddress;
      _setBaseURI("https://simpwars.loca.lt/metadata/twitch/"); // Rinkeby
      //_setBaseURI("https://simpwars.net/metadata/twitch/"); // Mainnet
    }

    function getUpgrades(uint256 _streamerId) public view returns (uint256) {
        return upgrades[_streamerId];
    }

    function upgradeAccepted(uint256 _streamerId) public view returns (bool) {
        return upgradesAccepted[_streamerId];
    }

    function mintedTimestamp(uint256 _streamerId) public view returns (uint256) {
        return timestamps[_streamerId];
    }

    function setUpgradeAccepted(uint256 _streamerId, bool allowed) public {
        require(ownerOf(_streamerId) == msg.sender);
        upgradesAccepted[_streamerId] = allowed;
    }

    /**
     * @dev Upgrade the simp and burn the SimpUpgradeTokens 
    */
    function upgrade(uint256 _streamerId, uint256 amount) public {
        require(ownerOf(_streamerId) == msg.sender || upgradesAccepted[_streamerId], "you don't have permission to upgrade this simp");
        upgrades[_streamerId] = upgrades[_streamerId].add(amount);
        ERC20Burnable(sutAddress).transferFrom(msg.sender, address(this), amount);
        ERC20Burnable(sutAddress).burn(amount);
        emit SimpUpgraded(_streamerId, amount);
    }

    function price(uint256 _streamerId) public view returns (uint256) {
        return pricer.getPrice(_streamerId);
    }

    /**
     * @dev Withdraw ether from this contract (Callable by owner)
    */
    function withdraw() onlyOwner public {
        uint balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    function setPricer(Pricing newPricer) public onlyOwner {
        pricer = newPricer;
    }

    function setBaseURI(string memory newURI) public onlyOwner {
        _setBaseURI(newURI);
    }
    
    function setContractURI(string memory newURI) public onlyOwner {
        contractURI = newURI;
    }
    
    function purchase(uint256 streamerId) public payable {
        uint256 effectivePrice = price(streamerId);
        
        // Forward payment to contract owner
        payable(owner()).transfer(effectivePrice);

        // Reimburse buyer if paid too much
        msg.sender.transfer(msg.value.sub(effectivePrice));
        
        // Save timestamp of mint
        timestamps[streamerId] = block.timestamp;

        // Mint the ERC721 Token
        _mint(msg.sender, streamerId);
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
