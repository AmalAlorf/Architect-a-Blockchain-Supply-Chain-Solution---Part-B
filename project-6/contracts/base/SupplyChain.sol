// pragma solidity ^0.4.24;
pragma solidity >=0.4.21 <0.6.0;
// Define a contract 'Supplychain'
import "../access_control/SellerRole.sol";//seller
import "../access_control/ConsumerRole.sol";//Consumer
import "../access_control/DeliveryAgentRole.sol";//DeliveryAgent
import "../core/Ownable.sol";

  contract SupplyChain is Ownable, SellerRole, ConsumerRole, DeliveryAgentRole{

  // Define 'owner'
   address owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that  its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Prepared, //0
    ForSale,    // 1
    Sold,       // 2
    Shipped,    // 3
    Delivered,  // 4
    Received   //5
    }


  State constant defaultState = State.Prepared;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address originSellerID; // Metamask-Ethereum address of the Farmer
    string  originSellerName; // Seller Name
    string  originSellerInformation;  // Seller Information
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address deliveryAgentID;  // Metamask-Ethereum address of the Distributor
    address consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define 5 events with the same 4 state values and accept 'upc' as input argument
 event Prepared(uint upc);
  event ForSale(uint upc);
  event Sold(uint upc);
  event Shipped(uint upc);
  event Delivered(uint upc);
  event Received(uint upc);
 
  // Define a modifer that checks to see if msg.sender == owner of the contract
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }
  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].consumerID.transfer(amountToReturn);
  }
  //////////
    // Define a modifier that checks if an item.state of a upc is Prepared
  modifier prepared(uint _upc) {
    require(items[_upc].itemState == State.Prepared);

    _;
  }
  // first state Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSale(uint _upc) {
    require(items[_upc].itemState == State.ForSale);
    _;
  }

  //second Define a modifier that checks if an item.state of a upc is Sold
  modifier sold(uint _upc) {
    require(items[_upc].itemState == State.Sold);
    _;
  }
  
  // third Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
    require(items[_upc].itemState == State.Shipped);

    _;
  }

  // forth Define a modifier that checks if an item.state of a upc is delivered
  modifier delivered(uint _upc) {
    require(items[_upc].itemState == State.Delivered);

    _;
  }
  // fifth Define a modifier that checks if an item.state of a upc is Received
  modifier received(uint _upc) {
    require(items[_upc].itemState == State.Received);

    _;
  }

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    owner = msg.sender;
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
       selfdestruct(owner());  
  }

  // Define a function 'bakeCookies' that allows a farmer to mark an item 'Prepared'
  function prepareItems(uint _upc, address _originSellerID, string _originSellerName, string _originSellerInformation, string  _productNotes, uint _productPrice)  public {
// Add the new item 
    items[_upc] = Item({
      sku: sku,
      upc: _upc,
      ownerID: _originSellerID,
      productID: sku + _upc ,
      originSellerID: _originSellerID,
      originSellerName: _originSellerName,
      originSellerInformation: _originSellerInformation ,
      productNotes: _productNotes,
      itemState: State.prepare,
      productPrice: _productPrice,
      deliveryAgentID:address(0),
      consumerID: address(0)
       });

       // Increment sku
    sku = sku + 1;
    // Emit the appropriate event
    emit prepared(_upc);
  }
  

  // Define a function 'addItemsToOnlineStore' that allows a seller to mark an item 'ForSale'
  function addItemsToOnlineStore(uint _upc)  public 
  // Call modifier to check if upc has passed previous supply chain stage  
  prepared(_upc)
  // Call modifier to verify caller of this function
          verifyCaller(items[_upc].originSellerID)
  {
    // Update the appropriate fields
    items[_upc].itemState = State.ForSale;
    // Emit the appropriate event
    emit ForSale(_upc);
  }
  

  // Define a function 'buyItems' that allows a seller to mark an item 'sold'
  function buyItems(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
  forSale(_upc)
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice)
    // Call modifer to send any excess ether back to buyer
    checkValue(_upc)
  // Call modifier to verify caller of this function
   onlyConsumer()
  {

        items[_upc].ownerID = msg.sender;
        items[_upc].consumerID = msg.sender;
        items[_upc].itemState = State.Sold; 
        // Transfer money to seller
        items[_upc].originSellerID.transfer(items[_upc].productPrice);
        // emit the appropriate event
        emit Sold(_upc); 
  }

  // Define a function 'shipItems' that allows a seller to mark an item 'sold'
  function shipItems(uint _upc,address _deliveryAgentID) public 
  // Call modifier to check if upc has passed previous supply chain stage
    sold(_upc)
 
  // Call modifier to verify caller of this function
            verifyCaller(items[_upc].originSellerID)

  {
    // Update the appropriate fields
        items[_upc].itemState = State.Shipped;
        items[_upc].deliveryAgentID = _deliveryAgentID;

    // Emit the appropriate event
        emit Shipped(_upc);

  }

  // Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  function DeliverItems(uint _upc) public  
    // Call modifier to check if upc has passed previous supply chain stage
    shipped(_upc)
{
     items[_upc].deliveryAgentID = msg.sender;

     items[_upc].itemState = State.Delivered;

    // emit the appropriate event
            emit Delivered(_upc); 
}

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    delivered(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    onlyConsumer()
    verifyCaller(items[_upc].consumerID)

    {
                items[_upc].itemState = State.Received;

    // Emit the appropriate event
                emit Received(_upc);

  }
  
  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originSellerID,
  string  originSellerName,
  string  originSellerInformation
   ) 
  {
  // Assign values to the 8 parameters
 //muist check
  itemSKU =   items[_upc].sku ;
   itemUPC  = items[_upc].upc;
  ownerID  = items[_upc].ownerID;
  originSellerID  = items[_upc].originSellerID;
  originSellerName  = items[_upc].originSellerName;
  originSellerInformation  = items[_upc].originSellerInformation;
   return 
  (
  itemSKU ,
  itemUPC,
  ownerID,
  originSellerID,
  originSellerName,
  originSellerInformation
   );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string  productNotes,
  uint    productPrice,
  uint    itemState,
  address deliveryAgentID,
   address consumerID
  ) 
  {

  itemSKU =   items[_upc].sku ;
  itemUPC  = items[_upc].upc;
  productID  = items[_upc].productID;
  productNotes  = items[_upc].productNotes;
  productPrice  = items[_upc].productPrice;
  itemState  = uint(items[_upc].itemState); 
  deliveryAgentID  = items[_upc].deliveryAgentID;
  consumerID  = items[_upc].consumerID;
    // Assign values to the 9 parameters
    
  return 
  (
  itemSKU,
  itemUPC,
  productID,
  productNotes,
  productPrice,
  itemState,
  deliveryAgentID,
  consumerID
  );
  }
}