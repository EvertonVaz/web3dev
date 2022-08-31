// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Helper que escrevemos para codificar em Base64
import "../libraries/Base64.sol";



// Herda de ERC721, contrato padrão dos nfts
contract MyEpicGame is ERC721 {
    // struct com os atributos dos personagens
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // array para nos auxiliar com os characters mintados
    CharacterAttributes[] defaultCharacters;

    // criamos um mapping tookenId => atributos das nfts
    mapping(uint => CharacterAttributes) public nftHolderAttributes;

    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    BigBoss public bigBoss;


    // mapping de um endereco => tokenId das bfts, nos da um jeito facil de armazenar o dono da nft e referencar ele depois

    mapping(address => uint) public nftHolders;

    // Dados passados para o contrato quando ele for criado, inicializando os personagens
    constructor (
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,

        string memory bossName, // Essas novas variáveis serão passadas via run.js ou deploy.js
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
    ) ERC721("Heroes", "HERO") {
    
      // Inicializa o boss. Salva na nossa variável global de estado "bigBoss".
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log("Boss inicializado com sucesso %s com HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);


        // Faz um loop nos personagens e salva os valores deles no contrato, para usarmos para mintar as NFTs

        for(uint i = 0; i < characterNames.length; i++) {
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i]
            }));

            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Personagem inicializado: %s com %s de HP, img %s", c.name, c.hp, c.imageURI);
            }

            _tokenIds.increment();
        }

        function mintCharacterNFT(uint _characterIndex) external {
            uint newItemId = _tokenIds.current();

            //Atribui o tokenID para o endereço da carteira de quem chamou o contrato
            _safeMint(msg.sender, newItemId);

            //mapeamos o tokenId => os atributos dos personagens.
            nftHolderAttributes[newItemId] = CharacterAttributes({
                characterIndex: _characterIndex,
                name: defaultCharacters[_characterIndex].name,
                imageURI: defaultCharacters[_characterIndex].imageURI,
                hp: defaultCharacters[_characterIndex].hp,
                maxHp: defaultCharacters[_characterIndex].maxHp,
                attackDamage: defaultCharacters[_characterIndex].attackDamage
            });

            console.log("Mintou NFT com tokenId %s e characterIndex %s", newItemId, _characterIndex);

            // mantem um jeito facil de ver quem possui a NFT
            nftHolders[msg.sender] = newItemId;

            // Incrementa para a proxima pessoa que usar
            _tokenIds.increment();
    }

    function tokenURI(uint _tokenId) public view override returns(string memory){
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                charAttributes.name,
                ' -- NFT #: ',
                Strings.toString(_tokenId),
                '", "description": "Esta NFT da acesso ao meu jogo NFT!", "image": "',
                charAttributes.imageURI,
                '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
                strAttackDamage,'} ]}'
            )
        );

        string memory output = string(abi.encodePacked("data:application/json;base64,", json));

        return output;
    }
}