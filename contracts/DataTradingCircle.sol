// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/openzeppelin-solidity/contracts/access/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/utils/Strings.sol";

contract DataTradingCircle is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    struct EntryRequest { 
      bool hasBeenRequested;
      uint allowCount;
      mapping(address => bool) allowers;
    }
    mapping(address => EntryRequest) public entries;

    struct DataTrade { 
      address saleFrom;
      address saleTo;
      uint price;
      bool uploaded;
      bool sold;
    }
    mapping(uint => DataTrade) public trades;

    uint traderCount;
    mapping(address => bool) public isTrader;

    event TradeCreated(uint indexed idTrade);

    constructor(string memory name, string memory symbol, address firstTrader) ERC721(name, symbol) {
      isTrader[firstTrader] = true;
      traderCount += 1;
    }

    modifier onlyTrader() {
      require(isTrader[msg.sender], "Not trader");
      _;
    }

    modifier onlyTraderOwner() {
      require(isTrader[msg.sender] || owner() == msg.sender, "Not trader either owner");
      _;
    }

    /**
    * Checks if Caller is User
    */
    function isTraderPresent(address user) public view returns (bool) {
      return isTrader[user];
    }

   /**
    * Requests new entry
    */
    function requestEntry() public {
      require(isTrader[msg.sender] == false, "User is already trader");
      require(entries[msg.sender].hasBeenRequested == false, "User has already requested entry");
      entries[msg.sender].hasBeenRequested = true;
    }

   /**
    * Allows new entry
    */
    function allowEntry(address user) public onlyTrader {
      require(isTrader[user] == false, "User is already trader");
      require(entries[user].hasBeenRequested, "Entry has not been requested");
      require(entries[user].allowers[msg.sender] == false, "Entry has already been approved");
      entries[user].allowers[msg.sender] = true;
      entries[user].allowCount += 1;
      if (entries[user].allowCount >= traderCount) {
        isTrader[user] = true;
        traderCount += 1;
      }
    }

   /**
    * Returns if entry has been requested
    */
    function hasRequestedEntry(address user) public view returns (bool) {
      return entries[user].hasBeenRequested;
    }

   /**
    * Returns if entry has been allowed
    */
    function entryHasBeenAllowed(address user) public view returns (bool) {
      return entries[user].allowers[msg.sender];
    }

   /**
    * Trader exits
    */
    function exitCircle() public onlyTrader {
      isTrader[msg.sender] = false;
      traderCount -= 1;
    }


    /**
    * Create Trade Token
    */
    function getTrade(uint idTrade) public view returns (DataTrade memory){
      return trades[idTrade];
    }

    /**
    * Create Trade Token
    */
    function createTrade(address sellerAddress, uint weiPrice, uint idTrade) public onlyTrader payable{
      require(sellerAddress != msg.sender, "Trader cant sell to himself");
      require(isTraderPresent(sellerAddress), "Seller must be trader");
      require(weiPrice <= msg.value, "Ether value sent is not correct");
      require(!trades[idTrade].sold, "Trade already sold");

      _safeMint(msg.sender, idTrade);
      trades[idTrade].uploaded = false;
      trades[idTrade].sold = true;
      trades[idTrade].price = weiPrice;
      trades[idTrade].saleFrom = sellerAddress;
      trades[idTrade].saleTo = msg.sender;

      emit TradeCreated(idTrade);
    }

    /**
     * Overrides ERC721 tokenURI function and adds starting index randomization
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI_ = _baseURI();

        return string(abi.encodePacked(baseURI_, tokenId));
    }
}
