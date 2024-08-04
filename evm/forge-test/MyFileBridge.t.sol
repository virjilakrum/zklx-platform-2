// wormhole-scaffolding-main/evm/forge-test/MyFileBridge.t.sol
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyFileBridge.sol";

contract MyFileBridgeTest is Test {
    MyFileBridge myFileBridge;
    address owner = address(0x123); //güncellenecek
    address uploader = address(0x456); //güncellenecek
    bytes32 fileId = keccak256("file1");
    string arweaveHash = "arweaveHash";
    string fileName = "example.txt";
    uint256 fileSize = 1024;
    string fileType = "text/plain";
    uint256 uploadFee = 1 ether;

    function setUp() public {
        myFileBridge = new MyFileBridge(uploadFee);
        myFileBridge.setAuthorizedUploader(uploader, true);
    }

    function testUploadFile() public {
        vm.prank(uploader);
        vm.deal(uploader, 2 ether);
        myFileBridge.uploadFile{value: uploadFee}(
            fileId,
            arweaveHash,
            fileName,
            fileSize,
            fileType
        );

        MyFileBridge.FileInfo memory fileInfo = myFileBridge.files(fileId);
        assertEq(fileInfo.arweaveHash, arweaveHash);
        assertEq(fileInfo.fileName, fileName);
        assertEq(fileInfo.fileSize, fileSize);
        assertEq(fileInfo.fileType, fileType);
        assertEq(fileInfo.uploader, uploader);
        assertEq(fileInfo.uploadTime > 0, true);
    }

    function testWithdraw() public {
        vm.prank(uploader);
        vm.deal(uploader, 2 ether);
        myFileBridge.uploadFile{value: uploadFee}(
            fileId,
            arweaveHash,
            fileName,
            fileSize,
            fileType
        );

        uint256 balanceBefore = owner.balance;
        myFileBridge.withdraw();
        uint256 balanceAfter = owner.balance;
        assertEq(balanceAfter > balanceBefore, true);
    }
}
