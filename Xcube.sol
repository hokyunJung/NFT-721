// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./SaleNftToken.sol";

contract Xcube is ERC721URIStorage, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    SaleNftToken public saleNftToken;
    address admin;

    constructor() ERC721("Xcube", "Willd") {
        admin = msg.sender;
    }

    event info(address _address, uint256 newTokenId, string tokenURI);

    struct NftData {
        uint256 tokenId;
        string tokenURI;
        address tokenOwner;
        uint256 nftPrice;
    }

    //자산 민트..
    function mintNFT(string memory tokenURI) payable public returns (uint256){
        require(msg.value > 0, "You must send ether for minting.");

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();

        emit info(msg.sender, newItemId, tokenURI);

        _mint(msg.sender, newItemId);
        payable(admin).transfer(msg.value);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    //주소가 가지고 있는 자산들..
    function getNFTTokens(address _ownerAddress) view public returns (NftData[] memory) {
        uint256 totalBalance = balanceOf(_ownerAddress);

        require(totalBalance != 0, "Owner did not have token.");

        NftData[] memory nftDatas = new NftData[](totalBalance);

        for(uint256 i = 0; i < totalBalance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(_ownerAddress, i);
            string memory tokenURI = tokenURI(tokenId);
            uint256 nftPrice = saleNftToken.getNftTokenPrice(tokenId);
            address owner = ownerOf(tokenId);

            nftDatas[i] = NftData(tokenId, tokenURI, owner, nftPrice);
        }

        return nftDatas;
    }

    //판매 중인 NFT 가져오기
    function getSaleOnNfts() view public returns (NftData[] memory) {
        uint256[] memory lists = saleNftToken.getOnSaleNftTokenArray();

        NftData[] memory nftDatas = new NftData[](lists.length);

        for(uint256 i = 0; i < lists.length; i++) {
            uint256 tokenId = lists[i];
            string memory tokenURI = tokenURI(tokenId);
            uint256 nftPrice = saleNftToken.getNftTokenPrice(tokenId);
            address owner = ownerOf(tokenId);

            nftDatas[i] = NftData(tokenId, tokenURI, owner, nftPrice);
        }

        return nftDatas;
    }

    //xcube와 saleNftToken을 이어준다.
    function setSaleNftToken(address _saleNftToken) public {
        require(admin == msg.sender, "You not admin.");

        saleNftToken = SaleNftToken(_saleNftToken);
    }

    //실행 가능한 권한 설정 : setApprovalForAll -> 지갑선택 -> operator : SALENFTTOKEN AT 주소, approved : true
    //실행 가능한 권한 보기 : isApprovalForAll -> setApprovalForAll -> 해당 지갑이 true/false 인지...

    //판매 등록 : setForSaleNftToken -> 지갑선택 -> _nftTokenId : key, _price : 1

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
