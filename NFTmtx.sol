// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract mtx is ERC721, Ownable {
    // Inherit from ERC721 and Ownable contracts.

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        // Constructor to initialize the token's name and symbol.
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        // Mint a new token with the given tokenId and assign it to the specified address.
        _mint(to, tokenId);
    }
}
