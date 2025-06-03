const contractAddress = "YOUR_CONTRACT_ADDRESS_HERE";
const abi = YOUR_ABI_HERE;

let web3, contract, accounts;

window.addEventListener('load', async () => {
  if (window.ethereum) {
    web3 = new Web3(window.ethereum);
    await window.ethereum.request({ method: 'eth_requestAccounts' });
    accounts = await web3.eth.getAccounts();
    contract = new web3.eth.Contract(abi, contractAddress);
    document.getElementById("status").textContent = "Connected: " + accounts[0];
  } else {
    alert("Please install MetaMask to use this DApp");
  }
});

async function issueCertificate() {
  const student = document.getElementById("studentName").value;
  const course = document.getElementById("courseName").value;
  const expDate = new Date(document.getElementById("expirationDate").value).getTime() / 1000;
  const ipfsHash = document.getElementById("ipfsHash").value;

  try {
    await contract.methods.issueCertificate(student, course, expDate, ipfsHash)
      .send({ from: accounts[0] });
    log("Certificate issued successfully.");
  } catch (err) {
    log("Error: " + err.message);
  }
}

async function verifyCertificate() {
  const hash = document.getElementById("verifyHash").value;

  try {
    const cert = await contract.methods.verifyCertificate(hash).call();
    document.getElementById("verifyResult").innerHTML = `
      Student: ${cert.studentName}<br>
      Course: ${cert.courseName}<br>
      Issued: ${new Date(cert.issueDate * 1000).toLocaleString()}<br>
      Expires: ${new Date(cert.expirationDate * 1000).toLocaleString()}<br>
      Revoked: ${cert.revoked}<br>
      IPFS: ${cert.ipfsHash ? `<a href="https://ipfs.io/ipfs/${cert.ipfsHash}" target="_blank">${cert.ipfsHash}</a>` : 'N/A'}
    `;
  } catch (err) {
    log("Error: " + err.message);
  }
}

async function revokeCertificate() {
  const hash = document.getElementById("revokeHash").value;
  try {
    await contract.methods.revokeCertificate(hash).send({ from: accounts[0] });
    log("Certificate revoked.");
  } catch (err) {
    log("Error: " + err.message);
  }
}

function log(message) {
  document.getElementById("status").textContent = message;
}
