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

    struct TokenSale { 
      address owner;
      uint price;
      bool sold;
      bool active;
    }
    mapping(uint => TokenSale) public sales;

    uint traderCount;
    mapping(address => bool) public isTrader;

    event SaleCreated(uint indexed saleID);
    event SaleSold(uint indexed saleID);

    constructor(string memory name, string memory symbol, address firstTrader) ERC721(name, symbol) {
      isTrader[firstTrader] = true;
      traderCount += 1;
    }

    modifier onlyTrader() {
      require(isTrader[msg.sender], "Not trader");
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
    * Trader exits
    */
    function exitCircle() public onlyTrader {
      isTrader[msg.sender] = false;
      traderCount -= 1;
    }

    /**
    * Create Sale Token
    */
    function createSale(address saleAddress, uint weiPrice) public onlyTrader{
      require(saleAddress == msg.sender, "Trader cant sell to himself");
      uint saleID = totalSupply() + 1;
      _safeMint(msg.sender, saleID);
      approve(owner(), saleID);
      sales[saleID].active = true;
      sales[saleID].price = weiPrice;
      sales[saleID].owner = msg.sender;

      emit SaleCreated(saleID);
    }

    /**
    * Purchase Sale Token
    */
    function purchaseSale(uint saleID) public payable onlyTrader{
      require(sales[saleID].active, "Sale must be active to purchase sale");
      require(sales[saleID].price <= msg.value, "Value sent is not correct");
      transferFrom(sales[saleID].owner, msg.sender, saleID);

      emit SaleSold(saleID);
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
