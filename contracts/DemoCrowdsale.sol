pragma solidity ^0.4.21;

import "contracts/crowdsale/PostDeliveryCrowdsale.sol";
import "contracts/crowdsale/RefundableCrowdsale.sol";
import "contracts/crowdsale/CappedCrowdsale.sol";
import "contracts/DMT.sol";
import "contracts/ownership/Owned.sol";
import "contracts/crowdsale/WhitelistedCrowdsale.sol";


contract DemoCrowdsale is PostDeliveryCrowdsale, RefundableCrowdsale, CappedCrowdsale, WhitelistedCrowdsale {


    using SafeMath for uint;

    // ICO Stage
    // ============
    enum CrowdsaleStage { PreICO, ICO }
    CrowdsaleStage public stage = CrowdsaleStage.PreICO; // By default it's Pre Sale
    event CrowdsaleStageChanged();


    /**
    * @dev  Crowdsale constructor
    * _wallet  MultiSig Wallet contarct address
    * _token  DMT contract address
    * _openingTime   Opening date and time of crowdsale, should be given in UNIX format, required to be more than current date&time, non zero
    * _closingTime  Closing time, after that period payments wont be able, required to be more than _openingTime and non zero
    * _initialRate  Exchange rate for token buyers, taken from IncreasingPriceCrowdsale - in Crowdsale used as _rate
    * _finalRate  Exchange final rate, used in IncreasingPriceCrowdsale, currently disabled
    * _goal  Crowdsale goal set in Wei, used as "soft cap"
    * _cap  Crowdsale cap set in Wei, used as "hard cap"
    */
    function DemoCrowdsale(
        address _wallet, // should be MultiSig Wallet contarct address
        DMT _token,
        uint _openingTime,
        uint _closingTime,
        uint _initialRate,
        //uint _finalRate,
        uint _goal,
        uint _cap
    ) public Owned(msg.sender)
    Crowdsale (_initialRate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    PostDeliveryCrowdsale()
    //IncreasingPriceCrowdsale(_initialRate, _finalRate)
    RefundableCrowdsale(_goal)
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    {
        require(_goal <= _cap);
    }

    /**
    *
    *
    */

    function changeStage() public onlyOwner {
        require(goalReached());
        stage = CrowdsaleStage.ICO;
        emit CrowdsaleStageChanged();

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

    // 2mln EUR with ETH price 500EUR requires 4000 ETH as soft cap -> _goal -> in WEI: "4000000000000000000000"
    // 25mln EUR with ETH price 500EUR requires 50000 ETH as hard cap -> _cap -> in WEI: "50000000000000000000000"

    // pre-sale 1 and half months then
    // the sale (first round) 1 and half month

    // token number at all: 1 300 000 000 (1 billion 300 millions)

    // pre-sale 30% discount

    // min investment 1ETH

    // distribution:
    //60% pre sale
    //15% token sale
    //10% reserve;
    //5% team
    //5% advisors
    //5% bounty


}
}
