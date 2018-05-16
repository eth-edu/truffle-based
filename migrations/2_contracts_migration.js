const DMT = artifacts.require("DMT");
const DemoCrowdsale = artifacts.require("DemoCrowdsale");


//DemoCrowdsale arguments which have to be clarified before deploy, below is examples
const wallet = "0x64293d503191BB5298cD15B64D733CFF5151a683"; // my ususal ropsten wallet #3
const openingTime = 1526403600; //parseInt(Date.now()+300000); should be >= now and <= closingTime
const closingTime = 1526774400;
const initialRate = 10;
const goal = "4000000000000000000"; // 4 eth
const cap = "50000000000000000000"; // 50 eth


module.exports = function(deployer) {
  deployer.deploy(DMT,
    { gasPrice: 50000000000 }) // gasPrice set as 50 Gwei
    .then(function() {
      return deployer.deploy(DemoCrowdsale,
            wallet,
            DMT.address,
            openingTime,
            closingTime,
            initialRate,
            goal,
            cap,
            { gasPrice: 50000000000 });
        });
};

