//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VLFNFT is ERC721URIStorage, Ownable, ERC2981 {
    //auto-increment field for each token
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //address of the NFT marketplace 
    address public contractAddress;
    
     // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;


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

    function burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

         // Clear approvals
         _approve(address(0), tokenId);

         _balances[owner] -= 1;
         delete _owners[tokenId];

         emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
     }
}
