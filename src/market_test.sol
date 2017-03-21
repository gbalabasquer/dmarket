pragma solidity ^0.4.8;

import "dapple/test.sol";
import "./market.sol";
import "./token.sol";

contract MarketTester {
    Market market;
    function MarketTester(Market market_) {
        market = market_;
    }
    function doApprove(address spender, uint value, ERC20 token) {
        token.approve(spender, value);
    }
    /*function doBuy(uint id, uint buy_how_much) returns (bool _success) {
        return market.buy(id, buy_how_much);
    }
    function doCancel(uint id) returns (bool _success) {
        return market.cancel(id);
    }*/
}

contract MarketTest is Test
{
    Market market;
    MarketTester user;
    ERC20 weth;
    ERC20 mkr;

    function setUp() {
        market = new Market();

        weth = new Token(1000000000000000000000000);
        mkr = new Token(1000000000000000000000000);
    }

    function test_verify_message_hash() {
        //@log weth: `address weth`
        //@log mkr: `address mkr`
        bytes32 uuid = '5351ee8451854dd991e654a18de5cabf'; 
        address sT = '0xecE9Fa304cC965B00afC186f5D0281a00D3dbBFD';
        address bT = '0xA7F6C9A5052a08a14ff0e3349094B6EFBc591Ea4';
        uint sA = 200000000000000000000;
        uint bA = 100000000000000000000;
        uint exp = 1234567891011;

        bytes32 message = sha3(uuid, sT, bT, sA, bA, exp);
        //@log message: `bytes32 message`
        assertEq32(message, 0x8c191cdf7c7cfe1ab1927c2de23f94f4c103496767017794fcc4a720f26b368c);
    }

    function test_signer() {
        uint8 v = 28;
        bytes32 r = 0x5c9a0501a6d4a6afeaf5c34b72cabec55494792c913541d7c84b1fedc98ac500;
        bytes32 s = 0x1aa87cd29d16b8b0d509a74947cc57f7dcfce5595578cbc572fc1749a31a8729;

        address seller = market.getSellerFromSignature('5351ee8451854dd991e654a18de5cabf', '0xecE9Fa304cC965B00afC186f5D0281a00D3dbBFD',
                                                        '0xA7F6C9A5052a08a14ff0e3349094B6EFBc591Ea4', 200000000000000000000, 100000000000000000000,
                                                        1234567891011, v, r, s);

        //@log Signer: `address seller`

        assertEq(seller, '0xdB33dFD3D61308C33C63209845DaD3e6bfb2c674');
    }

    // function testBuyTransfersFromBuyer() {
    //     var id = market.offer( 30, mkr, 100, dai );

    //     var balance_before = dai.balanceOf(user1);
    //     user1.doBuy(id, 30);
    //     var balance_after = dai.balanceOf(user1);

    //     assertEq(balance_before - balance_after, 100);
    // }

    // function testBuyTransfersToSeller() {
    //     var id = otc.offer( 30, mkr, 100, dai );

    //     var balance_before = dai.balanceOf(this);
    //     user1.doBuy(id, 30);
    //     var balance_after = dai.balanceOf(this);

    //     assertEq(balance_after - balance_before, 100);
    // }
    // function testBuyTransfersFromMarket() {
    //     var id = otc.offer( 30, mkr, 100, dai );

    //     var balance_before = mkr.balanceOf(otc);
    //     user1.doBuy(id, 30);
    //     var balance_after = mkr.balanceOf(otc);

    //     assertEq(balance_before - balance_after, 30);
    // }
    // function testBuyTransfersToBuyer() {
    //     var id = otc.offer( 30, mkr, 100, dai );

    //     var balance_before = mkr.balanceOf(user1);
    //     user1.doBuy(id, 30);
    //     var balance_after = mkr.balanceOf(user1);

    //     assertEq(balance_after - balance_before, 30);
    // }

    // function test_signer2() {
    //     bytes32 hash = 0x9be0f6be75ef83634b9d09b5c1293a496c4ed0d96e8df7e296fce7a915e28d50;
    //     uint8 v = 27;
    //     bytes32 r = 0x31bda27c3ccc377bb163644e835518054871025e88a738965cedbc4d7ec8286b;
    //     bytes32 s = 0x188e54730eb175c93e1b66f10d97f4eadebba0bbbbce3a09c1f89a8cfca3365a;

    //     address seller = ecrecover(hash, v, r, s);

    //     //@log Signer: `address seller`
    // }
}
