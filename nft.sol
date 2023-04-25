// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract BasicNFT is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public nftURI;

    constructor(string memory _name, string memory _symbol, string memory _nftURI) ERC721(_name,_symbol){
        nftURI = _nftURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return nftURI;
    }

    function mint(address to) public onlyOwner{
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(to, newTokenId);
    }

    function burn(uint256 tokenId) public{
        address owner = ERC721.ownerOf(tokenId);
        require(msg.sender == owner, "not owner");
        _burn(tokenId);
    }
}