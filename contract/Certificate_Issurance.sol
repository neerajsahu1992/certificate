// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateIssuer {
    address public owner;

    struct Certificate {
        string studentName;
        string courseName;
        uint256 issueDate;
    }

    mapping(bytes32 => Certificate) public certificates;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // 1. Issue a new certificate
    function issueCertificate(string memory studentName, string memory courseName) public onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, block.timestamp));
        certificates[certHash] = Certificate(studentName, courseName, block.timestamp);
    }

    // 2. Verify an existing certificate
    function verifyCertificate(bytes32 certHash) public view returns (string memory, string memory, uint256) {
        Certificate memory cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        return (cert.studentName, cert.courseName, cert.issueDate);
    }

    // 3. Revoke an issued certificate
    function revokeCertificate(bytes32 certHash) public onlyOwner {
        require(certificates[certHash].issueDate != 0, "Certificate not found");
        delete certificates[certHash];
    }

    // 4. Get the hash of a certificate (to use in verification)
    function generateCertHash(string memory studentName, string memory courseName, uint256 timestamp) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(studentName, courseName, timestamp));
    }
}
