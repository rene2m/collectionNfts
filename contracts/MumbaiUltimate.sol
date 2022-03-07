// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MumbaiUltimate is ERC721Enumerable, Ownable {
  using Strings for uint256;

      // Starting and stopping sale, presale and whitelis
    bool public saleActive = true;
    bool public whitelistActive = false;
    bool public presaleActive = false;
   
    //quit reveal for oficial version
    bool public revealed = false;

    // Reserved for the team, customs, giveaways, collabs and so on.
    uint256 public reserved = 150;

    // Price of each token
    uint256 public initial_price = 0.01234 ether;
    uint256 public price;
    
      // Maximum limit of tokens that can ever exist
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_PRESALE_SUPPLY = 500;
    uint256 public constant MAX_MINT_PER_TX = 50;

      // Team addresses for withdrawals
    address public a1;
    address public a2;
    address public a3;


    // List of addresses that have a number of reserved tokens for whitelist
     mapping (address => uint256) public whitelistReserved;

     string public notRevealedUri;
     string public baseURI;
     string public baseExtension = ".json";

  constructor(
  ) ERC721("MumbaiUltimate", "MU") {
     setBaseURI("https://bohemian.mypinata.cloud/ipfs/QmSMDJA6ATqPbvFnmoWjoqDNB2WYqNWjVEdDHA6a44xiVR/");
     setNotRevealedURI("https://bohemian.mypinata.cloud/ipfs/QmeikWRLfqPMeV9oZVagyoVS3CgLXaH1rBNyepeUnmfzdA");
      mintToken(10);
      price = initial_price;
  }
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

    // See which address owns which tokens
       function tokensOfOwner(address addr) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(addr);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(addr, i);
        }
        return tokensId;
    }

        // Exclusive whitelist minting
        function mintWhitelist(uint256 _amount) public payable {
        uint256 supply = totalSupply();
        uint256 reservedAmt = whitelistReserved[msg.sender];
        require( whitelistActive,                   "Whitelist isn't active" );
        require( reservedAmt > 0,                   "No tokens reserved for your address" );
        require( _amount <= reservedAmt,            "Can't mint more than reserved" );
        require( supply + _amount <= MAX_SUPPLY,    "Can't mint more than max supply" );
        require( msg.value >= price * _amount,      "Wrong amount of ETH sent" );
        whitelistReserved[msg.sender] = reservedAmt - _amount;
        for(uint256 i; i < _amount; i++){
            _safeMint( msg.sender, supply + i );
        }
    }

       // Presale minting
     function mintPresale(uint256 _amount) public payable {
        uint256 supply = totalSupply();
        require( presaleActive,                             "Sale isn't active" );
        require( _amount > 0 && _amount <= MAX_MINT_PER_TX, "Can only mint between 1 and 20 tokens at once" );
        require( supply + _amount <= MAX_PRESALE_SUPPLY,    "Can't mint more than max supply" );
        require( msg.value >= price * _amount,              "Wrong amount of ETH sent" );
        for(uint256 i; i < _amount; i++){
            _safeMint( msg.sender, supply + i );
        }
    }
    
           // Standard mint function
     function mintToken(uint256 _amount) public payable {
        uint256 supply = totalSupply();
        require( saleActive,                                "Sale isn't active" );
        require( _amount > 0 && _amount <= MAX_MINT_PER_TX, "Can only mint between 1 and 4 tokens at once" );
        require( supply + _amount <= MAX_SUPPLY,            "Can't mint more than max supply" );
        require( msg.value >= price * _amount,              "Wrong amount of ETH sent" );
        for(uint256 i; i < _amount; i++){
            _safeMint( msg.sender, supply + i );
        }
    }
       // Admin minting function to reserve tokens for the team, collabs, customs and giveaways
      function mintReserved(uint256 _amount) public onlyOwner {
        // Limited to a publicly set amount
        require( _amount <= reserved, "Can't reserve more than set amount" );
        reserved -= _amount;
        uint256 supply = totalSupply();
        for(uint256 i; i <= _amount; i++){
            _safeMint( msg.sender, supply + i );
        }
    }

   // Edit reserved whitelist spots
    function editWhitelistReserved(address[] memory _a, uint256[] memory _amount) public onlyOwner {
        for(uint256 i; i < _a.length; i++){
            whitelistReserved[_a[i]] = _amount[i];
        }
    }

      // Start and stop whitelist
    function setWhitelistActive(bool val) public onlyOwner {
        whitelistActive = val;
    }

    // Start and stop presale
    function setPresaleActive(bool val) public onlyOwner {
        presaleActive = val;
    }

      // Start and stop sale
    function setSaleActive(bool val) public onlyOwner {
        saleActive = val;
    }
      // Set a different price in case ETH changes drastically
    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

      // Set team addresses
    function setAddresses(address[] memory _a) public onlyOwner {
        a1 = _a[0];
        a2 = _a[1];
        a3 = _a[2];
    }

    // Withdraw funds from contract for the team
    function withdrawTeam(uint256 amount) public payable onlyOwner {
        uint256 percent = amount / 100;
        require(payable(a1).send(percent * 40));
        require(payable(a2).send(percent * 30));
        require(payable(a3).send(percent * 30));
    }

  function withdraw() public payable onlyOwner {
 
    (bool hs, ) = payable(0xd0A7f7829aA9166812A36ace2188874E29B21d07).call{value: address(this).balance * 5 / 100}("");
    require(hs);
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }




  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
     if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }
    function reveal() public onlyOwner {
      revealed = true;
  }
function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }
}