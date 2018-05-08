pragma solidity ^0.4.21;

import "contracts/token/BasicToken.sol";
import "contracts/ownership/Owned.sol";
import "contracts/math/SafeMath.sol";


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken, Owned {

    using SafeMath for uint;

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens in the token storage - contract's balance. Could be requested only by contract Owner.
     * @param _value The amount of token to be burned.
     * !! msg.sender changed to address(this) because tokens issue and save on the token contract instead of contract creator address
     * !! this does not provide a possibility to burn tokens on any buyer's balance
     */
    function burnInStorage(uint _value) public onlyOwner {
        require(_value <= balances[address(this)]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = address(this);
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }


    /**
    * @dev Burns a specific amount of tokens on msg.sender's address
    * @param _value The amount of token to be burned.
    * Could be requested by anyone, who owns tokens.
    */
    function burnMyTokens(uint _value) public {
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
}