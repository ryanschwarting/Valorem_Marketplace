//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFT is ERC721URIStorage, Ownable, ERC2981 {
    //auto-increment field for each token
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //address of the NFT marketplace 
    address public contractAddress;

    constructor (uint96 _royaltyFeesInBips, address marketplaceAddress, string memory myName, string memory mySymbol) ERC721(myName, mySymbol) {
        contractAddress = marketplaceAddress;
        setRoyaltyInfo(msg.sender, _royaltyFeesInBips);
    }

    /// @notice create a new token
    /// @param tokenURI: token URI

    function createToken(string memory tokenURI) public returns (uint256) {
        //sets a new token id for the token to be minted
        _tokenIds.increment(); //0,1,2,3....etc
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId); //Mint the token
        _setTokenURI(newItemId, tokenURI); //generate the URI
        setApprovalForAll(contractAddress, true); //grant transaction permission to marketplace

        //return token ID
        return newItemId; 
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal 
        override(ERC721)
        {
            super._beforeTokenTransfer(from, to, tokenId);
        }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) public onlyOwner {
        _setDefaultRoyalty(_receiver, _royaltyFeesInBips);
    }
}

