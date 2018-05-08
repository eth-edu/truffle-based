pragma solidity ^0.4.21;

import "contracts/token/MintableToken.sol";
import "contracts/token/BurnableToken.sol";
import "contracts/math/SafeMath.sol";


/**
*'DMT' 'Demo ERC20' token contract
* Symbol      : DMT
* Name        : Demo Token
* Total supply: 900 000 000.000000000000000000
* Decimals    : 18
*/
contract DMT is MintableToken, BurnableToken {
    using SafeMath for uint;

    string public constant name = "DMT Token";
    string public constant symbol = "DMT";
    uint8 public constant decimals = 18;

    // NEW DIGITS FOR TOKENS
    // max tokens; 900000000.000000000000000000
    // 60% tokens sale; 540000000.000000000000000000
    // 15% reserve; 135000000.000000000000000000
    // 10% Team; 90000000.000000000000000000
    // 10% Advisors; 90000000.000000000000000000
    // 5% Ambassadors/Bounty 45000000.000000000000000000

    uint256 public maxTokens = 900000000000000000000000000; // There will be total 900 000 000 SI Tokens
    //uint256 public totalTokensForSaleDuringPreICO = 780000000000000000000000000; // ... for PreSale
    uint256 public totalTokensForSale = 540000000000000000000000000; // 540000000 for Crowdsale
    uint256 public totalTokensReserve = 135000000000000000000000000; // 135000000 for reserve
    uint256 public totalTokensForTeam = 90000000000000000000000000; // 90000000 for team
    uint256 public totalTokensForAdvisors = 90000000000000000000000000; // 90000000 for advisors
    uint256 public totalTokensForBounty = 45000000000000000000000000; // 45000000 for bounty


    //DMT constructor + tokensForSale minted
    function DMT() public Owned(msg.sender) {
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
