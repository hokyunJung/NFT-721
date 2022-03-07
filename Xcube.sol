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

    constructor() ERC721("Xcube", "Willd") {}

    event info(address _address, uint256 newTokenId, string tokenURI);

    mapping(uint256 => string) private tokenURIs;

    struct NftData {
        uint256 tokenId;
        string tokenURI;
        uint256 nftPrice;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return tokenURIs[tokenId];
    }

    //function mintNFT(address to, string memory tokenURI) public returns (uint256){ 민트를 개인들도 할 것이냐?
    function mintNFT(string memory tokenURI) public onlyOwner returns (uint256){    //민트를 컨트랙 배포자만 할 것이냐?
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();

        emit info(msg.sender, newItemId, tokenURI);

        _mint(msg.sender, newItemId);
        tokenURIs[newItemId] = tokenURI;

        return newItemId;
    }

    function getNFTTokens(address _ownerAddress) view public returns (NftData[] memory) {
        uint256 totalBalance = balanceOf(_ownerAddress);

        require(totalBalance != 0, "Owner did not have token.");

        NftData[] memory nftDatas = new NftData[](totalBalance);

        for(uint256 i = 0; i < totalBalance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(_ownerAddress, i);
            string memory tokenURI = tokenURI(tokenId);
            uint256 nftPrice = saleNftToken.getNftTokenPrice(tokenId);

            nftDatas[i] = NftData(tokenId, tokenURI, nftPrice);
        }

        return nftDatas;
    }

    function setSaleNftToken(address _saleNftToken) public {
        saleNftToken = SaleNftToken(_saleNftToken);
    }
}