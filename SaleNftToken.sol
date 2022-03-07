// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Xcube.sol";

contract SaleNftToken {
    Xcube public xcube;

    constructor (address _xcubeTokenAddress) {
        xcube = Xcube(_xcubeTokenAddress);
    }

    mapping(uint256 => uint256) public nftTokenPrices;

    uint256[] public onSaleNftTokenArray;

    //NFT 를 팔기 위해 사용
    function setForSaleNftToken(uint256 _nftTokenId, uint256 _price) public {
        address nftTokenOwner = xcube.ownerOf(_nftTokenId);

        require(nftTokenOwner == msg.sender, "You are not NFT token owner.");
        require(_price > 0, "Price is zero or hight.");
        require(nftTokenPrices[_nftTokenId] == 0, "This NFT token is already on sale.");
        require(xcube.isApprovedForAll(nftTokenOwner, address(this)), "NFT token owner did not approve token.");

        nftTokenPrices[_nftTokenId] = _price;

        onSaleNftTokenArray.push(_nftTokenId);
    }

    //NFT 를 사기 위해 사용
    function purchaseNftToken(uint256 _nftTokenId) public payable {
        uint256 price = nftTokenPrices[_nftTokenId];
        address nftTokenOnwer = xcube.ownerOf(_nftTokenId);

        require(price > 0, "NFT token is not on sale.");
        require(price <= msg.value, "You sent lower than price.");
        require(nftTokenOnwer != msg.sender, "You are not this NFT token owner.");

        payable(nftTokenOnwer).transfer(msg.value);
        xcube.safeTransferFrom(nftTokenOnwer, msg.sender, _nftTokenId);

        nftTokenPrices[_nftTokenId] = 0;

        for(uint256 i = 0; i < onSaleNftTokenArray.length; i++) {
            if(nftTokenPrices[onSaleNftTokenArray[i]] == 0) {
                onSaleNftTokenArray[i] = onSaleNftTokenArray[onSaleNftTokenArray.length - 1];
                onSaleNftTokenArray.pop();
            }
        }
    }

    //판매중인 NFT 개수
    function getOnSaleNftTokenArrayLength() view public returns (uint256) {
        return onSaleNftTokenArray.length;
    }

    //NFT 가격 가져오기
    function getNftTokenPrice(uint256 _nftTokenId) view public returns (uint256) {
        return nftTokenPrices[_nftTokenId];
    }
}