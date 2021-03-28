// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

interface IERC2981Royalties {
    function royaltyInfo(uint256 nft) external returns (address gal, uint256 fee);
    function receivedRoyalties(address gal, address buyer, uint256 nft, address gem, uint256 fee) external;
}