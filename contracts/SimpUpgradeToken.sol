// SPDX-License-Identifier: WTFPL

pragma solidity >=0.6.0 <0.8.0;

import "./openzeppelin/math/SafeMath.sol";
import "./openzeppelin/token/ERC20/ERC20.sol";
import "./openzeppelin/GSN/Context.sol";
import "./ISimps.sol";

/**
 *
 * SimpUpgradeToken Contract (The native token of SimpWars)
 * @dev Extends standard ERC20 contract
 */
contract SimpUpgradeToken is ERC20 {
    using SafeMath for uint256;

    // Constants
    uint256 public SECONDS_IN_A_DAY = 86400;

    // Public variables
    uint256 public emissionPerDay = 10 * (10 ** 18);

    mapping(uint256 => uint256) private _lastClaim;

    address private _simpsAddress;

    constructor() ERC20("Simp Upgrade Token", "SUT") {}

    /**
     * @dev When accumulated SUTs have last been claimed for a Simp index
     */
    function lastClaim(uint256 tokenIndex) public view returns (uint256) {
        require(ISimps(_simpsAddress).ownerOf(tokenIndex) != address(0), "Owner cannot be 0 address");
        uint256 emissionStart = ISimps(_simpsAddress).mintedTimestamp(tokenIndex);
        uint256 lastClaimed = uint256(_lastClaim[tokenIndex]) != 0 ? uint256(_lastClaim[tokenIndex]) : emissionStart;
        return lastClaimed;
    }
    
    /**
     * @dev Accumulated SUT tokens for a Simp token index.
     */
    function accumulated(uint256 tokenIndex) public view returns (uint256) {

        require(ISimps(_simpsAddress).ownerOf(tokenIndex) != address(0), "Owner cannot be 0 address");

        uint256 lastClaimed = lastClaim(tokenIndex);

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
     * @dev Claim mints SUTs and supports multiple Simp token indices at once.
     */
    function claim(uint256[] memory tokenIndices) public returns (uint256) {

        uint256 totalClaimAmount = 0;
        for (uint i = 0; i < tokenIndices.length; i++) {
            // Duplicate token index check
            for (uint j = i + 1; j < tokenIndices.length; j++) {
                require(tokenIndices[i] != tokenIndices[j], "Duplicate token index");
            }

            uint tokenIndex = tokenIndices[i];
            require(ISimps(_simpsAddress).ownerOf(tokenIndex) == msg.sender, "Sender is not the owner");

            uint256 claimAmount = accumulated(tokenIndex);
            if (claimAmount != 0) {
                totalClaimAmount = totalClaimAmount.add(claimAmount);
                _lastClaim[tokenIndex] = block.timestamp;
            }
        }

        require(totalClaimAmount != 0, "No accumulated SUT");
        _mint(msg.sender, totalClaimAmount); 
        return totalClaimAmount;
    }

}