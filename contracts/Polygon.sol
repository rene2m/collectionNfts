// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Polygon is ERC721Enumerable, Ownable {
  using Strings for uint256;

      // Starting and stopping sale, presale and whitelis
      //Inicio y detención de venta, preventa y whitelis // variables inicializadas en false para que una ves que se lanse el samrt contract no se pueda realizar ventas ni prevententas
    bool public saleActive = false;
    bool public whitelistActive = false;
    bool public presaleActive = false;


      // Reserved for the team, customs, giveaways, collabs and so on.
      //Reservado para el equipo, costumbres, sorteos, colaboraciones, etc. reservado una cantidad n para el equipó
    uint256 public reserved = 150;


      // Price of each token
      //precio de cada token
    uint256 public initial_price = 0.04 ether;
    // uint256 public initial_price = 0.04 matic;
    uint256 public price;

    
      // Maximum limit of tokens that can ever exist
      //Límite máximo de tokens que pueden existir  limite de tokens que se puede mintear  limite de token que pueden pasar a preventa
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_PRESALE_SUPPLY = 500;
    uint256 public constant MAX_MINT_PER_TX = 20;


      // Team addresses for withdrawals
      //Direcciones de equipo para retiros de los fondos
    address public a1;
    address public a2;
    address public a3;


    // List of addresses that have a number of reserved tokens for whitelist
    //Lista de direcciones que tienen una cantidad de tokens reservados para la lista blanca
    mapping (address => uint256) public whitelistReserved;

  string public baseURI;
  string public baseExtension = ".json";
  

  // uint256 public cost = 0.01 ether;
  // uint256 public maxSupply = 10000;
  // uint256 public maxMintAmount = 20;
  // bool public paused = false;
  // mapping(address => bool) public whitelisted;



  constructor(
  ) ERC721("Polygon", "POL") {
     setBaseURI("https://bohemian.mypinata.cloud/ipfs/QmV3XKt2dCnXxF2awyD12GyC117tfLgyAznDrMz2GG87FY/");
      price = initial_price;
    //  mint(msg.sender, 5);
  }
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

    // See which address owns which tokens
    //Ver qué dirección posee qué tokens 
    function tokensOfOwner(address addr) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(addr);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(addr, i);
        }
        return tokensId;
    }


        // Exclusive whitelist minting
        // Minado exclusivo de listas blancas
    function mintWhitelist(uint256 _amount) public payable {
        uint256 supply = totalSupply();
        uint256 reservedAmt = whitelistReserved[msg.sender];
        require( whitelistActive,                   "Whitelist isn't active" );
        require( reservedAmt > 0,                   "No tokens reserved for your address" );
        require( _amount <= reservedAmt,            "Can't mint more than reserved" );
        require( supply + _amount <= MAX_SUPPLY,    "Can't mint more than max supply" );
        require( msg.value == price * _amount,      "Wrong amount of ETH sent" );
        whitelistReserved[msg.sender] = reservedAmt - _amount;
        for(uint256 i; i <= _amount; i++){
            _safeMint( msg.sender, supply + i );
        }
    }
 // Presale minting
 //acuñación preventa
    function mintPresale(uint256 _amount) public payable {
        uint256 supply = totalSupply();
        require( presaleActive,                             "Sale isn't active" );
        require( _amount > 0 && _amount <= MAX_MINT_PER_TX, "Can only mint between 1 and 20 tokens at once" );
        require( supply + _amount <= MAX_PRESALE_SUPPLY,    "Can't mint more than max supply" );
        require( msg.value == price * _amount,              "Wrong amount of ETH sent" );
        for(uint256 i; i <= _amount; i++){
            _safeMint( msg.sender, supply + i );
        }
    }


    
    // Standard mint function
    //Función estándar de mint
    function mintToken(uint256 _amount) public payable {
        uint256 supply = totalSupply();
        require( saleActive,                                "Sale isn't active" );
        require( _amount > 0 && _amount <= MAX_MINT_PER_TX, "Can only mint between 1 and 10 tokens at once" );
        require( supply + _amount <= MAX_SUPPLY,            "Can't mint more than max supply" );
        require( msg.value == price * _amount,              "Wrong amount of ETH sent" );
        for(uint256 i; i <= _amount; i++){
            _safeMint( msg.sender, supply + i );
        }
    }


  // Admin minting function to reserve tokens for the team, collabs, customs and giveaways
  //Función de acuñación de administrador para reservar tokens para el equipo, colaboraciones, costumbres y obsequios
    function mintReserved(uint256 _amount) public onlyOwner {
        // Limited to a publicly set amount
        //Limitado a una cantidad establecida públicamente
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


       // Set new baseURI
    // function setBaseURI(string memory baseURI) public onlyOwner {
    //    baseTokenURI  = baseURI;
    // }

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
 ///esta funcion se encarga de los pagos a los diferentes componenetas  del equipo
    function withdrawTeam(uint256 amount) public payable onlyOwner {
        uint256 percent = amount / 100;
        require(payable(a1).send(percent * 40));
        require(payable(a2).send(percent * 30));
        require(payable(a3).send(percent * 30));
    }








//   function mint(address _to, uint256 _mintAmount) public payable {
//     uint256 supply = totalSupply();
//     require(!paused);
//     require(_mintAmount > 0);
//     require(_mintAmount <= maxMintAmount);
//     require(supply + _mintAmount <= maxSupply);

//     if (msg.sender != owner()) {
//         if(whitelisted[msg.sender] != true) {
//           require(msg.value >= cost * _mintAmount);
//         }
//     }

//     for (uint256 i = 1; i <= _mintAmount; i++) {
//       _safeMint(_to, supply + i);
//     }
//   }

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

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

//   //only owner
//   function setCost(uint256 _newCost) public onlyOwner {
//     cost = _newCost;
//   }

//   function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
//     maxMintAmount = _newmaxMintAmount;
//   }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  // function pause(bool _state) public onlyOwner {
  //   paused = _state;
  // }
 
//  function whitelistUser(address _user) public onlyOwner {
//     whitelisted[_user] = true;
//   }
 
  // function removeWhitelistUser(address _user) public onlyOwner {
  //   whitelisted[_user] = false;
  // }
// ///esta funcion se encarga de los pagos 
//   function withdraw() public payable onlyOwner {
//     // This will pay HashLips 5% of the initial sale.
//     // You can remove this if you want, or keep it in to support HashLips and his channel.
//     // =============================================================================
//     (bool hs, ) = payable(0xa5F60597f4292e08228f608368Ec774C90Fa8b56).call{value: address(this).balance * 5 / 100}("");
//     require(hs);
//     // =============================================================================
    
//     // This will payout the owner 95% of the contract balance.
//     // Do not remove this otherwise you will not be able to withdraw the funds.
//     // =============================================================================
//     (bool os, ) = payable(owner()).call{value: address(this).balance}("");
//     require(os);
//     // =============================================================================
//   }
}