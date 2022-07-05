// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6;

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
/// @return Documents the return variables of a contract’s function state variable
/// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
// import "./AggregatorV3Interface.sol";

// import "./SafeMathChainlink.sol"; -> ya no se usa

contract FundMe {
    // using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    // if you're following along with the freecodecamp video
    // Please see https://github.com/PatrickAlphaC/fund_me
    // to get the starting solidity contract code, it'll be slightly different than this!
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // 1000000000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }

    //modifier: https://medium.com/coinmonks/solidity-tutorial-all-about-modifiers-a86cf81c14cb
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public payable onlyOwner {
        // address payable p_msg_sender = payable(msg.sender);
        // p_msg_sender.transfer(address(this).balance);
        payable(msg.sender).transfer(address(this).balance);

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
