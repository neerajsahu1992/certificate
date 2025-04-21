// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateIssuer {
    address public owner;

    struct Certificate {
        string studentName;
        string courseName;
        uint256 issueDate;
        bool isValid;
    }

    mapping(bytes32 => Certificate) public certificates;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function issueCertificate(string memory studentName, string memory courseName) public onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, block.timestamp));
        certificates[certHash] = Certificate(studentName, courseName, block.timestamp, true);
    }

    function verifyCertificate(bytes32 certHash) public view returns (string memory, string memory, uint256, bool) {
        Certificate memory cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        return (cert.studentName, cert.courseName, cert.issueDate, cert.isValid);
    }

    function getCertificateHash(string memory studentName, string memory courseName, uint256 timestamp) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(studentName, courseName, timestamp));
    }

    function revokeCertificate(bytes32 certHash) public onlyOwner {
        require(certificates[certHash].isValid, "Certificate not found or already revoked");
        certificates[certHash].isValid = false;
    }
}
