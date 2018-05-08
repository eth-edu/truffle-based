pragma solidity ^0.4.21;

import "contracts/ownership/Owned.sol";

contract Managed is Owned {

  address public manager;
  event ManagerChanged(address indexed _from, address indexed _to);

  /**
   * @dev The Ownable constructor sets the original `manager` of the contract to the provided address or sender
   * account.
   */
  function Managed(address definedManager) public Owned(msg.sender) {
      if (definedManager != address(0)) {
        manager = definedManager;
      } else {
        manager = msg.sender;
      }
  }

  modifier onlyManager {
    require(msg.sender == owner || msg.sender == manager);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the managed functions
   */
  function transferManagerRights(address newManager) onlyOwner public {
    emit ManagerChanged(manager, newManager);
    manager = newManager;
  }
}
