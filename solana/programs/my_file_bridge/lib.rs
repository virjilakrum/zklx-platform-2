// wormhole-scaffolding-main/solana/programs/file_registry/src/lib.rs
use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    pubkey::Pubkey,
    sysvar::{rent::Rent, Sysvar},
};

#[derive(BorshSerialize, BorshDeserialize, PartialEq, Debug)]
pub struct FileInfo {
    pub arweave_hash: String,
    pub uploader: Pubkey,
    pub authorized_viewers: Vec<Pubkey>,
}

#[derive(BorshSerialize, BorshDeserialize, PartialEq, Debug)]
pub struct FileAccount {
    pub is_initialized: bool,
    pub file_info: FileInfo,
}

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

    let rent = Rent::get()?;
    if !rent.is_exempt(file_account_info.lamports(), file_account_info.data_len()) {
        return Err(ProgramError::AccountNotRentExempt);
    }

    let file_info = FileInfo::try_from_slice(instruction_data)?;

    let mut file_account = FileAccount::try_from_slice(&file_account_info.data.borrow())?;
    if file_account.is_initialized {
        return Err(ProgramError::AccountAlreadyInitialized);
    }

    if uploader_info.is_signer {
        file_account = FileAccount::new(file_info);
        file_account.serialize(&mut &mut file_account_info.data.borrow_mut()[..])?;
        msg!("File hash registered: {:?}", file_account.file_info);
    } else {
        return Err(ProgramError::MissingRequiredSignature);
    }

    Ok(())
}
