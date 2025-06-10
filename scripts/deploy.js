// scripts/deploy.js

const hre = require("hardhat");

async function main() {
  console.log("Deploying CertificateIssuer contract...");

  const CertificateIssuer = await hre.ethers.getContractFactory("CertificateIssuer");
  const certificateIssuer = await CertificateIssuer.deploy();

  await certificateIssuer.deployed();

  console.log("✅ CertificateIssuer deployed to:", certificateIssuer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
