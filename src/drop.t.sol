// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.20;

import "ds-test/test.sol";

import "./drop.sol";

contract DropUser {

    Drop drop;

    constructor(Drop _drop) public {
        drop = _drop;
    }

    function doTransferFrom(address from, address to, uint nft) public {
        drop.transferFrom(from, to, nft);
    }

    function doSafeTransferFrom(address from, address to, uint nft) public {
        drop.safeTransferFrom(from, to, nft);
    }

    function doSafeTransferFrom(
        address from, address to, uint nft, bytes memory data
    ) public {
        drop.safeTransferFrom(from, to, nft, data);
    }

    function doBalanceOf(address who) public view returns (uint) {
        return drop.balanceOf(who);
    }

    function doApprove(address guy, uint nft) public {
        drop.approve(guy, nft);
    }

    function doSetApprovalForAll(address guy, bool ok) public {
        drop.setApprovalForAll(guy, ok);
    }

    function doPush(address who, uint nft) public {
        drop.push(who, nft);
    }
    function doPull(address who, uint nft) public {
        drop.pull(who, nft);
    }
    function doMove(address src, address dst, uint nft) public {
        drop.move(src, dst, nft);
    }

    function onERC721Received(
        address, address, uint256, bytes calldata
    ) external pure returns(bytes4) {
        return this.onERC721Received.selector;
    }
}

contract TokenReceiver {

    uint256 public tokensReceived;

    function onERC721Received(
        address, address, uint256, bytes calldata
    ) external returns (bytes4) {
        tokensReceived++;
        return this.onERC721Received.selector;
    }
}

contract BadTokenReceiver { uint256 one = 0; }


contract DropTest is DSTest {
    Drop drop;

    string  _name        = "TestToken";
    string  _symb        = "TEST";
    address _addr        = 0x00000000219ab540356cBB839Cbe05303d7705Fa;
    address _addr2       = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    string  _uri         = "https://etherscan.io/address/0x00000000219ab540356cBB839Cbe05303d7705Fa";
    string  _contractURI = "https://metadata-url.com/my-metadata";

    uint256 public constant NONCE  = 0;
    uint256 public constant NONCE1 = 5;
    uint256 public constant NONCE2 = 11;
    uint256 public constant NONCE3 = 6;
    uint256 public constant NONCE4 = 10;
    uint256 public constant NONCE5 = 24;
    uint256 public constant NONCE6 = 48;
    uint256 public constant NONCE7 = 38;
    uint256 public constant NONCE8 = 392;
    uint256 public constant NONCE9 = 646;

    DropUser alice;
    DropUser bob;
    TokenReceiver receiver;
    BadTokenReceiver badreceiver;

    function setUp() public {
        drop  = new Drop(_name, _symb, 0, _contractURI);
        alice = new DropUser(drop);
        bob   = new DropUser(drop);

        receiver = new TokenReceiver();
        badreceiver = new BadTokenReceiver();
    }

    function testMint() public {
        assertEq(drop.totalSupply(), 0);

        drop.mint(_addr, _uri, NONCE, _addr, 0);

        assertEq(drop.totalSupply(), 1);
    }

    function testERC165() public {
        // 
        //  bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
        //  bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
        // 
        //  => 0x0ebd4c7f ^ 0xb9c4d9fb == 0xb7799584
        // 
        // assertEq(drop.contractURI.selector, 0);
    }

    function testMintMany() public {
        assertEq(drop.totalSupply(), 0);

        drop.mint(_addr, _uri, NONCE, _addr, 0);
        drop.mint(_addr, "t1", NONCE1, _addr, 0);
        drop.mint(_addr, "t2", NONCE2, _addr, 0);
        drop.mint(_addr, "t3", NONCE3, _addr, 0);
        drop.mint(_addr, "t4", NONCE4, _addr, 0);
        drop.mint(_addr, "t5", NONCE5, _addr, 0);
        drop.mint(_addr, "t6", NONCE6, _addr, 0);
        drop.mint(_addr, "t7", NONCE7, _addr, 0);
        drop.mint(_addr, "t8", NONCE8, _addr, 0);

        assertEq(drop.totalSupply(), 9);
        assertEq(drop.tokenURI(8), "t8");

    }

    function testBurn() public {
        drop.mint(_addr, _uri, NONCE, _addr, 0);
        assertEq(drop.totalSupply(), 1); // setup

        drop.burn(0);
        assertEq(drop.totalSupply(), 0);
    }

    function testBurnMany() public {
        drop.mint(_addr, _uri, NONCE, _addr, 0);
        drop.mint(_addr, "t1", NONCE1, _addr, 0);
        drop.mint(_addr, "t2", NONCE2, _addr, 0);
        drop.mint(_addr, "t3", NONCE3, _addr, 0);
        drop.mint(_addr, "t4", NONCE4, _addr, 0);
        drop.mint(_addr, "t5", NONCE5, _addr, 0);
        drop.mint(_addr, "t6", NONCE6, _addr, 0);
        drop.mint(_addr, "t7", NONCE7, _addr, 0);
        drop.mint(_addr, "t8", NONCE8, _addr, 0);
        assertEq(drop.totalSupply(), 9);  // setup

        drop.burn(7);
        assertEq(drop.totalSupply(), 8);
        assertEq(drop.ownerOf(6), _addr);
        drop.burn(6);
        drop.burn(2);
        drop.burn(8);
        drop.burn(1);
        assertEq(drop.totalSupply(), 4);
    }

    // ERC721
    /// title ERC-721 Non-Fungible Token Standard
    /// dev See https://eips.ethereum.org/EIPS/eip-721
    ///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.

    /// dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to
    ///  none.
    // event Transfer(
    //     address indexed _from, address indexed _to, uint256 indexed _tokenId
    // );

    /// dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    // event Approval(
    //     address indexed _owner,
    //     address indexed _approved,
    //     uint256 indexed _tokenId
    // );

    /// dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    // event ApprovalForAll(
    //     address indexed _owner, address indexed _operator, bool _approved
    // );

    /// notice Count all NFTs assigned to an owner
    /// dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// param _owner An address for whom to query the balance
    /// return The number of NFTs owned by `_owner`, possibly zero
    //function balanceOf(address _owner) external view returns (uint256);
    function testBalanceOf() public {
        assertEq(drop.balanceOf(_addr),  0);
        assertEq(drop.balanceOf(_addr2),  0);

        drop.mint(_addr, _uri, NONCE, _addr,  0);
        drop.mint(_addr,  "t1", NONCE1, _addr, 0);
        drop.mint(_addr,  "t2", NONCE2, _addr, 0);
        drop.mint(_addr2, "t3", NONCE3, _addr, 0);
        drop.mint(_addr2, "t4", NONCE4, _addr, 0);
        drop.mint(_addr2, "t5", NONCE5, _addr, 0);
        drop.mint(_addr,  "t6", NONCE6, _addr, 0);

        assertEq(drop.balanceOf(_addr),  4);
        assertEq(drop.balanceOf(_addr2), 3);

        drop.burn(4);

        assertEq(drop.balanceOf(_addr),  4);
        assertEq(drop.balanceOf(_addr2), 2);
    }

    function testFailBalanceOf() public view {
        // function throws for queries about the zero address.
        drop.balanceOf(address(0));
    }

    /// notice Find the owner of an NFT
    /// dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// param _tokenId The identifier for an NFT
    /// return The address of the owner of the NFT
    function testOwnerOf() public {
        drop.mint(address(this), _uri, NONCE,  address(this), 0);
        drop.mint(address(101),  "t1", NONCE1, address(this), 0);

        assertEq(drop.ownerOf(0), address(this));
        assertEq(drop.ownerOf(1), address(101));

        drop.approve(address(this), 0);
        drop.transferFrom(address(this), address(102), 0);

        assertEq(drop.ownerOf(0), address(102));
    }

    function testFailOwnerOf() public {
        drop.mint(address(this), _uri, NONCE, address(this), 0);
        // We can't test revert on check of address(0) because we can't
        // transfer to address(0)
        drop.transferFrom(address(this), address(0), 0);
        drop.ownerOf(0);
    }

    /// notice Transfers the ownership of an NFT from one address to another
    /// address dev Throws unless `msg.sender` is the current owner, an
    /// authorized operator, or the approved address for this NFT. Throws if
    /// `_from` is ///  not the current owner. Throws if `_to` is the zero
    /// address. Throws if ///  `_tokenId` is not a valid NFT. When transfer is
    /// complete, this function ///  checks if `_to` is a smart contract
    /// (code size > 0). If so, it calls `onERC721Received` on `_to` and throws
    /// if the return value is not
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// param _from The current owner of the NFT
    /// param _to The new owner
    /// param _tokenId The NFT to transfer
    /// param data Additional data with no specified format, sent in call to
    /// `_to`
    // function safeTransferFrom(
    //     address _from, address _to, uint256 _tokenId, bytes data
    // ) external payable;
    function testSafeTransferFromWithData() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        // _addr is EOA (can't use address(bob) because that's a contract
        alice.doSafeTransferFrom(address(alice), _addr, 0, "Some data");

        assertEq(drop.ownerOf(0),_addr);
    }

    function testSafeTransferFromContractWithData() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doSafeTransferFrom(
            address(alice), address(receiver), 0, "Some data"
        );

        assertEq(drop.ownerOf(0), address(receiver));
        assertEq(receiver.tokensReceived(), 1); // Ensure receiver was called.
    }


    /// notice Transfers the ownership of an NFT from one address to another
    /// address dev This works identically to the other function with an extra
    /// data parameter, except this function just sets data to "".
    /// param _from The current owner of the NFT
    /// param _to The new owner
    /// param _tokenId The NFT to transfer
    // function safeTransferFrom(
    //     address _from, address _to, uint256 _tokenId
    // ) external payable;
    function testSafeTransferFromEOA() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        // _addr is EOA (can't use address(bob) because that's a contract
        alice.doSafeTransferFrom(address(alice), _addr, 0);

        assertEq(drop.ownerOf(0), _addr);
    }

    function testSafeTransferFromContract() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doSafeTransferFrom(address(alice), address(receiver), 0);

        assertEq(drop.ownerOf(0), address(receiver));
        assertEq(receiver.tokensReceived(), 1); // Ensure receiver was called.
    }

    function testFailSafeTransferFromBadContract() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        /// it calls
        ///  `onERC721Received` on `_to` and throws if the return value is not
        ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
        alice.doSafeTransferFrom(address(alice), address(badreceiver), 0);
    }

    function testFailSafeTransferFromZeroAddr() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        // Throws if `_to` is the zero address.
        alice.doSafeTransferFrom(address(alice), address(0), 0);
    }

    function testFailSafeTransferFromInvalidNFT() public {
        // Throws if `_tokenId` is not a valid NFT.
        alice.doSafeTransferFrom(address(alice), address(0), 0);
    }


    /// notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// param _from The current owner of the NFT
    /// param _to The new owner
    /// param _tokenId The NFT to transfer
    // function transferFrom(
    //     address _from, address _to, uint256 _tokenId
    // ) external payable;
    function testTransferFrom() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doTransferFrom(address(alice), address(bob), 0);

        assertEq(drop.ownerOf(0), address(bob));
    }

    function testTransferFromNoCheck() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        // Useless contract. Tokens can be lost.
        alice.doTransferFrom(address(alice), address(badreceiver), 0);

        // Transfer will succeed without a check.
        assertEq(drop.ownerOf(0), address(badreceiver));
    }

    function testFailTransferFromNonOwner() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        bob.doTransferFrom(address(alice), address(bob), 0);
    }

    function testFailTransferFromWrongOwner() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        // Throws if `_from` is not the current owner.
        alice.doTransferFrom(address(bob), address(alice), 0);
    }

    function testFailTransferFromToZeroAddress() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        // Throws if `_to` is the zero address.
        alice.doTransferFrom(address(alice), address(0), 0);
    }

    function testFailTransferFromInvalidNFT() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        // Throws if `_tokenId` is not a valid NFT.
        alice.doTransferFrom(address(alice), address(bob), 1);
    }


    /// notice Change or reaffirm the approved address for an NFT
    /// dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// param _approved The new approved NFT controller
    /// param _tokenId The NFT to approve
    //function approve(address _approved, uint256 _tokenId) external payable;
    function testApprove() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doApprove(address(bob), 0);

        assertEq(drop.getApproved(0), address(bob));

        bob.doApprove(address(this), 0);

        assertEq(drop.getApproved(0), address(this));
        
        drop.mint(address(alice), "", NONCE1, address(alice), 0);
        alice.doSetApprovalForAll(address(bob), true);

        bob.doApprove(address(1), 1);

        assertEq(drop.getApproved(1), address(1));
    }

    function testFailApprove() public {
        //Throws unless `msg.sender` is the current NFT owner, or an authorized
        ///  operator of the current owner.
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        bob.doApprove(address(this), 0);
    }

    /// notice Enable or disable approval for a third party ("operator") to
    /// manage all of `msg.sender`'s assets
    /// dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// param _operator Address to add to the set of authorized operators
    /// param _approved True if the operator is approved, false to revoke approval
    //function setApprovalForAll(address _operator, bool _approved) external;
    function testSetApprovalForAll() public {
        drop.mint(address(alice), _uri, NONCE, address(alice), 0);
        drop.mint(address(alice), "t1", NONCE1, address(alice), 0);
        drop.mint(address(alice), "t2", NONCE2, address(alice), 0);
        drop.mint(address(alice), "t3", NONCE3, address(alice), 0);
        drop.mint(address(alice), "t4", NONCE4, address(alice), 0);

        alice.doSetApprovalForAll(address(bob), true);

        drop.mint(address(alice), "t5", NONCE5, address(alice), 0);
        drop.mint(address(alice), "t6", NONCE6, address(alice), 0);

        assertTrue(drop.isApprovedForAll(address(alice), address(bob)));

        bob.doPull(address(alice), 2);

        alice.doSetApprovalForAll(address(bob), false);
        assertTrue(!drop.isApprovedForAll(address(alice), address(bob)));
    }

    /// notice Get the approved address for a single NFT
    /// dev Throws if `_tokenId` is not a valid NFT.
    /// param _tokenId The NFT to find the approved address for
    /// return The approved address for this NFT, or the zero address if there is none
    //function getApproved(uint256 _tokenId) external view returns (address);
    function testGetApproved() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        assertEq(drop.getApproved(0), address(0));

        alice.doApprove(address(bob), 0);

        assertEq(drop.getApproved(0), address(bob));
    }

    // Throws if `_tokenId` is not a valid NFT.
    function testFailGetApproved() public {
        drop.getApproved(3);
    }

    /// notice Query if an address is an authorized operator for another address
    /// param _owner The address that owns the NFTs
    /// param _operator The address that acts on behalf of the owner
    /// return True if `_operator` is an approved operator for `_owner`, false
    /// otherwise
    // function isApprovedForAll(
    //     address _owner, address _operator
    // ) external view returns (bool);
    function testIsApprovedForAll() public {
        assertTrue(!drop.isApprovedForAll(address(alice), address(bob)));
        alice.doSetApprovalForAll(address(bob), true);
        assertTrue(drop.isApprovedForAll(address(alice), address(bob)));
    }


    //interface ERC165 {
    /// notice Query if a contract implements an interface
    /// param interfaceID The interface identifier, as specified in ERC-165
    /// dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    //function supportsInterface(bytes4 interfaceID) external view returns (bool);
    function testSupportsInterface() public {
        assertTrue(drop.supportsInterface(0x80ac58cd));
        assertTrue(drop.supportsInterface(0x5b5e139f));
        assertTrue(drop.supportsInterface(0x780e9d63));

        assertTrue(!drop.supportsInterface(0x01234567));
        assertTrue(!drop.supportsInterface(0xffffffff));
    }

    /// dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
    //interface ERC721TokenReceiver {
    /// notice Handle the receipt of an NFT
    /// dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// param _operator The address which called `safeTransferFrom` function
    /// param _from The address which previously owned the token
    /// param _tokenId The NFT identifier which is being transferred
    /// param _data Additional data with no specified format
    /// return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    // function onERC721Received(
    //     address _operator, address _from, uint256 _tokenId, bytes _data
    // ) external returns(bytes4);
    function testFailOnERC721Received() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        drop.onERC721Received(address(alice), address(alice), 0, "");
    }


    // ERC721 Metadata
    /// title ERC-721 Non-Fungible Token Standard, optional metadata extension
    /// dev See https://eips.ethereum.org/EIPS/eip-721
    ///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.

    /// notice A descriptive name for a collection of NFTs in this contract
    function testName() public {
        assertEq(drop.name(), _name);
    }

    /// notice An abbreviated name for NFTs in this contract
    function testSymbol() public {
        assertEq(drop.symbol(), _symb);
    }

    /// notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function testTokenURI() public {
        drop.mint(_addr, _uri, NONCE, _addr, 0);  //setup
        drop.mint(_addr, "t2", NONCE1, _addr, 0);

        assertEq(drop.tokenURI(0), _uri);
        assertEq(drop.tokenURI(1), "t2");
    }

    function testWork() public {
        assertEq(address(drop), 0xE58d97b6622134C0436d60daeE7FBB8b965D9713);

        // for(uint256 i = 0; i < 100000; i++) {
        //     if (drop.work(9, i, 9)) {
        //         assertEq(i, 9);
        //         break;
        //     }
        // }

        // test for hard = 0
        uint256 nft = drop.mint(_addr, _uri, NONCE, _addr, 0);
        assertEq(nft, 0);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE, drop.hard() - 1));

        // test for hard = 1
        nft = drop.mint(_addr, _uri, NONCE1, _addr, 0);
        assertEq(nft, 1);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE1, drop.hard() - 1));

        // test for hard = 2
        nft = drop.mint(_addr, _uri, NONCE2, _addr, 0);
        assertEq(nft, 2);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE2, drop.hard() - 1));

        // test for hard = 3
        nft = drop.mint(_addr, _uri, NONCE3, _addr, 0);
        assertEq(nft, 3);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE3, drop.hard() - 1));

        // test for hard = 4
        nft = drop.mint(_addr, _uri, NONCE4, _addr, 0);
        assertEq(nft, 4);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE4, drop.hard() - 1));

        // test for hard = 5
        nft = drop.mint(_addr, _uri, NONCE5, _addr, 0);
        assertEq(nft, 5);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE5, drop.hard() - 1));

        // test for hard = 6
        nft = drop.mint(_addr, _uri, NONCE6, _addr, 0);
        assertEq(nft, 6);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE6, drop.hard() - 1));

        // test for hard = 7
        nft = drop.mint(_addr, _uri, NONCE7, _addr, 0);
        assertEq(nft, 7);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE7, drop.hard() - 1));

        // test for hard = 8
        nft = drop.mint(_addr, _uri, NONCE8, _addr, 0);
        assertEq(nft, 8);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE8, drop.hard() - 1));

        // test for hard = 9
        nft = drop.mint(_addr, _uri, NONCE9, _addr, 0);
        assertEq(nft, 9);
        assertEq(nft, uint(drop.hard()) - 1);
        assertTrue(drop.work(nft, NONCE9, drop.hard() - 1));
    }

    function testFailWork() public {
        assertEq(address(drop), 0xE58d97b6622134C0436d60daeE7FBB8b965D9713);
        assertEq(uint(drop.hard()), 0);
        drop.mint(_addr, _uri, 0, _addr, 0);
        assertEq(uint(drop.hard()), 1);

        assertTrue(drop.work(1, 0, 1));
    }

    function testIERC2981Royalties10() public {
        // 10% fee
        uint256 nft = drop.mint(_addr, _uri, NONCE, address(alice), 1_000_000);
        (address gal, uint256 fee) = drop.royaltyInfo(nft);
        assertEq(gal, address(alice));
        assertEq(fee, 1_000_000);
    }

    function testIRaribleRoyaltiesV1_10() public {
        // 10% fee
        uint256 nft = drop.mint(_addr, _uri, NONCE, address(alice), 1_000_000);
        address payable[] memory gals = new address payable[](1);
        gals = drop.getFeeRecipients(nft);
        uint[] memory fees = new uint[](1);
        fees = drop.getFeeBps(nft);
        assertEq(gals[0], payable(address(alice)));
        assertEq(fees[0], 1_000);
    }

    function testIERC2981Royalties100() public {
        // 100% fee
        uint256 nft = drop.mint(_addr, _uri, NONCE, address(bob), 10_000_000);
        (address gal, uint256 fee) = drop.royaltyInfo(nft);
        assertEq(gal, address(bob));
        assertEq(fee, 10_000_000);
    }

    function testIRaribleRoyaltiesV1_100() public {
        // 100% fee
        uint256 nft = drop.mint(_addr, _uri, NONCE, address(alice), 10_000_000);
        address payable[] memory gals = new address payable[](1);
        gals = drop.getFeeRecipients(nft);
        uint[] memory fees = new uint[](1);
        fees = drop.getFeeBps(nft);
        assertEq(gals[0], payable(address(alice)));
        assertEq(fees[0], 10_000);
    }

    function testERC2981Royalties01() public {
        // 0.1% fee
        uint256 nft = drop.mint(_addr, _uri, NONCE, address(alice), 10_000);
        (address gal, uint256 fee) = drop.royaltyInfo(nft);
        assertEq(gal, address(alice));
        assertEq(fee, 10_000);
    }

    function testIRaribleRoyaltiesV1_01() public {
        // 0.1% fee
        uint256 nft = drop.mint(_addr, _uri, NONCE, address(alice), 10_000);
        address payable[] memory gals = new address payable[](1);
        gals = drop.getFeeRecipients(nft);
        uint[] memory fees = new uint[](1);
        fees = drop.getFeeBps(nft);
        assertEq(gals[0], payable(address(alice)));
        assertEq(fees[0], 10);
    }

    function testERC2981Royalties00001() public {
        // 0.00001% fee
        uint256 nft = drop.mint(_addr, _uri, NONCE, address(alice), 1);
        (address gal, uint256 fee) = drop.royaltyInfo(nft);
        assertEq(gal, address(alice));
        assertEq(fee, 1);
    }

    function testIERC2981Royalties0() public {
        // 0% fee
        uint256 nft = drop.mint(_addr, _uri, NONCE, _addr, 0);
        (address gal, uint256 fee) = drop.royaltyInfo(nft);
        assertEq(gal, _addr);
        assertEq(fee, 0);
    }

    function testFailERC2981Royalties() public {
        drop.mint(_addr, _uri, NONCE, address(alice), 10_000_001); // >100% fee
    }

    function testContractURI() public {
        assertEq(drop.contractURI(), _contractURI);
    }

    // ERC721 Enumerable

    /// notice Count NFTs tracked by this contract
    /// return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function testTotalSupply() public {
        drop.mint(_addr, _uri, NONCE, _addr, 0);
        drop.mint(_addr, "t2", NONCE1, _addr, 0); //setup

        assertEq(drop.totalSupply(), 2);
        drop.mint(_addr,  "t3", NONCE2, _addr, 0);
        drop.mint(_addr2, "t4", NONCE3, _addr, 0);
        assertEq(drop.totalSupply(), 4);
        drop.burn(0);
        assertEq(drop.totalSupply(), 3);
        drop.burn(1);
        assertEq(drop.totalSupply(), 2);
        drop.burn(2);
        assertEq(drop.totalSupply(), 1);
        drop.mint(_addr, "t5", NONCE4, _addr, 0);
        assertEq(drop.totalSupply(), 2);
        assertEq(drop.balanceOf(_addr), 1);
        assertEq(drop.balanceOf(_addr2), 1);
        drop.burn(3);
        assertEq(drop.totalSupply(), 1);
        assertEq(drop.balanceOf(_addr), 1);
        assertEq(drop.balanceOf(_addr2), 0);
    }

    //function tokenByIndex(uint256 idx) external view returns (uint256);
    /// notice Enumerate valid NFTs
    /// dev Throws if `_index` >= `totalSupply()`.
    /// param _index A counter less than `totalSupply()`
    /// return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function testTokenByIndex() public {
        drop.mint(_addr,  _uri, NONCE, _addr,  0);
        drop.mint(_addr,  "t1", NONCE1, _addr,  0);
        drop.mint(_addr,  "t2", NONCE2, _addr,  0);
        drop.mint(_addr2, "t3", NONCE3, _addr2, 0);
        drop.mint(_addr2, "t4", NONCE4, _addr2, 0);
        drop.mint(_addr2, "t5", NONCE5, _addr2, 0);
        drop.mint(_addr,  "t6", NONCE6, _addr,  0);

        assertEq(drop.tokenByIndex(4), 4);
        drop.burn(4);
        assertEq(drop.tokenByIndex(3), 3);
        assertEq(drop.tokenByIndex(4), 6);
        drop.burn(3);
        assertEq(drop.tokenByIndex(3), 5);
        assertEq(drop.tokenByIndex(4), 6);
        drop.burn(0);
        assertEq(drop.tokenByIndex(0), 6);
        assertEq(drop.tokenByIndex(1), 1);
    }

    // function tokenOfOwnerByIndex(
    //     address guy, uint256 idx
    // ) external view returns (uint256);
    /// notice Enumerate NFTs assigned to an owner
    /// dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// param guy An address where we are interested in NFTs owned by them
    /// param idx A counter less than `balanceOf(_owner)`
    /// return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function testTokenOfOwnerByIndex() public {
        drop.mint(_addr,   _uri, NONCE, _addr, 0);
        drop.mint(_addr,   "t1", NONCE1, _addr, 0);
        drop.mint(_addr,   "t2", NONCE2, _addr, 0);
        drop.mint(_addr2,  "t3", NONCE3, _addr2, 0);
        drop.mint(_addr2,  "t4", NONCE4, _addr2, 0);
        drop.mint(_addr2,  "t5", NONCE5, _addr2, 0);
        drop.mint(_addr,   "t6", NONCE6, _addr, 0);

        assertEq(drop.tokenOfOwnerByIndex(_addr, 0), 0);
        assertEq(drop.tokenOfOwnerByIndex(_addr, 2), 2);
        assertEq(drop.tokenOfOwnerByIndex(_addr, 3), 6);

        assertEq(drop.tokenOfOwnerByIndex(_addr2, 0), 3);
        assertEq(drop.tokenOfOwnerByIndex(_addr2, 1), 4);
    }

    function testFailTokenOfOwnerByIndex() public {
        drop.mint(_addr,  _uri, NONCE, _addr, 0);
        drop.mint(_addr,  "t1", NONCE, _addr, 0);
        drop.mint(_addr,  "t2", NONCE, _addr, 0);

        drop.tokenOfOwnerByIndex(_addr, 3); // max 2
    }

    function testFailBurnBurned() public {
        drop.mint(_addr,  _uri, NONCE, _addr, 0);
        drop.mint(_addr,  "t1", NONCE, _addr, 0);
        drop.burn(1);
        drop.burn(1);
    }

    function testStop() public {
        drop.stop();
        assertTrue(drop.stopped());
    }

    function testStart() public {
        drop.stop();
        drop.start();
        assertTrue(!drop.stopped());
    }

    function testFailTransferFromWhenStopped() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        drop.stop();
        alice.doTransferFrom(address(alice), address(bob), 0);
    }

    function testFailSafeTransferFromWhenStopped() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        drop.stop();
        alice.doSafeTransferFrom(address(alice), address(bob), 0);
    }

    function testFailPushWhenStopped() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        drop.stop();
        alice.doPush(address(bob), 0);
    }

    function testFailPullWhenStopped() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        alice.doApprove(address(bob), 0);
        drop.stop();
        bob.doPull(address(alice), 0);
    }

    function testFailMoveWhenStopped() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        alice.doApprove(address(bob), 0);
        drop.stop();
        alice.doMove(address(alice), address(bob), 0);
    }

    function testFailMintWhenStopped() public {
        drop.stop();
        drop.mint(address(alice), "", NONCE, address(alice), 0);
    }

    function testFailMintGuyWhenStopped() public {
        drop.stop();
        drop.mint(address(this), "t1", NONCE, address(this), 0);
    }

    function testFailBurnWhenStopped() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        drop.stop();
        drop.burn(0);
    }

    function testFailTrustWhenStopped() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);
        drop.stop();
        alice.doApprove(address(bob), 0);
    }

    function testFailSendSelf() public {
        drop.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doPush(address(drop), 0);
    }

}
