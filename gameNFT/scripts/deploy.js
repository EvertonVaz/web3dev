const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
    const gameContract = await gameContractFactory.deploy(
        ["Eleven", "Lucas", "Mike", "Dustin"],
        [
            "https://imgur.com/an3GgIm.png",
            "https://imgur.com/U9upCQA.png",
            "https://imgur.com/X5G9IsL.png",
            "https://imgur.com/hdr1XtD.png",
        ],
    [400, 200, 100, 150], // HP values
    [300, 150, 25, 100], // Attack damage values
    "Mind Flayer",
    "https://i.imgur.com/dvHOFBX.png",
    10000,
    50
  );
    await gameContract.deployed();
    console.log("Contrato implantado no endereço:", gameContract.address)
  
    let txn;
    txn = await gameContract.mintCharacterNFT(0);
    await txn.wait();

    txn = await gameContract.attackBoss();
    await txn.wait();
    
    txn = await gameContract.attackBoss();
    await txn.wait();
  
    console.log("Fim do deploy, mint e attack!");
  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();
  