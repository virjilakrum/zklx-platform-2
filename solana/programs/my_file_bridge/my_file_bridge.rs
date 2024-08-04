// wormhole-scaffolding-main/solana/programs/my_file_bridge/tests/my_file_bridge.rs
use solana_program_test::*;
use solana_sdk::{
    account::Account,
    pubkey::Pubkey,
    signature::{Keypair, Signer},
    transaction::Transaction,
};
use my_file_bridge::{FileAccount, FileInfo};
use borsh::BorshSerialize;

#[tokio::test]
async fn test_upload_file() {
    let program_id = Pubkey::new_unique();
    let uploader = Keypair::new();
    let file_account = Keypair::new();
    let file_info = FileInfo {
        arweave_hash: "arweaveHash".to_string(),
        file_name: "example.txt".to_string(),
        file_size: 1024,
        file_type: "text/plain".to_string(),
        uploader: uploader.pubkey(),
        upload_time: 0, // placeholder
    };

    let mut program_test = ProgramTest::new(
        "my_file_bridge",
        program_id,
        processor!(my_file_bridge::process_instruction),
    );

    program_test.add_account(
        file_account.pubkey(),
        Account {
            lamports: 1_000_000_000,
            data: vec![0; FileAccount::LEN],
            owner: program_id,
            ..Account::default()
        },
    );

    let (mut banks_client, payer, recent_blockhash) = program_test.start().await;

    let mut transaction = Transaction::new_with_payer(
        &[
            my_file_bridge::instruction::upload_file(
                program_id,
                file_account.pubkey(),
                uploader.pubkey(),
                file_info,
            ),
        ],
        Some(&payer.pubkey()),
    );

    transaction.sign(&[&payer, &uploader, &file_account], recent_blockhash);
    banks_client.process_transaction(transaction).await.unwrap();

    let account = banks_client
        .get_account(file_account.pubkey())
        .await
        .unwrap()
        .unwrap();

    let file_account_state = FileAccount::try_from_slice(&account.data).unwrap();
    assert_eq!(file_account_state.file_info, file_info);
}
