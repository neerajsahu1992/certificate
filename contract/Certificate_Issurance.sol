// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Certificate Issuer
/// @author 
/// @notice This smart contract allows issuance, verification, and revocation of certificates on the blockchain.

contract CertificateIssuer {
    address public owner;

    struct Certificate {
        string studentName;
        string courseName;
        uint256 issueDate;
    }

    mapping(bytes32 => Certificate) private certificates;

    /// @notice Sets the contract deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Restricts function usage to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only owner allowed");
        _;
    }

    /// @notice Issues a new certificate
    /// @param studentName Name of the student
    /// @param courseName Name of the course
    function issueCertificate(string memory studentName, string memory courseName) external onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, block.timestamp));
        certificates[certHash] = Certificate(studentName, courseName, block.timestamp);
    }

    /// @notice Verifies and fetches certificate details
    /// @param certHash Unique certificate hash
    /// @return studentName, courseName, issueDate
    function verifyCertificate(bytes32 certHash) external view returns (string memory studentName, string memory courseName, uint256 issueDate) {
        Certificate memory cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        return (cert.studentName, cert.courseName, cert.issueDate);
    }

    /// @notice Revokes (deletes) an issued certificate
    /// @param certHash Unique certificate hash
    function revokeCertificate(bytes32 certHash) external onlyOwner {
        require(certificates[certHash].issueDate != 0, "Certificate not found");
        delete certificates[certHash];
    }

    /// @notice Utility function to generate a certificate hash
    /// @param studentName Name of the student
    /// @param courseName Name of the course
    /// @param timestamp Issuance timestamp
    /// @return certHash Generated certificate hash
    function generateCertHash(string memory studentName, string memory courseName, uint256 timestamp) external pure returns (bytes32 certHash) {
        return keccak256(abi.encodePacked(studentName, courseName, timestamp));
    }
}
