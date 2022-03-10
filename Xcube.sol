// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./SaleNftToken.sol";

contract Xcube is ERC721Enumerable , Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    SaleNftToken public saleNftToken;
    address admin;

    constructor() ERC721("Xcube", "Willd") {
        admin = msg.sender;
    }

    event info(address _address, uint256 newTokenId, string tokenURI);

    mapping(uint256 => string) private tokenURIs;
    //mapping(uint256 => address) private tokenOwners;

    struct NftData {
        uint256 tokenId;
        string tokenURI;
        address tokenOwner;
        uint256 nftPrice;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return tokenURIs[tokenId];
    }

/*
    function tokenOwner(uint256 tokenId) public view returns (address) {
        return tokenOwners[tokenId];
    }
    function setTokenOwners(uint256 tokenId, address _address) public {
        tokenOwners[tokenId] = _address;
    }
*/

    function mintNFT(string memory tokenURI) payable public returns (uint256){ //민트를 개인들도 할 것이냐?
    //function mintNFT(string memory tokenURI) public onlyOwner returns (uint256){    //민트를 컨트랙 배포자만 할 것이냐?
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();

        //emit info(msg.sender, newItemId, tokenURI);
        emit info(msg.sender, newItemId, tokenURI);

        //_mint(msg.sender, newItemId);
        _mint(msg.sender, newItemId);
        payable(admin).transfer(msg.value);
        tokenURIs[newItemId] = tokenURI;
        //tokenOwners[newItemId] = to;

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
            //address owner = tokenOwner(tokenId);
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
        saleNftToken = SaleNftToken(_saleNftToken);
    }



    //실행 가능한 권한 설정 : setApprovalForAll -> 지갑선택 -> operator : SALENFTTOKEN AT 주소, approved : true
    //실행 가능한 권한 보기 : isApprovalForAll -> setApprovalForAll -> 해당 지갑이 true/false 인지...

    //판매 등록 : setForSaleNftToken -> 지갑선택 -> _nftTokenId : key, _price : 1
}
