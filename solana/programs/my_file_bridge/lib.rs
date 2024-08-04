// wormhole-scaffolding-main/solana/programs/my_file_bridge/src/lib.rs
use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
    sysvar::{rent::Rent, Sysvar},
};

// FileInfo struct'ına eksik alanlar eklendi
#[derive(BorshSerialize, BorshDeserialize, PartialEq, Debug)]
pub struct FileInfo {
    pub arweave_hash: String,            // Arweave Hash
    pub file_name: String,               // Dosya adı
    pub file_size: u64,                  // Dosya boyutu
    pub file_type: String,               // Dosya tipi
    pub uploader: Pubkey,                // Yükleyen
    pub authorized_viewers: Vec<Pubkey>, // İzin verilenler
    pub timestamp: i64,                  // Yükleme zamanı
}

#[derive(BorshSerialize, BorshDeserialize, PartialEq, Debug)]
pub struct FileAccount {
    pub is_initialized: bool,
    pub file_info: FileInfo,
}

// Hesap oluşturma için varsayılan değerler.
impl FileAccount {
    pub fn new(file_info: FileInfo) -> Self {
        Self {
            is_initialized: true,
            file_info,
        }
    }
}

entrypoint!(process_instruction);
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();

    let file_account_info = next_account_info(accounts_iter)?;
    let uploader_info = next_account_info(accounts_iter)?;

    // Hesapların uygunluğunu kontrol et
    if !uploader_info.is_signer {
        return Err(ProgramError::MissingRequiredSignature);
    }

    if file_account_info.owner != program_id {
        return Err(ProgramError::IncorrectProgramId);
    }

    // Rent kontrolü
    let rent = &Rent::from_account_info(next_account_info(accounts_iter)?)?;
    if !rent.is_exempt(file_account_info.lamports(), file_account_info.data_len()) {
        return Err(ProgramError::AccountNotRentExempt);
    }

    // Borsh ile verileri deserialize et
    let file_info = FileInfo::try_from_slice(instruction_data)?;
    let mut file_account = FileAccount::try_from_slice(&file_account_info.data.borrow())?;

    // Hesap başlatma kontrolü
    if file_account.is_initialized {
        return Err(ProgramError::AccountAlreadyInitialized);
    }

    file_account = FileAccount::new(file_info);
    file_account.serialize(&mut &mut file_account_info.data.borrow_mut()[..])?;
    msg!("File hash registered: {:?}", file_account.file_info);

    Ok(())
}
