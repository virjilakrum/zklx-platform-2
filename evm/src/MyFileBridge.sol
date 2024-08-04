// wormhole-scaffolding-main/evm/src/MyFileBridge.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FileRegistry is Ownable {
    struct FileInfo {
        string arweaveHash; // Arweave'de depolanan dosyanın hash'i
        address uploader; // Dosyayı yükleyen Ethereum adresi
        mapping(address => bool) authorizedViewers; // İzin verilen görüntüleyenlerin listesi
        uint256 viewerCount; // İzin verilen görüntüleyen sayısı (optimizasyon için)
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

        files[fileId].arweaveHash = arweaveHash;
        files[fileId].uploader = msg.sender;
        files[fileId].viewerCount = 0; // Başlangıçta görüntüleyen yok

        emit FileHashRegistered(fileId, arweaveHash, msg.sender);
    }

    function authorizeViewer(
        bytes32 fileId,
        address viewer
    ) external onlyUploaderOrOwner(fileId) {
        require(
            !files[fileId].authorizedViewers[viewer],
            "Viewer already authorized"
        );

        files[fileId].authorizedViewers[viewer] = true;
        files[fileId].viewerCount++;

        emit ViewerAuthorized(fileId, viewer);
    }

    function revokeViewer(
        bytes32 fileId,
        address viewer
    ) external onlyUploaderOrOwner(fileId) {
        require(
            files[fileId].authorizedViewers[viewer],
            "Viewer not authorized"
        );

        files[fileId].authorizedViewers[viewer] = false;
        files[fileId].viewerCount--;

        emit ViewerRevoked(fileId, viewer);
    }

    // Gas optimizasyonu için izin verilen görüntüleyenlerin listesini döndürmez.
    // Bunun yerine, görüntüleyenlerin tek tek kontrol edilir.

    function isViewerAuthorized(
        bytes32 fileId,
        address viewer
    ) public view returns (bool) {
        return files[fileId].authorizedViewers[viewer];
    }

    function getFileHash(bytes32 fileId) external view returns (string memory) {
        require(isViewerAuthorized(fileId, msg.sender), "Not authorized");
        return files[fileId].arweaveHash;
    }
}
