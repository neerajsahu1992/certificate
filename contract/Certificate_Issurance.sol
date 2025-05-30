// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Certificate Issuer Contract
/// @notice This contract allows authorized issuance, verification, revocation, and expiration of certificates, with frontend/IPFS integration.

contract CertificateIssuer {
    address public owner;

    struct Certificate {
        string studentName;
        string courseName;
        uint256 issueDate;
        uint256 expirationDate;
        string ipfsHash; // IPFS hash for the certificate file
    }

    mapping(bytes32 => Certificate) private certificates;
    bytes32[] private certificateHashes;

    event CertificateIssued(bytes32 indexed certHash, string studentName, string courseName, uint256 issueDate, uint256 expirationDate, string ipfsHash);
    event CertificateRevoked(bytes32 indexed certHash);
    event ExpirationUpdated(bytes32 indexed certHash, uint256 newExpirationDate);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only owner allowed");
        _;
    }

    function issueCertificate(
        string memory studentName,
        string memory courseName,
        uint256 expirationDate,
        string memory ipfsHash
    ) external onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, block.timestamp, ipfsHash));
        certificates[certHash] = Certificate(studentName, courseName, block.timestamp, expirationDate, ipfsHash);
        certificateHashes.push(certHash);
        emit CertificateIssued(certHash, studentName, courseName, block.timestamp, expirationDate, ipfsHash);
    }

    function verifyCertificate(bytes32 certHash) external view returns (
        string memory studentName,
        string memory courseName,
        uint256 issueDate,
        uint256 expirationDate,
        string memory ipfsHash
    ) {
        Certificate memory cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        return (cert.studentName, cert.courseName, cert.issueDate, cert.expirationDate, cert.ipfsHash);
    }

    function revokeCertificate(bytes32 certHash) external onlyOwner {
        require(certificates[certHash].issueDate != 0, "Certificate not found");
        delete certificates[certHash];

        for (uint256 i = 0; i < certificateHashes.length; i++) {
            if (certificateHashes[i] == certHash) {
                certificateHashes[i] = certificateHashes[certificateHashes.length - 1];
                certificateHashes.pop();
                break;
            }
        }

        emit CertificateRevoked(certHash);
    }

    function updateCertificateExpiration(bytes32 certHash, uint256 newExpirationDate) external onlyOwner {
        require(certificates[certHash].issueDate != 0, "Certificate not found");
        certificates[certHash].expirationDate = newExpirationDate;
        emit ExpirationUpdated(certHash, newExpirationDate);
    }

    function generateCertHash(
        string memory studentName,
        string memory courseName,
        uint256 timestamp,
        string memory ipfsHash
    ) external pure returns (bytes32 certHash) {
        return keccak256(abi.encodePacked(studentName, courseName, timestamp, ipfsHash));
    }

    function checkCertificateExists(
        string memory studentName,
        string memory courseName,
        uint256 timestamp,
        string memory ipfsHash
    ) external view returns (bool exists) {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, timestamp, ipfsHash));
        return certificates[certHash].issueDate != 0;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        owner = newOwner;
    }

    function getCertificateCount() external view returns (uint256 count) {
        return certificateHashes.length;
    }

    function getAllCertificates() external view returns (bytes32[] memory) {
        return certificateHashes;
    }

    function getCertificateByIndex(uint256 index) external view returns (
        string memory studentName,
        string memory courseName,
        uint256 issueDate,
        uint256 expirationDate,
        string memory ipfsHash
    ) {
        require(index < certificateHashes.length, "Index out of bounds");
        bytes32 certHash = certificateHashes[index];
        Certificate memory cert = certificates[certHash];
        return (cert.studentName, cert.courseName, cert.issueDate, cert.expirationDate, cert.ipfsHash);
    }

    function isValidCertificateHash(bytes32 certHash) external view returns (bool exists) {
        return certificates[certHash].issueDate != 0;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function isOwner() external view returns (bool) {
        return msg.sender == owner;
    }
}
