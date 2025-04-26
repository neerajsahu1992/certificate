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
    /// @param studentName The student's name
    /// @param courseName The course name
    function issueCertificate(string memory studentName, string memory courseName) external onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, block.timestamp));
        certificates[certHash] = Certificate(studentName, courseName, block.timestamp);
    }

    /// @notice Verifies and fetches certificate details
    /// @param certHash The hash of the certificate
    /// @return studentName The student's name
    /// @return courseName The course name
    /// @return issueDate The date the certificate was issued
    function verifyCertificate(bytes32 certHash) external view returns (string memory studentName, string memory courseName, uint256 issueDate) {
        Certificate memory cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        return (cert.studentName, cert.courseName, cert.issueDate);
    }

    /// @notice Revokes (deletes) an issued certificate
    /// @param certHash The hash of the certificate to revoke
    function revokeCertificate(bytes32 certHash) external onlyOwner {
        require(certificates[certHash].issueDate != 0, "Certificate not found");
        delete certificates[certHash];
    }

    /// @notice Generates a certificate hash for off-chain use
    /// @param studentName The student's name
    /// @param courseName The course name
    /// @param timestamp The issuance timestamp
    /// @return certHash The generated certificate hash
    function generateCertHash(string memory studentName, string memory courseName, uint256 timestamp) external pure returns (bytes32 certHash) {
        return keccak256(abi.encodePacked(studentName, courseName, timestamp));
    }
}
