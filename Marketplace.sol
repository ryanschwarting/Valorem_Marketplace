//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VLFMarketplace is ReentrancyGuard, Ownable {
    
    address payable public immutable feeAccount; // the account that recieves fees
    uint public feePercent; // the fee percentage on sales
    uint public itemCount; 

    enum ListingStatus {
        Active,
        Sold,
        Cancelled
    }

    struct Item {
        ListingStatus status;
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable seller;
        bool sold;
    }

    event Offered (
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller
    );

    event Bought (
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller,
        address indexed buyer
    );

    //itemId -> Item
    mapping(uint => Item) public items;

    constructor (uint _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    function makeItem(IERC721 _nft, uint _tokenId, uint _price) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");
        // increase itemCount
        itemCount ++;
        // transfer nft
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        // add new item to items mapping
        items[itemCount] = Item (
            ListingStatus.Active,
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
        // emit Offered event
        emit Offered (
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            msg.sender
        );
    }

    function purchaseItem(uint _itemId) external payable nonReentrant {
        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "Item doesn't exist");
        require(msg.value >= _totalPrice, "Not enough ether to buy");
        require(!item.sold, "item already sold");
        require(item.status == ListingStatus.Active, "Listing is not active");
        // pay seller and feeAccount
        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);
        // update item to sold
        item.sold = true;
        // transfer nft to buyer
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        // emit Bought event
        emit Bought (
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

     function cancelSale(uint _itemId) public {
        Item storage item = items[_itemId];

        require(msg.sender == item.seller, "Only seller can cancel listing");
        require(item.status == ListingStatus.Active, "Listing is not active");
        
        item.status = ListingStatus.Cancelled;
        
        IERC721(item.nft).transferFrom(address(this), msg.sender, item.tokenId);

     }

    function getTotalPrice(uint _itemId) view public returns(uint) {
        return items[_itemId].price*(100 + feePercent/100);
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call {
            value: address(this).balance
        }("");
        require(success, "not owner you can't withdraw");
    }

    function setFeePercent(uint _feePercent) public onlyOwner {
        feePercent = _feePercent;
    }
}
