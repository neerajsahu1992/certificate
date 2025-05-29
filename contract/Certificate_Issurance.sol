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

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only owner allowed");
        _;
    }

    function issueCertificate(string memory studentName, string memory courseName) external onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, block.timestamp));
        certificates[certHash] = Certificate(studentName, courseName, block.timestamp);
        certificateHashes.push(certHash);
    }

    function verifyCertificate(bytes32 certHash) external view returns (
        string memory studentName,
        string memory courseName,
        uint256 issueDate
    ) {
        Certificate memory cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        return (cert.studentName, cert.courseName, cert.issueDate);
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
    }

    function generateCertHash(
        string memory studentName,
        string memory courseName,
        uint256 timestamp
    ) external pure returns (bytes32 certHash) {
        return keccak256(abi.encodePacked(studentName, courseName, timestamp));
    }

    function checkCertificateExists(
        string memory studentName,
        string memory courseName,
        uint256 timestamp
    ) external view returns (bool exists) {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, timestamp));
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

    function getCertificateHash(string memory studentName, string memory courseName, uint256 timestamp) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(studentName, courseName, timestamp));
    }

    function isOwner() external view returns (bool) {
        return msg.sender == owner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

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

    function isValidCertificateHash(bytes32 certHash) external view returns (bool exists) {
        return certificates[certHash].issueDate != 0;
    }

    function getAllCertificateDetails() external view returns (Certificate[] memory certs) {
        uint256 count = certificateHashes.length;
        certs = new Certificate[](count);
        for (uint256 i = 0; i < count; i++) {
            certs[i] = certificates[certificateHashes[i]];
        }
    }

    function updateCourseName(bytes32 certHash, string memory newCourseName) external onlyOwner {
        Certificate storage cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        cert.courseName = newCourseName;
    }

    function getCertificatesByStudent(string memory studentName) external view returns (Certificate[] memory results) {
        uint256 total = certificateHashes.length;
        uint256 count = 0;

        for (uint256 i = 0; i < total; i++) {
            if (keccak256(bytes(certificates[certificateHashes[i]].studentName)) == keccak256(bytes(studentName))) {
                count++;
            }
        }

        results = new Certificate[](count);
        uint256 j = 0;

        for (uint256 i = 0; i < total; i++) {
            Certificate memory cert = certificates[certificateHashes[i]];
            if (keccak256(bytes(cert.studentName)) == keccak256(bytes(studentName))) {
                results[j] = cert;
                j++;
            }
        }
    }

    /// @notice Returns whether a student has any issued certificates
    function hasCertificates(string memory studentName) external view returns (bool) {
        for (uint256 i = 0; i < certificateHashes.length; i++) {
            if (keccak256(bytes(certificates[certificateHashes[i]].studentName)) == keccak256(bytes(studentName))) {
                return true;
            }
        }
        return false;
    }
}
