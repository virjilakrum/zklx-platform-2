// wormhole-scaffolding-main/solana/programs/my_file_bridge/tests/my_file_bridge.rs
use {
    borsh::{BorshDeserialize, BorshSerialize},
    solana_program::{hash::hashv, pubkey::Pubkey, system_instruction},
    solana_program_test::*,
    solana_sdk::{
        account::Account,
        signature::{Keypair, Signer},
        transaction::Transaction,
    },
    my_file_bridge::{entrypoint::process_instruction, instruction, FileAccount, FileInfo},
};

#[tokio::test]
async fn test_upload_file() {
    // Program ID ve hesaplar
    let program_id = Pubkey::new_unique();
    let uploader = Keypair::new();
    let file_account = Keypair::new();

    // FileInfo verisi
    let file_info = FileInfo {
        arweave_hash: "arweaveHash".to_string(),
        file_name: "example.txt".to_string(),
        file_size: 1024,
        file_type: "text/plain".to_string(),
        uploader: uploader.pubkey(),
        authorized_viewers: vec![], // Başlangıçta yetkili görüntüleyen yok
        timestamp: 0, // Demo için şimdilik 0
    };

    // Program Test ortamını hazırla
    let mut program_test = ProgramTest::new(
        "my_file_bridge",
        program_id,
        processor!(process_instruction),
    );

    // Test için hesap ekle
    program_test.add_account(
        file_account.pubkey(),
        Account {
            lamports: 1000000000, // Rent için yeterli miktar
            data: vec![0; FileAccount::try_from_slice(&[0u8; 1000][..]).unwrap().try_to_vec().unwrap().len()], // Hesap verisi boyutu
            owner: program_id,
            ..Account::default()
        },
    );

    // Test ortamını başlat
    let (mut banks_client, payer, recent_blockhash) = program_test.start().await;

    // Talimat verisini oluştur
    let mut instruction_data = file_info.try_to_vec().unwrap();

    // Transaction oluştur
    let mut transaction = Transaction::new_with_payer(
        &[
            system_instruction::create_account(
                &payer.pubkey(),
                &file_account.pubkey(),
                1000000000, // Rent için yeterli miktar
                FileAccount::try_from_slice(&[0u8; 1000][..]).unwrap().try_to_vec().unwrap().len() as u64,
                &program_id,
            ),
            instruction::upload_file(
                program_id,
                file_account.pubkey(),
                uploader.pubkey(),
                instruction_data,
            ),
        ],
        Some(&payer.pubkey()),
    );

    // Transaction'ı imzala
    transaction.sign(&[&payer, &file_account, &uploader], recent_blockhash);

    // Transaction'ı gönder ve sonucu kontrol et
    banks_client.process_transaction(transaction).await.unwrap();

    // Hesap verisini al
    let file_account_data = banks_client
        .get_account(file_account.pubkey())
        .await
        .unwrap()
        .unwrap()
        .data;

    // Hesap verisini FileAccount yapısına dönüştür
    let file_account_state = FileAccount::try_from_slice(&file_account_data).unwrap();

    // FileInfo verisinin doğru şekilde kaydedildiğini doğrula
    assert_eq!(file_account_state.file_info, file_info);
}
