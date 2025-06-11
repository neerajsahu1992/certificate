const CONTRACT_ADDRESS = "0xf8e81D47203A594245E36C48e151709F0C19fBe8";
const ABI = certificateIssuerABI;

let web3, contract, account;

window.addEventListener('load', async () => {
  if (window.ethereum) {
    web3 = new Web3(window.ethereum);
    await window.ethereum.request({ method: 'eth_requestAccounts' });
    [account] = await web3.eth.getAccounts();
    contract = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);
    setStatus(`Connected account: ${account}`);
  } else {
    alert("Please install MetaMask to use this DApp.");
  }
});

const setStatus = msg => document.getElementById("status").textContent = msg;

const handleTx = async (promise, successMsg) => {
  try {
    setStatus("Waiting for confirmation...");
    await promise;
    setStatus(successMsg);
  } catch (err) {
    setStatus("Error: " + err.message);
  }
};

document.getElementById("btnIssue").onclick = async () => {
  const name = document.getElementById("studentName").value;
  const course = document.getElementById("courseName").value;
  const exp = new Date(document.getElementById("expirationDate").value).getTime() / 1000;
  const ipfs = document.getElementById("ipfsHash").value;
  if (!name || !course || !exp) return setStatus("Fill all fields.");
  const tx = contract.methods.issueCertificate(name, course, exp, ipfs).send({ from: account });
  await handleTx(tx, "Certificate issued successfully.");
};

document.getElementById("btnVerify").onclick = async () => {
  const hash = document.getElementById("verifyHash").value;
  if (!hash) return setStatus("Enter certificate hash.");
  try {
    const cert = await contract.methods.verifyCertificate(hash).call();
    const { studentName, courseName, issueDate, expirationDate, ipfsHash } = cert;
    const issue = new Date(issueDate * 1000).toLocaleString();
    const exp = new Date(expirationDate * 1000).toLocaleString();
    const ipfsLink = ipfsHash
      ? `<a href="https://ipfs.io/ipfs/${ipfsHash}" target="_blank">${ipfsHash}</a>`
      : "N/A";
    document.getElementById("verifyResult").innerHTML = `
      <strong>Student:</strong> ${studentName}<br>
      <strong>Course:</strong> ${courseName}<br>
      <strong>Issued:</strong> ${issue}<br>
      <strong>Expires:</strong> ${exp}<br>
      <strong>IPFS:</strong> ${ipfsLink}
    `;
    setStatus("Fetched certificate details.");
  } catch (err) {
    setStatus("Error: Certificate not found.");
    document.getElementById("verifyResult").innerHTML = "";
  }
};

document.getElementById("btnRevoke").onclick = async () => {
  const hash = document.getElementById("revokeHash").value;
  if (!hash) return setStatus("Enter certificate hash.");
  const tx = contract.methods.revokeCertificate(hash).send({ from: account });
  await handleTx(tx, "Certificate revoked successfully.");
};

document.getElementById("btnUpdateExpiration").onclick = async () => {
  const hash = document.getElementById("updateHash").value;
  const exp = new Date(document.getElementById("newExpirationDate").value).getTime() / 1000;
  if (!hash || !exp) return setStatus("Fill both fields.");
  const tx = contract.methods.updateCertificateExpiration(hash, exp).send({ from: account });
  await handleTx(tx, "Expiration updated successfully.");
};
