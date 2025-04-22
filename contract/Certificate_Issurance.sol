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
    bytes32[] public issuedCertificateHashes;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Function to issue a new certificate
    function issueCertificate(string memory studentName, string memory courseName) public onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(studentName, courseName, block.timestamp));
        certificates[certHash] = Certificate(studentName, courseName, block.timestamp);
        issuedCertificateHashes.push(certHash);
    }

    // Function to verify a certificate
    function verifyCertificate(bytes32 certHash) public view returns (string memory, string memory, uint256) {
        Certificate memory cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        return (cert.studentName, cert.courseName, cert.issueDate);
    }

    // Function to update certificate details
    function updateCertificate(bytes32 certHash, string memory newStudentName, string memory newCourseName) public onlyOwner {
        Certificate storage cert = certificates[certHash];
        require(cert.issueDate != 0, "Certificate not found");
        cert.studentName = newStudentName;
        cert.courseName = newCourseName;
    }

    // Function to revoke a certificate
    function revokeCertificate(bytes32 certHash) public onlyOwner {
        require(certificates[certHash].issueDate != 0, "Certificate not found");
        delete certificates[certHash];
    }

    // New Function 1: Get certificate hash by index (to list issued certificates)
    function getCertificateHashByIndex(uint index) public view returns (bytes32) {
        require(index < issuedCertificateHashes.length, "Index out of bounds");
        return issuedCertificateHashes[index];
    }

    // New Function 2: Get total number of issued certificates
    function getIssuedCertificateCount() public view returns (uint) {
        return issuedCertificateHashes.length;
    }
}
