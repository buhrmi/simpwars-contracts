// SPDX-License-Identifier: WTFPL

// Tokenized Streamers

pragma solidity >=0.6.0 <0.8.0;

import "./openzeppelin/token/ERC721/IERC721.sol";

interface ISimpWars is IERC721 {
  function mintedTimestamp(uint256) external view returns (uint256);
  function tokenOfOwnerByIndex(address, uint256) external view returns (uint256);
}