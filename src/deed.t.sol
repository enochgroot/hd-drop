// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.20;

import "ds-test/test.sol";

import "./deed.sol";

contract DeedUser {

    DSDeed deed;

    constructor(DSDeed _deed) public {
        deed = _deed;
    }

    function doTransferFrom(address from, address to, uint nft) public {
        deed.transferFrom(from, to, nft);
    }

    function doSafeTransferFrom(address from, address to, uint nft) public {
        deed.safeTransferFrom(from, to, nft);
    }

    function doSafeTransferFrom(address from, address to, uint nft, bytes memory data) public {
        deed.safeTransferFrom(from, to, nft, data);
    }

    function doBalanceOf(address who) public view returns (uint) {
        return deed.balanceOf(who);
    }

    function doApprove(address guy, uint nft) public {
        deed.approve(guy, nft);
    }

    function doSetApprovalForAll(address guy, bool ok) public {
        deed.setApprovalForAll(guy, ok);
    }

    function doPush(address who, uint nft) public {
        deed.push(who, nft);
    }
    function doPull(address who, uint nft) public {
        deed.pull(who, nft);
    }
    function doMove(address src, address dst, uint nft) public {
        deed.move(src, dst, nft);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns(bytes4) {
        return this.onERC721Received.selector;
    }
}

contract TokenReceiver {

    uint256 public tokensReceived;

    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        tokensReceived++;
        return this.onERC721Received.selector;
    }
}

contract BadTokenReceiver { uint256 one = 0; }


contract DSDeedTest is DSTest {
    DSDeed deed;

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

    DeedUser alice;
    DeedUser bob;
    TokenReceiver receiver;
    BadTokenReceiver badreceiver;

    function setUp() public {
        deed  = new DSDeed(_name, _symb, 0, _contractURI);
        alice = new DeedUser(deed);
        bob   = new DeedUser(deed);

        receiver = new TokenReceiver();
        badreceiver = new BadTokenReceiver();
    }

    function testMint() public {
        assertEq(deed.totalSupply(), 0);

        deed.mint(_addr, _uri, NONCE, _addr, 0);

        assertEq(deed.totalSupply(), 1);
    }

    function testERC165() public {
        // 
        //  bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
        //  bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
        // 
        //  => 0x0ebd4c7f ^ 0xb9c4d9fb == 0xb7799584
        // 
        // assertEq(deed.contractURI.selector, 0);
    }

    function testMintMany() public {
        assertEq(deed.totalSupply(), 0);

        deed.mint(_addr, _uri, NONCE, _addr, 0);
        deed.mint(_addr, "t1", NONCE1, _addr, 0);
        deed.mint(_addr, "t2", NONCE2, _addr, 0);
        deed.mint(_addr, "t3", NONCE3, _addr, 0);
        deed.mint(_addr, "t4", NONCE4, _addr, 0);
        deed.mint(_addr, "t5", NONCE5, _addr, 0);
        deed.mint(_addr, "t6", NONCE6, _addr, 0);
        deed.mint(_addr, "t7", NONCE7, _addr, 0);
        deed.mint(_addr, "t8", NONCE8, _addr, 0);

        assertEq(deed.totalSupply(), 9);
        assertEq(deed.tokenURI(8), "t8");

    }

    function testBurn() public {
        deed.mint(_addr, _uri, NONCE, _addr, 0);
        assertEq(deed.totalSupply(), 1); // setup

        deed.burn(0);
        assertEq(deed.totalSupply(), 0);
    }

    function testBurnMany() public {
        deed.mint(_addr, _uri, NONCE, _addr, 0);
        deed.mint(_addr, "t1", NONCE1, _addr, 0);
        deed.mint(_addr, "t2", NONCE2, _addr, 0);
        deed.mint(_addr, "t3", NONCE3, _addr, 0);
        deed.mint(_addr, "t4", NONCE4, _addr, 0);
        deed.mint(_addr, "t5", NONCE5, _addr, 0);
        deed.mint(_addr, "t6", NONCE6, _addr, 0);
        deed.mint(_addr, "t7", NONCE7, _addr, 0);
        deed.mint(_addr, "t8", NONCE8, _addr, 0);
        assertEq(deed.totalSupply(), 9);  // setup

        deed.burn(7);
        assertEq(deed.totalSupply(), 8);
        assertEq(deed.ownerOf(6), _addr);
        deed.burn(6);
        deed.burn(2);
        deed.burn(8);
        deed.burn(1);
        assertEq(deed.totalSupply(), 4);
    }

    // ERC721
    /// title ERC-721 Non-Fungible Token Standard
    /// dev See https://eips.ethereum.org/EIPS/eip-721
    ///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.

    /// dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    //event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    //event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    //event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// notice Count all NFTs assigned to an owner
    /// dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// param _owner An address for whom to query the balance
    /// return The number of NFTs owned by `_owner`, possibly zero
    //function balanceOf(address _owner) external view returns (uint256);
    function testBalanceOf() public {
        assertEq(deed.balanceOf(_addr),  0);
        assertEq(deed.balanceOf(_addr2),  0);

        deed.mint(_addr, _uri, NONCE, _addr,  0);
        deed.mint(_addr,  "t1", NONCE1, _addr, 0);
        deed.mint(_addr,  "t2", NONCE2, _addr, 0);
        deed.mint(_addr2, "t3", NONCE3, _addr, 0);
        deed.mint(_addr2, "t4", NONCE4, _addr, 0);
        deed.mint(_addr2, "t5", NONCE5, _addr, 0);
        deed.mint(_addr,  "t6", NONCE6, _addr, 0);

        assertEq(deed.balanceOf(_addr),  4);
        assertEq(deed.balanceOf(_addr2), 3);

        deed.burn(4);

        assertEq(deed.balanceOf(_addr),  4);
        assertEq(deed.balanceOf(_addr2), 2);
    }

    function testFailBalanceOf() public view {
        // function throws for queries about the zero address.
        deed.balanceOf(address(0));
    }

    /// notice Find the owner of an NFT
    /// dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// param _tokenId The identifier for an NFT
    /// return The address of the owner of the NFT
    function testOwnerOf() public {
        deed.mint(address(this), _uri, NONCE,  address(this), 0);
        deed.mint(address(101),  "t1", NONCE1, address(this), 0);

        assertEq(deed.ownerOf(0), address(this));
        assertEq(deed.ownerOf(1), address(101));

        deed.approve(address(this), 0);
        deed.transferFrom(address(this), address(102), 0);

        assertEq(deed.ownerOf(0), address(102));
    }

    function testFailOwnerOf() public {
        deed.mint(address(this), _uri, NONCE, address(this), 0);
        deed.transferFrom(address(this), address(0), 0); // We can't test revert on check of address(0) because we can't transfer to address(0)
        deed.ownerOf(0);
    }

    /// notice Transfers the ownership of an NFT from one address to another address
    /// dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// param _from The current owner of the NFT
    /// param _to The new owner
    /// param _tokenId The NFT to transfer
    /// param data Additional data with no specified format, sent in call to `_to`
    //function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
    function testSafeTransferFromWithData() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        // _addr is EOA (can't use address(bob) because that's a contract
        alice.doSafeTransferFrom(address(alice), _addr, 0, "Some data");

        assertEq(deed.ownerOf(0),_addr);
    }

    function testSafeTransferFromContractWithData() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doSafeTransferFrom(address(alice), address(receiver), 0, "Some data");

        assertEq(deed.ownerOf(0), address(receiver));
        assertEq(receiver.tokensReceived(), 1); // Ensure receiver was called.
    }


    /// notice Transfers the ownership of an NFT from one address to another address
    /// dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// param _from The current owner of the NFT
    /// param _to The new owner
    /// param _tokenId The NFT to transfer
    //function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function testSafeTransferFromEOA() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        // _addr is EOA (can't use address(bob) because that's a contract
        alice.doSafeTransferFrom(address(alice), _addr, 0);

        assertEq(deed.ownerOf(0), _addr);
    }

    function testSafeTransferFromContract() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doSafeTransferFrom(address(alice), address(receiver), 0);

        assertEq(deed.ownerOf(0), address(receiver));
        assertEq(receiver.tokensReceived(), 1); // Ensure receiver was called.
    }

    function testFailSafeTransferFromBadContract() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
        // it calls
        ///  `onERC721Received` on `_to` and throws if the return value is not
        ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
        alice.doSafeTransferFrom(address(alice), address(badreceiver), 0);
    }

    function testFailSafeTransferFromZeroAddr() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
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
    //function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function testTransferFrom() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doTransferFrom(address(alice), address(bob), 0);

        assertEq(deed.ownerOf(0), address(bob));
    }

    function testTransferFromNoCheck() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        // Useless contract. Tokens can be lost.
        alice.doTransferFrom(address(alice), address(badreceiver), 0);

        // Transfer will succeed without a check.
        assertEq(deed.ownerOf(0), address(badreceiver));
    }

    function testFailTransferFromNonOwner() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        bob.doTransferFrom(address(alice), address(bob), 0);
    }

    function testFailTransferFromWrongOwner() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        // Throws if `_from` is not the current owner.
        alice.doTransferFrom(address(bob), address(alice), 0);
    }

    function testFailTransferFromToZeroAddress() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        // Throws if `_to` is the zero address.
        alice.doTransferFrom(address(alice), address(0), 0);
    }

    function testFailTransferFromInvalidNFT() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

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
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doApprove(address(bob), 0);

        assertEq(deed.getApproved(0), address(bob));

        bob.doApprove(address(this), 0);

        assertEq(deed.getApproved(0), address(this));
        
        deed.mint(address(alice), "", NONCE1, address(alice), 0);
        alice.doSetApprovalForAll(address(bob), true);

        bob.doApprove(address(1), 1);

        assertEq(deed.getApproved(1), address(1));
    }

    function testFailApprove() public {
        //Throws unless `msg.sender` is the current NFT owner, or an authorized
        ///  operator of the current owner.
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        bob.doApprove(address(this), 0);
    }

    /// notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// param _operator Address to add to the set of authorized operators
    /// param _approved True if the operator is approved, false to revoke approval
    //function setApprovalForAll(address _operator, bool _approved) external;
    function testSetApprovalForAll() public {
        deed.mint(address(alice), _uri, NONCE, address(alice), 0);
        deed.mint(address(alice), "t1", NONCE1, address(alice), 0);
        deed.mint(address(alice), "t2", NONCE2, address(alice), 0);
        deed.mint(address(alice), "t3", NONCE3, address(alice), 0);
        deed.mint(address(alice), "t4", NONCE4, address(alice), 0);

        alice.doSetApprovalForAll(address(bob), true);

        deed.mint(address(alice), "t5", NONCE5, address(alice), 0);
        deed.mint(address(alice), "t6", NONCE6, address(alice), 0);

        assertTrue(deed.isApprovedForAll(address(alice), address(bob)));

        bob.doPull(address(alice), 2);

        alice.doSetApprovalForAll(address(bob), false);
        assertTrue(!deed.isApprovedForAll(address(alice), address(bob)));
    }

    /// notice Get the approved address for a single NFT
    /// dev Throws if `_tokenId` is not a valid NFT.
    /// param _tokenId The NFT to find the approved address for
    /// return The approved address for this NFT, or the zero address if there is none
    //function getApproved(uint256 _tokenId) external view returns (address);
    function testGetApproved() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        assertEq(deed.getApproved(0), address(0));

        alice.doApprove(address(bob), 0);

        assertEq(deed.getApproved(0), address(bob));
    }

    // Throws if `_tokenId` is not a valid NFT.
    function testFailGetApproved() public {
        deed.getApproved(3);
    }

    /// notice Query if an address is an authorized operator for another address
    /// param _owner The address that owns the NFTs
    /// param _operator The address that acts on behalf of the owner
    /// return True if `_operator` is an approved operator for `_owner`, false otherwise
    //function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function testIsApprovedForAll() public {
        assertTrue(!deed.isApprovedForAll(address(alice), address(bob)));
        alice.doSetApprovalForAll(address(bob), true);
        assertTrue(deed.isApprovedForAll(address(alice), address(bob)));
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
        assertTrue(deed.supportsInterface(0x80ac58cd));
        assertTrue(deed.supportsInterface(0x5b5e139f));
        assertTrue(deed.supportsInterface(0x780e9d63));

        assertTrue(!deed.supportsInterface(0x01234567));
        assertTrue(!deed.supportsInterface(0xffffffff));
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
    //function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
    function testFailOnERC721Received() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
        deed.onERC721Received(address(alice), address(alice), 0, "");
    }


    // ERC721 Metadata
    /// title ERC-721 Non-Fungible Token Standard, optional metadata extension
    /// dev See https://eips.ethereum.org/EIPS/eip-721
    ///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.

    /// notice A descriptive name for a collection of NFTs in this contract
    function testName() public {
        assertEq(deed.name(), _name);
    }

    /// notice An abbreviated name for NFTs in this contract
    function testSymbol() public {
        assertEq(deed.symbol(), _symb);
    }

    /// notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function testTokenURI() public {
        deed.mint(_addr, _uri, NONCE, _addr, 0);  //setup
        deed.mint(_addr, "t2", NONCE1, _addr, 0);

        assertEq(deed.tokenURI(0), _uri);
        assertEq(deed.tokenURI(1), "t2");
    }

    function testWork() public {
        assertEq(address(deed), 0xE58d97b6622134C0436d60daeE7FBB8b965D9713);

        // for(uint256 i = 0; i < 100000; i++) {
        //     if (deed.work(9, i, 9)) {
        //         assertEq(i, 9);
        //         break;
        //     }
        // }

        // test for hard = 0
        uint256 nft = deed.mint(_addr, _uri, NONCE, _addr, 0);
        assertEq(nft, 0);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE, deed.hard() - 1));

        // test for hard = 1
        nft = deed.mint(_addr, _uri, NONCE1, _addr, 0);
        assertEq(nft, 1);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE1, deed.hard() - 1));

        // test for hard = 2
        nft = deed.mint(_addr, _uri, NONCE2, _addr, 0);
        assertEq(nft, 2);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE2, deed.hard() - 1));

        // test for hard = 3
        nft = deed.mint(_addr, _uri, NONCE3, _addr, 0);
        assertEq(nft, 3);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE3, deed.hard() - 1));

        // test for hard = 4
        nft = deed.mint(_addr, _uri, NONCE4, _addr, 0);
        assertEq(nft, 4);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE4, deed.hard() - 1));

        // test for hard = 5
        nft = deed.mint(_addr, _uri, NONCE5, _addr, 0);
        assertEq(nft, 5);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE5, deed.hard() - 1));

        // test for hard = 6
        nft = deed.mint(_addr, _uri, NONCE6, _addr, 0);
        assertEq(nft, 6);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE6, deed.hard() - 1));

        // test for hard = 7
        nft = deed.mint(_addr, _uri, NONCE7, _addr, 0);
        assertEq(nft, 7);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE7, deed.hard() - 1));

        // test for hard = 8
        nft = deed.mint(_addr, _uri, NONCE8, _addr, 0);
        assertEq(nft, 8);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE8, deed.hard() - 1));

        // test for hard = 9
        nft = deed.mint(_addr, _uri, NONCE9, _addr, 0);
        assertEq(nft, 9);
        assertEq(nft, uint(deed.hard()) - 1);
        assertTrue(deed.work(nft, NONCE9, deed.hard() - 1));
    }

    function testIERC2981Royalties10() public {
        uint256 nft = deed.mint(_addr, _uri, NONCE, address(alice), 1_000_000); // 10% fee
        (address gal, uint256 fee) = deed.royaltyInfo(nft);
        assertEq(gal, address(alice));
        assertEq(fee, 1_000_000);
    }

    function testIERC2981Royalties100() public {
        uint256 nft = deed.mint(_addr, _uri, NONCE, address(bob), 10_000_000); // 100% fee
        (address gal, uint256 fee) = deed.royaltyInfo(nft);
        assertEq(gal, address(bob));
        assertEq(fee, 10_000_000);
    }

    function testERC2981Royalties01() public {
        uint256 nft = deed.mint(_addr, _uri, NONCE, address(alice), 10_000); // 0.1% fee
        (address gal, uint256 fee) = deed.royaltyInfo(nft);
        assertEq(gal, address(alice));
        assertEq(fee, 10_000);
    }

    function testERC2981Royalties00001() public {
        uint256 nft = deed.mint(_addr, _uri, NONCE, address(alice), 1); // 0.00001% fee
        (address gal, uint256 fee) = deed.royaltyInfo(nft);
        assertEq(gal, address(alice));
        assertEq(fee, 1);
    }

    function testIERC2981Royalties0() public {
        uint256 nft = deed.mint(_addr, _uri, NONCE, _addr, 0); // 0% fee
        (address gal, uint256 fee) = deed.royaltyInfo(nft);
        assertEq(gal, _addr);
        assertEq(fee, 0);
    }

    function testFailERC2981Royalties() public {
        deed.mint(_addr, _uri, NONCE, address(alice), 10_000_001); // >100% fee
    }

    function testFailWork() public {
        assertEq(address(deed), 0xE58d97b6622134C0436d60daeE7FBB8b965D9713);
        assertEq(uint(deed.hard()), 0);
        deed.mint(_addr, _uri, 0, _addr, 0);
        assertEq(uint(deed.hard()), 1);

        assertTrue(deed.work(1, 0, 1));
    }

    // ERC721 Enumerable

    /// notice Count NFTs tracked by this contract
    /// return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function testTotalSupply() public {
        deed.mint(_addr, _uri, NONCE, _addr, 0);
        deed.mint(_addr, "t2", NONCE1, _addr, 0); //setup

        assertEq(deed.totalSupply(), 2);
        deed.mint(_addr,  "t3", NONCE2, _addr, 0);
        deed.mint(_addr2, "t4", NONCE3, _addr, 0);
        assertEq(deed.totalSupply(), 4);
        deed.burn(0);
        assertEq(deed.totalSupply(), 3);
        deed.burn(1);
        assertEq(deed.totalSupply(), 2);
        deed.burn(2);
        assertEq(deed.totalSupply(), 1);
        deed.mint(_addr, "t5", NONCE4, _addr, 0);
        assertEq(deed.totalSupply(), 2);
        assertEq(deed.balanceOf(_addr), 1);
        assertEq(deed.balanceOf(_addr2), 1);
        deed.burn(3);
        assertEq(deed.totalSupply(), 1);
        assertEq(deed.balanceOf(_addr), 1);
        assertEq(deed.balanceOf(_addr2), 0);
    }

    //function tokenByIndex(uint256 idx) external view returns (uint256);
    /// notice Enumerate valid NFTs
    /// dev Throws if `_index` >= `totalSupply()`.
    /// param _index A counter less than `totalSupply()`
    /// return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function testTokenByIndex() public {
        deed.mint(_addr,  _uri, NONCE, _addr,  0);
        deed.mint(_addr,  "t1", NONCE1, _addr,  0);
        deed.mint(_addr,  "t2", NONCE2, _addr,  0);
        deed.mint(_addr2, "t3", NONCE3, _addr2, 0);
        deed.mint(_addr2, "t4", NONCE4, _addr2, 0);
        deed.mint(_addr2, "t5", NONCE5, _addr2, 0);
        deed.mint(_addr,  "t6", NONCE6, _addr,  0);

        assertEq(deed.tokenByIndex(4), 4);
        deed.burn(4);
        assertEq(deed.tokenByIndex(3), 3);
        assertEq(deed.tokenByIndex(4), 6);
        deed.burn(3);
        assertEq(deed.tokenByIndex(3), 5);
        assertEq(deed.tokenByIndex(4), 6);
        deed.burn(0);
        assertEq(deed.tokenByIndex(0), 6);
        assertEq(deed.tokenByIndex(1), 1);
    }

    //function tokenOfOwnerByIndex(address guy, uint256 idx) external view returns (uint256);
    /// notice Enumerate NFTs assigned to an owner
    /// dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// param guy An address where we are interested in NFTs owned by them
    /// param idx A counter less than `balanceOf(_owner)`
    /// return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function testTokenOfOwnerByIndex() public {
        deed.mint(_addr,   _uri, NONCE, _addr, 0);
        deed.mint(_addr,   "t1", NONCE1, _addr, 0);
        deed.mint(_addr,   "t2", NONCE2, _addr, 0);
        deed.mint(_addr2,  "t3", NONCE3, _addr2, 0);
        deed.mint(_addr2,  "t4", NONCE4, _addr2, 0);
        deed.mint(_addr2,  "t5", NONCE5, _addr2, 0);
        deed.mint(_addr,   "t6", NONCE6, _addr, 0);

        assertEq(deed.tokenOfOwnerByIndex(_addr, 0), 0);
        assertEq(deed.tokenOfOwnerByIndex(_addr, 2), 2);
        assertEq(deed.tokenOfOwnerByIndex(_addr, 3), 6);

        assertEq(deed.tokenOfOwnerByIndex(_addr2, 0), 3);
        assertEq(deed.tokenOfOwnerByIndex(_addr2, 1), 4);
    }

    function testFailTokenOfOwnerByIndex() public {
        deed.mint(_addr,  _uri, NONCE, _addr, 0);
        deed.mint(_addr,  "t1", NONCE, _addr, 0);
        deed.mint(_addr,  "t2", NONCE, _addr, 0);

        deed.tokenOfOwnerByIndex(_addr, 3); // max 2
    }

    function testFailBurnBurned() public {
        deed.mint(_addr,  _uri, NONCE, _addr, 0);
        deed.mint(_addr,  "t1", NONCE, _addr, 0);
        deed.burn(1);
        deed.burn(1);
    }

    function testStop() public {
        deed.stop();
        assertTrue(deed.stopped());
    }

    function testStart() public {
        deed.stop();
        deed.start();
        assertTrue(!deed.stopped());
    }

    function testFailTransferFromWhenStopped() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
        deed.stop();
        alice.doTransferFrom(address(alice), address(bob), 0);
    }

    function testFailSafeTransferFromWhenStopped() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
        deed.stop();
        alice.doSafeTransferFrom(address(alice), address(bob), 0);
    }

    function testFailPushWhenStopped() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
        deed.stop();
        alice.doPush(address(bob), 0);
    }

    function testFailPullWhenStopped() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
        alice.doApprove(address(bob), 0);
        deed.stop();
        bob.doPull(address(alice), 0);
    }

    function testFailMoveWhenStopped() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
        alice.doApprove(address(bob), 0);
        deed.stop();
        alice.doMove(address(alice), address(bob), 0);
    }

    function testFailMintWhenStopped() public {
        deed.stop();
        deed.mint(address(alice), "", NONCE, address(alice), 0);
    }

    function testFailMintGuyWhenStopped() public {
        deed.stop();
        deed.mint(address(this), "t1", NONCE, address(this), 0);
    }

    function testFailBurnWhenStopped() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
        deed.stop();
        deed.burn(0);
    }

    function testFailTrustWhenStopped() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);
        deed.stop();
        alice.doApprove(address(bob), 0);
    }

    function testFailSendSelf() public {
        deed.mint(address(alice), "", NONCE, address(alice), 0);

        alice.doPush(address(deed), 0);
    }

    function testContractURI() public {
        assertEq(deed.contractURI(), _contractURI);
    }

}
