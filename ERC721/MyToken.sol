//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";

contract MyToken is ERC721 {
    address public owner;
    uint currentTokenId;

    constructor() ERC721("MyToken", "MTK") {
        owner = msg.sender;
    }

    function safeMint(address to, string calldata tokenId) public {
        require(owner == msg.sender, "not an owner!");

        _safeMint(to, currentTokenId);
        currentTokenId++;
    }

    function _baseURI() internal pure ovverride returns(string memory) {
        return "ifps://";
    }
}
