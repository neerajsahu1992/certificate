// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Certificate Issuer Contract
/// @notice This contract allows authorized issuance, verification, and revocation of certificates.

contract CertificateIssuer {
    address public owner;

    struct Certificate {
        string studentName;
        string courseName;
        uint256 issueDate;
    }

    mapping(bytes32 => Certificate) private certificates;
    bytes32[] private certificateHashes;

    /// @notice Sets the deployer as the contract owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Restricts access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only owner allowed");
        _;
    }

    /// @notice Issues a new certificate
    function issueCertificate(string memory studentName, string memory courseName) external onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, block.timestamp));
        certificates[certHash] = Certificate(studentName, courseName, block.timestamp);
        certificateHashes.push(certHash);
    }

    /// @notice Verifies and fetches certificate details
    function verifyCertificate(bytes32 certHash) external view returns (
        string memory studentName,
        string memory courseName,
        uint256 issueDate
    ) {
        Certificate memory cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        return (cert.studentName, cert.courseName, cert.issueDate);
    }

    /// @notice Revokes an issued certificate
    function revokeCertificate(bytes32 certHash) external onlyOwner {
        require(certificates[certHash].issueDate != 0, "Certificate not found");
        delete certificates[certHash];

        // Remove from certificateHashes
        for (uint256 i = 0; i < certificateHashes.length; i++) {
            if (certificateHashes[i] == certHash) {
                certificateHashes[i] = certificateHashes[certificateHashes.length - 1];
                certificateHashes.pop();
                break;
            }
        }
    }

    /// @notice Generates a certificate hash for off-chain use
    function generateCertHash(
        string memory studentName,
        string memory courseName,
        uint256 timestamp
    ) external pure returns (bytes32 certHash) {
        return keccak256(abi.encodePacked(studentName, courseName, timestamp));
    }

    /// @notice Checks if a certificate exists
    function checkCertificateExists(
        string memory studentName,
        string memory courseName,
        uint256 timestamp
    ) external view returns (bool exists) {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, timestamp));
        return certificates[certHash].issueDate != 0;
    }

    /// @notice Transfers contract ownership to a new address
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        owner = newOwner;
    }

    /// @notice Returns the total number of issued certificates
    function getCertificateCount() external view returns (uint256 count) {
        return certificateHashes.length;
    }

    /// @notice Returns all certificate hashes
    function getAllCertificates() external view returns (bytes32[] memory) {
        return certificateHashes;
    }

    /// @notice Returns the cert hash for given input
    function getCertificateHash(string memory studentName, string memory courseName, uint256 timestamp) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(studentName, courseName, timestamp));
    }

    /// @notice Checks if the caller is the contract owner
    function isOwner() external view returns (bool) {
        return msg.sender == owner;
    }

    /// @notice Gets the current owner
    function getOwner() external view returns (address) {
        return owner;
    }

    /// @notice Returns the certificate details by index
    function getCertificateByIndex(uint256 index) external view returns (
        string memory studentName,
        string memory courseName,
        uint256 issueDate
    ) {
        require(index < certificateHashes.length, "Index out of bounds");
        bytes32 certHash = certificateHashes[index];
        Certificate memory cert = certificates[certHash];
        return (cert.studentName, cert.courseName, cert.issueDate);
    }

    /// @notice Returns true if a given hash is a valid certificate hash in the registry
    function isValidCertificateHash(bytes32 certHash) external view returns (bool exists) {
        return certificates[certHash].issueDate != 0;
    }
}
