// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

interface IERC2981Royalties {
    event ReceivedRoyalties(
        address indexed _royaltyRecipient,
        address indexed _buyer,
        uint256 indexed _tokenId,
        address _tokenPaid,
        uint256 _amount
    );

    function royaltyInfo(uint256 nft) external returns (address gal, uint256 fee);
    function receivedRoyalties(address gal, address buyer, uint256 nft, address gem, uint256 fee) external;
}