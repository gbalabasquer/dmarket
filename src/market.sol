pragma solidity ^0.4.8;

import 'erc20/erc20.sol';

contract MarketEvents {
    event LogTrade(address seller, address indexed sellToken, address buyer, address indexed buyToken, uint sellQuantity, uint buyQuantity, uint timestamp);
}

contract Market is MarketEvents {
    // bool locked;

    // modifier synchronized {
    //     assert(!locked);
    //     locked = true;
    //     _;
    //     locked = false;
    // }

    // function assert(bool x) internal {
    //     if (!x) throw;
    // }

    struct Offer {
        address     sellToken;
        address     buyToken;
        uint        sold;
        uint        bought;
        bool        active;
    }

    mapping( address => mapping( bytes32 => Offer ) ) public proccesedOffers;

    // non underflowing subtraction
    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }
    // non overflowing multiplication
    function safeMul(uint a, uint b) internal returns (bool) {
        uint c = a * b;
        return (a == 0 || c / a == b);
    }

    function getSellerFromSignature(bytes32 uuid, address sellToken, address buyToken, uint sellMax, uint buyMax, uint expiration, uint8 v, bytes32 r, bytes32 s) returns (address) {
        bytes32 message = sha3(uuid, sellToken, buyToken, sellMax, buyMax, expiration); // This is the key to prove the offer is valid
        return ecrecover(sha3('\u0019Ethereum Signed Message:\n32', message), v, r, s);
    }

    function getOffer(address seller, bytes32 uuid) returns (address, address, uint, uint, bool) {
        Offer offer = proccesedOffers[seller][uuid];
        return (offer.sellToken, offer.buyToken, offer.sold, offer.bought, offer.active);
    }

    function checkOfferIsActive(address seller, bytes32 uuid) returns (bool) {
        return proccesedOffers[seller][uuid].sellToken == 0 || proccesedOffers[seller][uuid].active;
    }

    function checkOfferCanBeBought(address seller, bytes32 uuid, uint sellMax, uint quantity) returns (bool) {
        return proccesedOffers[seller][uuid].sellToken == 0 || sellMax >= proccesedOffers[seller][uuid].sold + quantity;
    }

    function buy(bytes32 uuid, address sellToken, address buyToken, uint sellMax, uint buyMax, uint expiration, uint8 v, bytes32 r, bytes32 s, uint sellQuantity) {  
        assert(expiration > now && sellQuantity <= sellMax);

        var seller = getSellerFromSignature(uuid, sellToken, buyToken, sellMax, buyMax, expiration, v, r, s);
        assert(seller != 0);
        
        assert(checkOfferIsActive(seller, uuid));

        assert(checkOfferCanBeBought(seller, uuid, sellMax, sellQuantity));
        
        assert(safeMul(sellMax, sellQuantity));

        uint buyQuantity = sellMax * sellQuantity / buyMax;

        proccesedOffers[seller][uuid].sellToken = sellToken;
        proccesedOffers[seller][uuid].buyToken = buyToken;
        proccesedOffers[seller][uuid].sold += sellQuantity;
        proccesedOffers[seller][uuid].bought += buyQuantity;
        proccesedOffers[seller][uuid].active = true;

        trade(seller, sellToken, msg.sender, buyToken, sellQuantity, buyQuantity);
    }

    function trade(address seller, address sellToken, address buyer, address buyToken, uint sellQuantity, uint buyQuantity) internal {
        assert(ERC20(buyToken).transferFrom(buyer, seller, buyQuantity));

        assert(ERC20(sellToken).transferFrom(seller, buyer, sellQuantity));

        LogTrade(seller, sellToken, buyer, buyToken, sellQuantity, buyQuantity, now);
    }

    function cancelOffer(bytes32 uuid, address sellToken, address buyToken, uint sellMax, uint buyMax, uint expiration, uint8 v, bytes32 r, bytes32 s) {
         var seller = getSellerFromSignature(uuid, sellToken, buyToken, sellMax, buyMax, expiration, v, r, s);
         assert(seller == msg.sender);

         proccesedOffers[seller][uuid].active = false;
    }
}
