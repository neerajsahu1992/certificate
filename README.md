# Blockchain-Based Certificate Issuance

## 📄 Project Description
This project aims to digitize and secure academic and professional certificates using blockchain technology. It ensures tamper-proof, easily verifiable, and immutable digital credentials for students, professionals, and institutions.
   
## 🎯 Project Vision
To eliminate fraudulent claims and bring transparency, trust, and security to the certificate issuance process by leveraging the decentralization and immutability of blockchain.

## ✨ Key Features
- **Decentralized Certificate Storage**: Certificates are issued and stored securely on the blockchain.
- **Public Verifiability**: Anyone can verify the authenticity of a certificate using its unique hash.
- **Owner-Only Issuance**: Only authorized institutions can issue certificates through the smart contract.

## 🔮 Future Scope
- 🔒 Integration with IPFS for full certificate storage (PDF/image format).
- 🧾 NFT-based certificates to enable easier transfer and ownership tracking.
- 🏫 Multi-institution access control for broader scalability.
- 📱 Front-end dApp for user-friendly interaction and verification. .
- 📜 Timestamp and QR-code-based printable credentials.


## Contract Details:
  
0xf8e81D47203A594245E36C48e151709F0C19fBe8

<img width="951" alt="image" src="https://github.com/user-attachments/assets/1b12c139-2536-4271-bab8-563423fdf6ab" />

### Structs

```solidity
struct Certificate {
    string studentName;
    string courseName;
    uint256 issueDate;
}
