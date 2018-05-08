pragma solidity ^0.4.2;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
        assert(token.transfer(to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        assert(token.transferFrom(from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        assert(token.approve(spender, value));
    }
}

/**
 * @title Owned
 * @dev The Owned contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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

/**
 * @title Managed
 * @dev The Managed contract has an manager address, and provides basic authorization control which extends Owned
 * Used for Patent Manager contract
 * functions, this simplifies the implementation of "user permissions".
 */
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[address(this)]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[address(this)] = balances[address(this)].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(address(this), _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

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

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Owned {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

// /**
//  * @title TokenTimelock
//  */
// contract TokenTimelock is Owned {

//     event Released(address indexed spender, uint tokens);
//     event Locked (address indexed spender, uint tokens, uint releaseTime);

//     struct lockedSpender {
//         uint256 releaseDate;
//         uint256 value;
//     }

//     mapping (address => lockedSpender) public timeLockedAmounts;

//     /**
//      * TokenTimelock
//      */
//     function TokenTimelock() public Owned(msg.sender) {

//     }

//     /**
//      * @notice Allow spend tokens held by timelock to beneficiary.
//      */
//     function release(address _addressToUnlock) public {
//         require(_addressToUnlock != address(0));
//         require(now >= timeLockedAmounts[_addressToUnlock].releaseDate);
//         require(timeLockedAmounts[_addressToUnlock].value > 0);

//         /* allowed[address(this)][_addressToUnlock] = timeLockedAmounts[_addressToUnlock].value; */

//         emit Released(_addressToUnlock, timeLockedAmounts[_addressToUnlock].value);
//     }

//     /**
//      *
//      * @param _addressToLock address
//      * @param _value uint256
//      * @param _releaseDate uint256
//      */
//     function lockFunds(address _addressToLock, uint256 _value , uint256 _releaseDate) public onlyOwner {
//         require(_addressToLock != address(0));
//         require(_releaseDate > now);
//         require(_value > 0);
//         timeLockedAmounts[_addressToLock] = lockedSpender(_releaseDate, _value);
//         emit Locked(_addressToLock, _value, _releaseDate);
//     }
// }

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // The token being sold
    ERC20 public token;

    // Address where funds are collected
    address public wallet;

    // How many token units a buyer gets per wei
    uint256 public rate;

    // Amount of wei raised
    uint256 public weiRaised;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @param _rate Number of token units a buyer gets per wei
     * @param _wallet Address where collected funds will be forwarded to
     * @param _token Address of the token being sold
     */
    function Crowdsale(uint256 _rate, address _wallet, ERC20 _token) public {
        require(_rate > 0);
        require(_wallet != address(0));
        require(_token != address(0));

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }
    // -----------------------------------------
    // Crowdsale external interface
    // -----------------------------------------

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Address performing the token purchase
     */
    function buyTokens(address _beneficiary) public payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        /* _updatePurchasingState(_beneficiary, weiAmount); */

        _forwardFunds();
        /* _postValidatePurchase(_beneficiary, weiAmount); */
    }

    // -----------------------------------------
    // Internal interface (extensible)
    // -----------------------------------------

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    /* function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
      // optional override
    } */

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.safeTransfer(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
     * @param _beneficiary Address receiving the tokens
     * @param _weiAmount Value in wei involved in the purchase
     */
    /* function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
      // optional override
    } */

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(rate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}

/**
 * @title CappedCrowdsale
 * @dev Crowdsale with a limit for total contributions.
 */
contract CappedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 public cap;

    /**
     * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
     * @param _cap Max amount of wei to be contributed
     */
    function CappedCrowdsale(uint256 _cap) public {
        require(_cap > 0);
        cap = _cap;
    }

    /**
     * @dev Checks whether the cap has been reached.
     * @return Whether the cap was reached
     */
    function capReached() public view returns (bool) {
        return weiRaised >= cap;
    }

    /**
     * @dev Extend parent behavior requiring purchase to respect the funding cap.
     * @param _beneficiary Token purchaser
     * @param _weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        require(weiRaised.add(_weiAmount) <= cap);
    }

}

/**
*Contract Patent is used by main contract to create new patents (ideas).
*It has array of created patents and patent constructor.
*Contract owner can withdraw funds from contract.
*/
contract Patent is Owned {

    using SafeMath for uint;

    struct patentInfo {
        string patentHash;
        string name;
        string description;
        string author;
        uint date;
        string patentType;
    }

    patentInfo[] public patents;

    function Patent(
        string _hash,
        string _name,
        string _description,
        string _author,
        string _patentType,
        address creator
    ) public Owned(creator) {

        patentInfo memory newPatent = patentInfo({
            patentHash: _hash,
            name: _name,
            description: _description,
            author: _author,
            date: now,
            patentType: _patentType
            });

        patents.push(newPatent);
    }

    function withdrawEth(uint amount) onlyOwner public returns(bool) {
        require(amount <= address(this).balance);
        owner.transfer(amount);
        return true;

    }


    //  COMMENTED AS NOT NEEDED - YOU WILL NEED TO CHECK AND SHOW VAULT BALANCE
    function getBalance() public view returns(uint){
        return address(this).balance;
    }


    /**
    * Fallback function
    */
    function () public payable {
    }

}

contract PatentManager is Managed {
    using SafeMath for uint;

    //    enum State { Active, Investing }

    // State public state;

    //    event InvestmentsStarted();
    //    event Invested(address indexed beneficiary, uint256 weiAmount);

    //mapping (address => uint256) public deployedPatents;

    //     struct newPatentData {
    //         address _address;
    // //        bool _owned;
    //         uint _invested;
    //     }

    // newPatentData[] public deployedPatents;

    function PatentManager(address _manager) public payable
    Managed (_manager)
    {
        //        state = State.Active; // added this because did not find any state changes, by default without this state is not defined but requires Active in functions below
    }

    // take your data and creates new patent with it
    function createPatent (string _hash, string _name, string _description, string _author, string _patentType) public onlyManager {

        address newPatent = new Patent(_hash, _name, _description, _author, _patentType, msg.sender);

        //         newPatentData memory patentInfo = newPatentData({
        //             _address: newPatent,
        // //            _owned: false,
        //             _invested: 0
        //             });

        //         deployedPatents.push(patentInfo);
    }

    function deposit() /*onlyOwner*/ public payable { //commented onlyOwner because there is no other pyable function, and not owner fails here during buying tokens
        //        require(state == State.Active);
    }

    //    function enableInvestments() onlyOwner public {
    //        //require(state == State.Active); // removed this because its useless if state:Active turned on upod invoking constructor function
    ////        state = State.Investing;
    ////        emit InvestmentsStarted();
    //    }

    function invest(uint256 _id, uint256 _value) public onlyOwner {
        //        require(state == State.Investing);
        require(_value > 0);
        require(address(this).balance > 0);
        //        deployedPatents[_id]._invested = deployedPatents[_id]._invested + _value;

        //        deployedPatents[_id]._address.transfer(_value);
        //        emit Invested(deployedPatents[_id]._address, _value);
    }

    /**
     * Withdraw
     * @param  _beneficiary address to withdraw
     * @param  _amount uint256 Amount of money
     */
    /* function withdraw(address _beneficiary, uint256 _amount) onlyOwner public {
      require (_beneficiary != address(0));
      _beneficiary.transfer(_amount);
    } */


    /**
     * Get vault balance in ether/wei
     */
    //    function getBalance() public view returns(uint){
    //        return address(this).balance;
    //    }
}

/**
*'SIPT' 'Save Ideas Patent Token' token contract
* Symbol      : SIPT
* Name        : Save Ideas Patent Token / Save Ideas Token
* Total supply: 900 000 000.000000000000000000
* Decimals    : 18
*/
contract SIPT is MintableToken, BurnableToken {
    using SafeMath for uint;

    string public constant name = "Save Ideas Token";
    string public constant symbol = "SIPT";
    uint8 public constant decimals = 18;



    // NEW DIGITS FOR TOKENS
    // max tokens; 900000000.000000000000000000
    // 60% tokens sale; 540000000.000000000000000000
    //15% reserve; 135000000.000000000000000000
    //10% Team; 90000000.000000000000000000
    //10% Advisors; 90000000.000000000000000000
    //5% Ambassadors/Bounty 45000000.000000000000000000

    uint256 public maxTokens = 900000000000000000000000000; // There will be total 900 000 000 SI Tokens
    //uint256 public totalTokensForSaleDuringPreICO = 780000000000000000000000000; // 78 000 0000 tokens for PreSale
    uint256 public totalTokensForSale = 540000000000000000000000000; // 195 000 000 for Crowdsale
    uint256 public totalTokensReserve = 135000000000000000000000000; //13 000 0000 for reserve
    uint256 public totalTokensForTeam = 90000000000000000000000000; // 65 000 000 for team
    uint256 public totalTokensForAdvisors = 90000000000000000000000000; // 65 000 000 for advisors
    uint256 public totalTokensForBounty = 45000000000000000000000000; // 65 000 000 for bounty


    //SIPT constructor + tokensForSale minted
    function SIPT() public Owned(msg.sender) {
        mint(address(this), totalTokensForSale);
        emit Mint(address(this), totalTokensForSale);
    }

    function mintReserveTokens(address _reserveAddress) public onlyOwner {
        assert(this.totalSupply() + totalTokensReserve <= maxTokens && _reserveAddress != address(0));
        mint(_reserveAddress, totalTokensReserve);
        emit Mint(_reserveAddress, totalTokensReserve);
    }

    function mintForBounty(address _bountyWallet) public onlyOwner {
        assert(this.totalSupply() + totalTokensForBounty <= maxTokens && _bountyWallet != address(0));
        mint(_bountyWallet, totalTokensForBounty);
        emit Mint(_bountyWallet, totalTokensForBounty);
    }

    function mintForTeam(address _teamWallet) public onlyOwner {
        assert(this.totalSupply() + totalTokensForTeam <= maxTokens && _teamWallet != address(0));
        mint(_teamWallet, totalTokensForTeam);
        emit Mint(_teamWallet, totalTokensForTeam);
    }

    function mintForAdvisors(address _advisorsWallet) public onlyOwner {
        assert(this.totalSupply() + totalTokensForAdvisors <= maxTokens && _advisorsWallet != address(0));
        mint(_advisorsWallet, totalTokensForAdvisors);
        emit Mint(_advisorsWallet, totalTokensForAdvisors);
    }

}

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 public openingTime;
    uint256 public closingTime;

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen {
        require(now >= openingTime && now <= closingTime);
        _;
    }

    /**
     * @dev Constructor, takes crowdsale opening and closing times.
     * @param _openingTime Crowdsale opening time
     * @param _closingTime Crowdsale closing time
     */
    function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
        require(_openingTime >= now);
        //require(_closingTime >= _openingTime);

        openingTime = _openingTime;
        closingTime = _closingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        return now > closingTime;
    }

    /**
     * @dev Extend parent behavior requiring to be within contributing period
     * @param _beneficiary Token purchaser
     * @param _weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

}

/**
 * @title IncreasingPriceCrowdsale
 * @dev Extension of Crowdsale contract that increases the price of tokens linearly in time.
 * Note that what should be provided to the constructor is the initial and final _rates_, that is,
 * the amount of tokens per wei contributed. Thus, the initial rate must be greater than the final rate.
 */
// contract IncreasingPriceCrowdsale is TimedCrowdsale {
//     using SafeMath for uint256;

//     uint256 public initialRate;
//     uint256 public finalRate;

//     /**
//      * @dev Constructor, takes intial and final rates of tokens received per wei contributed.
//      * @param _initialRate Number of tokens a buyer gets per wei at the start of the crowdsale
//      * @param _finalRate Number of tokens a buyer gets per wei at the end of the crowdsale
//      */
//     function IncreasingPriceCrowdsale(uint256 _initialRate, uint256 _finalRate) public {
//         require(_initialRate >= _finalRate);
//         require(_finalRate > 0);
//         initialRate = _initialRate;
//         finalRate = _finalRate;
//     }

//     /**
//      * @dev Returns the rate of tokens per wei at the present time.
//      * Note that, as price _increases_ with time, the rate _decreases_.
//      * @return The number of tokens a buyer gets per wei at a given time
//      */
//     function getCurrentRate() public view returns (uint256) {
//         uint256 elapsedTime = now.sub(openingTime);
//         uint256 timeRange = closingTime.sub(openingTime);
//         uint256 rateRange = initialRate.sub(finalRate);
//         return initialRate.sub(elapsedTime.mul(rateRange).div(timeRange));
//     }

//     /**
//      * @dev Overrides parent method taking into account variable rate.
//      * @param _weiAmount The value in wei to be converted into tokens
//      * @return The number of tokens _weiAmount wei will buy at present time
//      */
//     function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
//         uint256 currentRate = getCurrentRate();
//         return currentRate.mul(_weiAmount);
//     }

// }

/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Owned {
    using SafeMath for uint256;

    enum State { Active, Refunding, Closed }

    mapping (address => uint256) public deposited;
    address public wallet;
    State public state;

    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);

    /**
     * @param _wallet Vault address
     */
    function RefundVault(address _wallet) public Owned(msg.sender) {
        require(_wallet != address(0));
        wallet = _wallet;
        state = State.Active;
    }

    /**
     * @param investor Investor address
     */
    function deposit(address investor) onlyOwner public payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function close() onlyOwner public {
        require(state == State.Active);
        state = State.Closed;
        emit Closed();
        wallet.transfer(address(this).balance);
    }

    function enableRefunds() onlyOwner public {
        require(state == State.Active);
        state = State.Refunding;
        emit RefundsEnabled();
    }

    /**
     * @param investor Investor address
     */
    function refund(address investor) public {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        emit Refunded(investor, depositedValue);
    }
}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is TimedCrowdsale, Owned {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasClosed());

        finalization();
        emit Finalized();

        isFinalized = true;
    }

    /**
     * @dev Can be overridden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal {
    }
}

/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract RefundableCrowdsale is FinalizableCrowdsale {
    using SafeMath for uint256;

    // minimum amount of funds to be raised in weis
    uint256 public goal;

    // refund vault used to hold funds while crowdsale is running
    RefundVault public vault;

    /**
    * @dev Constructor, creates RefundVault.
    * @param _goal Funding goal
    */
    function RefundableCrowdsale(uint256 _goal) public {
        require(_goal > 0);
        vault = new RefundVault(wallet);
        goal = _goal;
    }

    /**
    * @dev Investors can claim refunds here if crowdsale is unsuccessful
    */
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        vault.refund(msg.sender);
    }

    /**
    * @dev Checks whether funding goal was reached.
    * @return Whether funding goal was reached
    */
    function goalReached() public view returns (bool) {
        return weiRaised >= goal;
    }

    /**
    * @dev vault finalization task, called when owner calls finalize()
    */
    function finalization() internal {
        if (goalReached()) {
            vault.close();
        } else {
            vault.enableRefunds();
        }

        super.finalization();
    }

    /**
    * @dev Overrides Crowdsale fund forwarding, sending funds to vault.
    */
    function _forwardFunds() internal {
        vault.deposit.value(msg.value)(msg.sender);
    }

}

/**
 * @title PostDeliveryCrowdsale
 * @dev Crowdsale that locks tokens from withdrawal until it ends.
 */
contract PostDeliveryCrowdsale is TimedCrowdsale {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    /**
     * @dev Overrides parent by storing balances instead of issuing tokens right away.
     * @param _beneficiary Token purchaser
     * @param _tokenAmount Amount of tokens purchased
     */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
    }

    /**
     * @dev Withdraw tokens only after crowdsale ends.
     */
    function withdrawTokens() public {
        require(hasClosed());
        uint256 amount = balances[msg.sender];
        require(amount > 0);
        balances[msg.sender] = 0;
        _deliverTokens(msg.sender, amount);
    }
}

/**
 * @title WhitelistedCrowdsale
 * @dev Crowdsale in which only whitelisted users can contribute.
 */
contract WhitelistedCrowdsale is Crowdsale, Owned {

    mapping(address => bool) public whitelist;

    /**
     * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
     */
    modifier isWhitelisted(address _beneficiary) {
        require(whitelist[_beneficiary]);
        _;
    }

    /**
     * @dev Adds single address to whitelist.
     * @param _beneficiary Address to be added to the whitelist
     */
    function addToWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = true;
    }

    /**
     * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
     * @param _beneficiaries Addresses to be added to the whitelist
     */
    function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    /**
     * @dev Removes single address from whitelist.
     * @param _beneficiary Address to be removed to the whitelist
     */
    function removeFromWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = false;
    }

    /**
     * @dev Extend parent behavior requiring beneficiary to be in whitelist.
     * @param _beneficiary Token beneficiary
     * @param _weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal isWhitelisted(_beneficiary) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

}

contract SaveIdeasCrowdsale is PostDeliveryCrowdsale, RefundableCrowdsale, CappedCrowdsale, WhitelistedCrowdsale {


    using SafeMath for uint;

    // ICO Stage
    // ============
    enum CrowdsaleStage { PreICO, ICO }
    CrowdsaleStage public stage = CrowdsaleStage.PreICO; // By default it's Pre Sale
    event CrowdsaleStageChanged();


    /**
    * @dev  Crowdsale constructor
    * _wallet  MultiSig Wallet contarct address
    * _token  SIPT contract address
    * _openingTime   Opening date and time of crowdsale, should be given in UNIX format, required to be more than current date&time, non zero
    * _closingTime  Closing time, after that period payments wont be able, required to be more than _openingTime and non zero
    * _initialRate  Exchange rate for token buyers, taken from IncreasingPriceCrowdsale - in Crowdsale used as _rate
    * _finalRate  Exchange final rate, used in IncreasingPriceCrowdsale, currently disabled
    * _goal  Crowdsale goal set in Wei, used as "soft cap"
    * _cap  Crowdsale cap set in Wei, used as "hard cap"
    */
    function SaveIdeasCrowdsale(
        address _wallet, // should be MultiSig Wallet contarct address
        SIPT _token,
        uint _openingTime,
        uint _closingTime,
        uint _initialRate,
        uint _goal,
        uint _cap
    ) public Owned(msg.sender)
    Crowdsale (_initialRate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    PostDeliveryCrowdsale()
    RefundableCrowdsale(_goal)
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    WhitelistedCrowdsale()
    {
        require(_goal <= _cap);
    }

    /**
    *
    *
    */

    function changeStage() public onlyOwner {
        //        require(goalReached());
        stage = CrowdsaleStage.ICO;
        emit CrowdsaleStageChanged();

    }


    function buyTokens(address _beneficiary) public payable isWhitelisted(msg.sender) {
        //       require(whitelist[_beneficiary]);
        super.buyTokens(_beneficiary);
    }

    function _forwardFunds() internal {
        if (stage == CrowdsaleStage.PreICO) {
            wallet.transfer(msg.value); // All funds from PreICO goes directly to the owner's wallet - change if needed
            // Add transfer event here
        } else if (stage == CrowdsaleStage.ICO) {
            // Add transfer event here
            super._forwardFunds(); // All funds on ICO stage will go to the vault
        }
    }
    /**
     * @dev Overrides finalization function and mints additional tokens
     *
     */
    // function finalization(address _team, address _bounty, address _advisors, address _reserve) internal {
    //     mint(_team, totalTokensForTeam);
    //     mint(_bounty, totalTokensForBounty);
    //     mint(_advisors, totalTokensForAdvisors);

    //     if (token.totalSupply() <= (maxTokens.sub(totalTokensReserve))) {
    //         mint(_reserve, totalTokensReserve);
    //      } else {
    //             mint(_reserve, maxTokens.sub(token.totalSupply()));
    //         }
    // }

    /**
     * @dev Overrides parent to add bonus tokens during PreICO Stage and over 20ETH boughts bonuses
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        assert(_weiAmount >= 1000000000000000000); // require at least 1 ether as msg.value/weiAmount to proceed

        if (_weiAmount >= 20000000000000000000) {
            if (stage == CrowdsaleStage.PreICO) {
                return (_weiAmount.mul(rate) + _weiAmount.mul(rate).div(100).mul(45)); // 45% bonus tokens for buyer over 20ETH during PreSale
            }else if (stage == CrowdsaleStage.ICO) {
                return (_weiAmount.mul(rate) + _weiAmount.mul(rate).div(100).mul(20)); // 20% bonus tokens for buyer over 20ETH during Sale
            }else{
                if (stage == CrowdsaleStage.PreICO) {
                    return (_weiAmount.mul(rate) + _weiAmount.mul(rate).div(100).mul(25)); // 25% bonus tokens returns during PreSale
                }else if (stage == CrowdsaleStage.ICO) {
                    return _weiAmount.mul(rate);
                }

            }
        }

        // 1.5mln EUR with ETH price 330EUR requires 4546 ETH as soft cap -> _goal -> in WEI: "4546000000000000000000"
        // 20mln EUR with ETH price 330EUR requires 60607 ETH as hard cap -> _cap -> in WEI: "60607000000000000000000"

        // Bonus for investments over 20ETH (5000 EURO ??)  - 20% (in addition to pre-sale discount of 30%) ?? total discount 50% or 45%?

        // pre-sale 1 and half months then
        // the sale (first round) 1 and half month

        // token number at all: 900 000 000

        // Pre-sale discount - 25%

        // min investment 1ETH

    }
}
