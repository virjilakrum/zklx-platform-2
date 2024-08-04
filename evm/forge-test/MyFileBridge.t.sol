// wormhole-scaffolding-main/evm/forge-test/MyFileBridge.t.sol
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyFileBridge.sol";

contract MyFileBridgeTest is Test {
    MyFileBridge myFileBridge;
    address owner = address(0x123); // Owner adresi
    address uploader = address(0x456); // Uploader adresi
    address viewer = address(0x789); // Viewer adresi
    bytes32 fileId = keccak256("file1");
    string arweaveHash = "arweaveHash";
    string fileName = "example.txt";
    uint256 fileSize = 1024;
    string fileType = "text/plain";
    uint256 uploadFee = 1 ether;
    uint256 viewFee = 0.5 ether; // View fee eklendi

    function setUp() public {
        // Kontratı viewFee ile oluştur
        myFileBridge = new MyFileBridge(uploadFee, viewFee);

        // Owner ve uploader yetkilendir
        myFileBridge.setAuthorizedUploader(uploader, true);
        vm.prank(owner);
        myFileBridge.transferOwnership(owner); // Ownership transfer edildi
    }

    function testUploadFile() public {
        vm.prank(uploader);
        vm.deal(uploader, 2 ether); // Uploader'a yeteri kadar ETH ver
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

    function testViewFile() public {
        testUploadFile(); // Dosya yükleme testini çalıştır

        vm.prank(viewer);
        vm.deal(viewer, 1 ether); // Viewer'a yeteri kadar ETH ver
        myFileBridge.viewFile{value: viewFee}(fileId);

        // Viewer yetkilendirilmiş mi kontrol et
        assertEq(myFileBridge.isViewerAuthorized(fileId, viewer), true);

        // Görüntüleme sayısı arttı mı kontrol et
        assertEq(myFileBridge.viewCounts(fileId), 1);
    }

    function testWithdraw() public {
        testViewFile(); // ViewFile testini çalıştır (gelir elde etmek için)

        uint256 balanceBefore = owner.balance;
        vm.prank(owner);
        myFileBridge.withdraw(); // Owner olarak para çekme işlemi
        uint256 balanceAfter = owner.balance;

        assertEq(balanceAfter - balanceBefore, uploadFee + viewFee); // Toplam gelirin çekildiğini doğrula
    }

    // Yetkisiz yükleme, yetersiz bakiye ile yükleme/görüntüleme gibi diğer test senaryoları da ekleyeceğim.
}
