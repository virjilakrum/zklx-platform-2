// wormhole-scaffolding-main/evm/src/MyFileBridge.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FileRegistry is Ownable {
    struct FileInfo {
        string arweaveHash;
        address uploader;
        address[] authorizedViewers;
    }

    mapping(bytes32 => FileInfo) public files;

    event FileHashRegistered(
        bytes32 indexed fileId,
        string arweaveHash,
        address indexed uploader
    );
    event ViewerAuthorized(bytes32 indexed fileId, address indexed viewer);
    event ViewerRevoked(bytes32 indexed fileId, address indexed viewer);

    modifier onlyUploaderOrOwner(bytes32 fileId) {
        require(
            msg.sender == files[fileId].uploader || msg.sender == owner(),
            "Not authorized"
        );
        _;
    }

    function registerFile(
        bytes32 fileId,
        string calldata arweaveHash
    ) external {
        require(
            files[fileId].uploader == address(0),
            "File already registered"
        );

        files[fileId] = FileInfo({
            arweaveHash: arweaveHash,
            uploader: msg.sender,
            authorizedViewers: new address
        });

        emit FileHashRegistered(fileId, arweaveHash, msg.sender);
    }

    function authorizeViewer(
        bytes32 fileId,
        address viewer
    ) external onlyUploaderOrOwner(fileId) {
        files[fileId].authorizedViewers.push(viewer);
        emit ViewerAuthorized(fileId, viewer);
    }

    function revokeViewer(
        bytes32 fileId,
        address viewer
    ) external onlyUploaderOrOwner(fileId) {
        uint256 viewerCount = files[fileId].authorizedViewers.length;
        for (uint256 i = 0; i < viewerCount; i++) {
            if (files[fileId].authorizedViewers[i] == viewer) {
                files[fileId].authorizedViewers[i] = files[fileId]
                    .authorizedViewers[viewerCount - 1];
                files[fileId].authorizedViewers.pop();
                emit ViewerRevoked(fileId, viewer);
                break;
            }
        }
    }

    function getAuthorizedViewers(
        bytes32 fileId
    ) external view returns (address[] memory) {
        return files[fileId].authorizedViewers;
    }

    function isViewerAuthorized(
        bytes32 fileId,
        address viewer
    ) external view returns (bool) {
        for (uint256 i = 0; i < files[fileId].authorizedViewers.length; i++) {
            if (files[fileId].authorizedViewers[i] == viewer) {
                return true;
            }
        }
        return false;
    }

    function getFileHash(bytes32 fileId) external view returns (string memory) {
        require(isViewerAuthorized(fileId, msg.sender), "Not authorized");
        return files[fileId].arweaveHash;
    }
}
