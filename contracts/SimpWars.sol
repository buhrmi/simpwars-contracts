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

contract SimpWars is ERC721, Ownable {
    using SafeMath for uint256;

    uint256 public SECONDS_IN_A_DAY = 864000;
    uint256 constant FALLOFF_BASE = 0xFFFF79679FF758000000000000000000; // = 0.9999919775 * 2^128

    uint256 public nextPrice = 1 ether;
    uint256 public lastPurchase = block.timestamp;


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

    function price() public view returns (uint256) {
        
        uint256 elapsedSeconds = block.timestamp - lastPurchase;
        if (elapsedSeconds == 0) return nextPrice;

        // Apply logarithmic falloff. The FALLOFF_BASE is selected in a way so that
        // after 86400 seconds (24h) factor is 0.5
        uint256 factor = pow(FALLOFF_BASE, elapsedSeconds);
        uint256 effectivePrice = mul(nextPrice, factor);

        return effectivePrice;
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

    /**
     * @dev Withdraw ether from this contract (Callable by owner)
    */
    function withdraw() onlyOwner public {
        uint balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    fallback() external payable {
        revert();
    }

    function setBaseURI(string memory newURI) public onlyOwner {
        _setBaseURI(newURI);
    }
    
    function setContractURI(string memory newURI) public onlyOwner {
        contractURI = newURI;
    }
    
    function purchase(uint256 streamerId) public payable {
        uint256 effectivePrice = price();
        
        // Forward payment to contract owner
        payable(owner()).transfer(effectivePrice);

        // Reimburse buyer if paid too much
        msg.sender.transfer(msg.value.sub(effectivePrice));
        
        // Save timestamp of mint
        timestamps[streamerId] = block.timestamp;

        // Save the next purchase price
        nextPrice = effectivePrice * 2;

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


    // Math tools
    uint256 constant TWO_128 = 0x100000000000000000000000000000000; // 2^128
    uint256 constant TWO_127 = 0x80000000000000000000000000000000; // 2^127
    
    /**
    * Multiply _a by _b / 2^128.  Parameter _a should be less than or equal to
    * 2^128 and parameter _b should be less than 2^128.
    *
    * @param _a left argument
    * @param _b right argument
    * @return _result = _a * _b / 2^128
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 _result) {
        assert(_a <= TWO_128);
        assert(_b < TWO_128);
        return (_a * _b + TWO_127) >> 128;
    }

    /**
    * Calculate (_a / 2^128)^_b * 2^128.  Parameter _a should be less than 2^128.
    *
    * @param _a left argument
    * @param _b right argument
    * @return _result = (_a / 2^128)^_b * 2^128
    */
    function pow(uint256 _a, uint256 _b) internal pure returns (uint256 _result) {
        assert(_a < TWO_128);

        _result = TWO_128;
        while (_b > 0) {
            if (_b & 1 == 0) {
                _a = mul (_a, _a);
                _b >>= 1;
            }
            else {
                _result = mul (_result, _a);
                _b -= 1;
            }
        }
    }
        
}
