# HDDrop

_An ERC721 Token based on DSDeed_

Implements royalties and a proof-of-work.

Based on Brian McMichael's [ds-deed](https://github.com/brianmcmichael/ds-deed.git)

### Custom Actions

#### `work`
returns true or false based to determine of the PoW passess.

#### `contractURI`
Provides the contractURI interface for OpenSea. When passed to the constructor,
this URI allows one to establish royalties and set other token-level metadata.

#### `royaltyInfo`
Provides the EIP2981 royalty info interface.  When calling `mint()` this
allows for the royalty info to be returned in compliance with EIP2981. 

#### `receivedRoyalties`
Provides the EIP2981 event callback.  When a marketplace sends royalties related
to a token on this ERC721, it should call this function.

#### `getFeeRecipients`
Provides the Rarible royalty V1 interface.  When calling `mint()` this
allows for the royalty info to be returned in a rarible compliant format.
NOTE: This contract can only handle 1 royalty address.  A royalty splitting
contract must be used for multiple royalties.

#### `getFeeBps`
Provides the Rarible royalty V1 interface.  When calling `mint()` this
allows for the royalty info to be returned in a rarible compliant format.
NOTE: This contract can only handle 1 royalty address.  A royalty splitting
contract must be used for multiple royalties.
