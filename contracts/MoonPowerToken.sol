// MOON POWER TOKEN
//
// The perfect token to upgrade your Simps
// Play now at https://simpwars.net

// SPDX-License-Identifier: WTFPL

pragma solidity >=0.6.0 <0.8.0;

import "./openzeppelin/math/SafeMath.sol";
import "./openzeppelin/token/ERC20/ERC20Burnable.sol";
import "./openzeppelin/GSN/Context.sol";
import "./ISimpWars.sol";

/**
 *
 * SimpPowerToken Contract (The native token of SimpWars)
 * @dev Extends standard ERC20 contract
 */
contract MoonPowerToken is ERC20Burnable {
    using SafeMath for uint256;

    // Constants
    uint256 public SECONDS_IN_A_DAY = 86400;

    // Public variables
    uint256 public emissionPerDay = 10 * (10 ** 18);

    mapping(uint256 => uint256) private _lastClaim;

    address private _simpsAddress;

    constructor() ERC20("Moon Power Token", "MPT") {}

    /**
     * @dev When accumulated SPTs have last been claimed for a Simp index
     */
    function lastClaim(uint256 simpId) public view returns (uint256) {
        require(ISimpWars(_simpsAddress).ownerOf(simpId) != address(0), "Owner cannot be 0 address");
        uint256 emissionStart = ISimpWars(_simpsAddress).mintedTimestamp(simpId);
        uint256 lastClaimed = uint256(_lastClaim[simpId]) != 0 ? uint256(_lastClaim[simpId]) : emissionStart;
        return lastClaimed;
    }

    /**
     * @dev Claim all SPT from all owned simps
     */
    function claimAll() public {
        uint256 balance = ISimpWars(_simpsAddress).balanceOf(msg.sender);
        uint256[] memory simpIds = new uint[](balance);
        for (uint256 i = 0; i < balance; i++) {
            simpIds[i] = (ISimpWars(_simpsAddress).tokenOfOwnerByIndex(msg.sender, i));
        }
        claim(simpIds);
    }
    
    /**
     * @dev Accumulated SPT tokens for a Simp token index.
     */
    function accumulated(uint256 simpId) public view returns (uint256) {

        require(ISimpWars(_simpsAddress).ownerOf(simpId) != address(0), "Owner cannot be 0 address");
        uint256 lastClaimed = lastClaim(simpId);
        uint256 totalAccumulated = block.timestamp.sub(lastClaimed).mul(emissionPerDay).div(SECONDS_IN_A_DAY);
        return totalAccumulated;
    }

    /**
     * @dev Permissioning not added because it is only callable once. It is set right after deployment and verified.
     */
    function setSimpsAddress(address simpsAddress) public {
        require(_simpsAddress == address(0), "Already set");
        _simpsAddress = simpsAddress;
    }
    
    /**
     * @dev Claim mints SPTs and supports multiple Simp token indices at once.
     */
    function claim(uint256[] memory tokenIndices) public returns (uint256) {

        uint256 totalClaimAmount = 0;
        for (uint i = 0; i < tokenIndices.length; i++) {
            // Duplicate token index check
            for (uint j = i + 1; j < tokenIndices.length; j++) {
                require(tokenIndices[i] != tokenIndices[j], "Duplicate token index");
            }

            uint simpId = tokenIndices[i];
            require(ISimpWars(_simpsAddress).ownerOf(simpId) == msg.sender, "Sender is not the owner");

            uint256 claimAmount = accumulated(simpId);
            if (claimAmount != 0) {
                totalClaimAmount = totalClaimAmount.add(claimAmount);
                _lastClaim[simpId] = block.timestamp;
            }
        }

        require(totalClaimAmount != 0, "No accumulated SPT");
        _mint(msg.sender, totalClaimAmount); 
        return totalClaimAmount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        // Approval check is skipped if the caller of transferFrom is the SimpWars contract. For better UX.
        if (msg.sender == _simpsAddress) {
          _transfer(sender, recipient, amount);
          return true;
        }
        return super.transferFrom(sender, recipient, amount);
    }

}
