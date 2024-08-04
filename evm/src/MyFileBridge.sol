// wormhole-scaffolding-main/evm/src/MyFileBridge.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MyFileBridge is Ownable {
    struct FileInfo {
        string arweaveHash;
        string fileName;
        uint256 fileSize;
        string fileType;
        address uploader;
        uint256 uploadTime;
    }

    mapping(bytes32 => FileInfo) public files;
    mapping(address => bool) public authorizedUploaders;
    uint256 public uploadFee;

    event FileUploaded(
        bytes32 indexed fileId,
        string arweaveHash,
        string fileName,
        uint256 fileSize,
        string fileType,
        address uploader
    );

    constructor(uint256 _uploadFee) {
        uploadFee = _uploadFee;
    }

    modifier onlyAuthorized() {
        require(
            authorizedUploaders[msg.sender] || owner() == msg.sender,
            "Not authorized"
        );
        _;
    }

    function setAuthorizedUploader(
        address uploader,
        bool authorized
    ) external onlyOwner {
        authorizedUploaders[uploader] = authorized;
    }

    function setUploadFee(uint256 fee) external onlyOwner {
        uploadFee = fee;
    }

    function uploadFile(
        bytes32 fileId,
        string calldata arweaveHash,
        string calldata fileName,
        uint256 fileSize,
        string calldata fileType
    ) external payable onlyAuthorized {
        require(msg.value >= uploadFee, "Insufficient fee");
        require(files[fileId].uploadTime == 0, "File already exists");

        files[fileId] = FileInfo({
            arweaveHash: arweaveHash,
            fileName: fileName,
            fileSize: fileSize,
            fileType: fileType,
            uploader: msg.sender,
            uploadTime: block.timestamp
        });

        emit FileUploaded(
            fileId,
            arweaveHash,
            fileName,
            fileSize,
            fileType,
            msg.sender
        );
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
