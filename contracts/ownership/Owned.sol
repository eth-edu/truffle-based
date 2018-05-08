pragma solidity ^0.4.21;


contract Owned {

  address public owner;
  event OwnershipTransferred(address indexed _from, address indexed _to);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the provided address or sender
   * account.
   */
  function Owned(address definedOwner) public {
      if (definedOwner != address(0)) {
        owner = definedOwner;
      } else {
        owner = msg.sender;
      }
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
