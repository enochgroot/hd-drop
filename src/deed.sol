// SPDX-License-Identifier: GPL-3.0-or-later

/// deed.sol -- basic ERC721 implementation

// Copyright (C) 2020  Brian McMichael

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity >=0.6.0;

import "erc721/erc721.sol";
import "./IERC2981Royalties.sol";
import "./IOpenSeaContractLevelMetadata.sol";
import "./IRaribleRoyaltiesV1.sol";

contract DSDeed is ERC721, ERC721Enumerable, ERC721Metadata, IERC2981Royalties, IOpenSeaContractLevelMetadata, IRaribleRoyaltiesV1 {

    uint8                            public   hard;

    bool                             public   stopped;
    mapping (address => uint)        public   wards;

    uint256                          private  _ids;

    string                           internal _name;
    string                           internal _symbol;
    string                           internal _uri;

    mapping (uint256 => string)      internal _uris;

    mapping (bytes4 => bool)         internal _interfaces;

    uint256[]                        internal _allDeeds;
    mapping (address => uint256[])   internal _usrDeeds;
    mapping (uint256 => Deed)        internal _deeds;
    mapping (address => mapping (address => bool)) internal _operators;

    struct Deed {
        uint256      pos;     // position in _allDeeds
        uint256     upos;     // position in _usrDeeds
        address      guy;     // creator
        address approved;     // appoved usr
        uint256    nonce;     // nonce to prove work
        address      gal;     // fee recipient
        uint256      fee;     // fee 0 or [100_000, 10_000_000]
    }

    // events
    event Stop();
    event Start();
    event Rely(address indexed guy);
    event Deny(address indexed guy);
    event ReceivedRoyalties(
        address indexed _royaltyRecipient,
        address indexed _buyer,
        uint256 indexed _tokenId,
        address _tokenPaid,
        uint256 _amount
    );

    // safe math
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    constructor(string memory name, string memory symbol, uint8 _hard, string memory uri) public {
        _name = name;
        _symbol = symbol;
        hard = _hard;
        _uri = uri;
        _addInterface(0x80ac58cd); // ERC721
        _addInterface(0x5b5e139f); // ERC721Metadata
        _addInterface(0x780e9d63); // ERC721Enumerable
        _addInterface(0x4b7f2c2d); // IERC2981Royalties
        _addInterface(0xe8a3d485); // IOpenSeaContractLevelMetadata
        _addInterface(0xb7799584); // IRaribleRoyaltiesV1

        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    modifier nod(uint256 nft) {
        require(
            _deeds[nft].guy == msg.sender ||
            _deeds[nft].approved == msg.sender ||
            _operators[_deeds[nft].guy][msg.sender],
            "ds-deed-insufficient-approval"
        );
        _;
    }

    modifier stoppable {
        require(!stopped, "ds-deed-is-stopped");
        _;
    }

    modifier auth {
        require(wards[msg.sender] == 1, "ds-deed-not-authorized");
        _;
    }

    function name() external override view returns (string memory) {
        return _name;
    }

    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 nft) external override view returns (string memory) {
        return _uris[nft];
    }

    function totalSupply() external override view returns (uint256) {
        return _allDeeds.length;
    }

    function tokenByIndex(uint256 idx) external override view returns (uint256) {
        return _allDeeds[idx];
    }

    function tokenOfOwnerByIndex(address guy, uint256 idx) external override view returns (uint256) {
        require(idx < balanceOf(guy), "ds-deed-index-out-of-bounds");
        return _usrDeeds[guy][idx];
    }

    function onERC721Received(address, address, uint256, bytes calldata) external override returns(bytes4) {
        revert("ds-deed-does-not-accept-tokens");
    }

    function _isContract(address addr) private view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470; // EIP-1052
        assembly { codehash := extcodehash(addr) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function supportsInterface(bytes4 interfaceID) external override view returns (bool) {
        return _interfaces[interfaceID];
    }

    function _addInterface(bytes4 interfaceID) private {
        _interfaces[interfaceID] = true;
    }

    function balanceOf(address guy) public override view returns (uint256) {
        require(guy != address(0), "ds-deed-invalid-address");
        return _usrDeeds[guy].length;
    }

    function ownerOf(uint256 nft) external override view returns (address) {
        require(_deeds[nft].guy != address(0), "ds-deed-invalid-nft");
        return _deeds[nft].guy;
    }

    function safeTransferFrom(address src, address dst, uint256 nft, bytes calldata what) external override payable {
        _safeTransfer(src, dst, nft, what);
    }

    function safeTransferFrom(address src, address dst, uint256 nft) public override payable {
        _safeTransfer(src, dst, nft, "");
    }

    function push(address dst, uint256 nft) external {
        safeTransferFrom(msg.sender, dst, nft);
    }

    function pull(address src, uint256 nft) external {
        safeTransferFrom(src, msg.sender, nft);
    }

    function move(address src, address dst, uint256 nft) external {
        safeTransferFrom(src, dst, nft);
    }

    function _safeTransfer(address src, address dst, uint256 nft, bytes memory data) internal {
        transferFrom(src, dst, nft);
        if (_isContract(dst)) {
            bytes4 res = ERC721TokenReceiver(dst).onERC721Received(msg.sender, src, nft, data);
            require(res == this.onERC721Received.selector, "ds-deed-invalid-token-receiver");
        }
    }

    function transferFrom(address src, address dst, uint256 nft) public override payable stoppable nod(nft) {
        require(src == _deeds[nft].guy, "ds-deed-src-not-valid");
        require(dst != address(0) && dst != address(this), "ds-deed-unsafe-destination");
        require(_deeds[nft].guy != address(0), "ds-deed-invalid-nft");
        _upop(nft);
        _upush(dst, nft);
        _approve(address(0), nft);
        emit Transfer(src, dst, nft);
    }

    function mint(address guy, string memory uri, uint256 nonce, address gal, uint256 fee) public auth stoppable returns (uint256 nft) {
        return _mint(guy, uri, nonce, address(gal), fee);
    }

    function _mint(address guy, string memory uri, uint256 nonce, address gal, uint256 fee) internal returns (uint256 nft) {
        require(guy != address(0), "ds-deed-invalid-address");
        require(fee <= 10_000_000, "ds-deed-invalid-fee");

        nft = _ids++;
        require(work(nft, nonce, hard), "ds-deed-failed-work");
        hard = hard + 1;

        _allDeeds.push(nft);
        _deeds[nft] = Deed(
            _allDeeds[_allDeeds.length - 1],
            _usrDeeds[guy].length - 1,
            guy,
            address(0),
            nonce,
            (gal != address(0)) ? gal : guy,
            fee
        );
        _upush(guy, nft);
        _uris[nft] = uri;

        emit Transfer(address(0), guy, nft);
    }

    function burn(uint256 nft) public auth stoppable {
        _burn(nft);
    }

    function _burn(uint256 nft) internal {
        address guy = _deeds[nft].guy;
        require(guy != address(0), "ds-deed-invalid-nft");

        uint256 _idx        = _deeds[nft].pos;
        uint256 _mov        = _allDeeds[_allDeeds.length - 1];
        _allDeeds[_idx]     = _mov;
        _deeds[_mov].pos    = _idx;
        _allDeeds.pop();    // Remove from All deed array
        _upop(nft);         // Remove from User deed array

        delete _deeds[nft]; // Remove from deed mapping

        emit Transfer(guy, address(0), nft);
    }

    function _upush(address guy, uint256 nft) internal {
        _deeds[nft].upos           = _usrDeeds[guy].length;
        _usrDeeds[guy].push(nft);
        _deeds[nft].guy            = guy;
    }

    function _upop(uint256 nft) internal {
        uint256[] storage _udds    = _usrDeeds[_deeds[nft].guy];
        uint256           _uidx    = _deeds[nft].upos;
        uint256           _move    = _udds[_udds.length - 1];
        _udds[_uidx]               = _move;
        _deeds[_move].upos         = _uidx;
        _udds.pop();
        _usrDeeds[_deeds[nft].guy] = _udds;
    }

    function approve(address guy, uint256 nft) external override payable stoppable nod(nft) {
        _approve(guy, nft);
    }

    function _approve(address guy, uint256 nft) internal {
        _deeds[nft].approved = guy;
        emit Approval(msg.sender, guy, nft);
    }

    function setApprovalForAll(address op, bool ok) external override stoppable {
        _operators[msg.sender][op] = ok;
        emit ApprovalForAll(msg.sender, op, ok);
    }

    function getApproved(uint256 nft) external override returns (address) {
        require(_deeds[nft].guy != address(0), "ds-deed-invalid-nft");
        return _deeds[nft].approved;
    }

    function isApprovedForAll(address guy, address op) external override view returns (bool) {
        return _operators[guy][op];
    }

    function _lshift(bytes32 bits, uint256 shift) internal pure returns (bytes32) {
        return bytes32(mul(uint256(bits), 2 ** shift));
    }

    function _firstn(bytes32 bits, uint256 num) internal pure returns (bytes32) {
        bytes32 ones = bytes32(sub(2 ** num, 1));
        bytes32 mask = _lshift(ones, sub(256, num));
        return bits & mask;
    } 

    // validate a proof-of-work for a given NFT, with a nonce, at a difficulty level
    function work(uint256 id, uint256 nonce, uint8 difficulty) public view returns (bool) {
        bytes32 candidate = _firstn(keccak256(abi.encodePacked(address(this), id, nonce)), difficulty);
        bytes32 target = _firstn(bytes32(uint256(address(this)) << 96), difficulty);
        return (candidate == target);
    }

    function stop() external auth {
        stopped = true;
        emit Stop();
    }

    function start() external auth {
        stopped = false;
        emit Start();
    }

    function rely(address guy) external auth {
        wards[guy] = 1;
        emit Rely(guy);
    }

    function deny(address guy) external auth {
        wards[guy] = 0;
        emit Deny(guy);
    }

    function setTokenUri(uint256 nft, string memory uri) public auth stoppable {
        _uris[nft] = uri;
    }

    function royaltyInfo(uint256 nft) public override returns (address receiver, uint256 amount) {
        return (_deeds[nft].gal, _deeds[nft].fee);
    }

    function receivedRoyalties(address gal, address buyer, uint256 nft, address gem, uint256 fee) public override {
        emit ReceivedRoyalties(gal, buyer, nft, gem, fee);
    }

    function getFeeRecipients(uint256 nft) external view override returns (address payable[] memory) {
        address payable[] memory result = new address payable[](1);
        result[0] = payable(_deeds[nft].gal);
        return result;
    }

    function getFeeBps(uint256 nft) external view override returns (uint[] memory) {
        uint[] memory result = new uint[](1);
        // TODO: normalize fee for rarible
        result[0] = _deeds[nft].fee;
        return result;
    }

    function contractURI() public view override returns (string memory) {
        return _uri;
    }
}
