// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

interface IRaribleRoyaltiesV1 {
    event SecondarySaleFees(uint256 tokenId, address[] recipients, uint[] bps);

    function getFeeRecipients(uint256 nft) external view returns (address payable[] memory);
    function getFeeBps(uint256 nft) external view returns (uint[] memory);
}
