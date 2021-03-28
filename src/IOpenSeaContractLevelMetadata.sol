// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

interface IOpenSeaContractLevelMetadata {
    function contractURI() external view returns (string memory);
}

