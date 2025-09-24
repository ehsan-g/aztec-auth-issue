use crate::RouterV3;
use dep::token::Token;
use dep::factory::FactoryV3;
use dep::uint_note::uint_note::UintNote;
use aztec::{
    oracle::{execution::{get_block_number, get_contract_address}, storage::storage_read},
    prelude::AztecAddress,
    protocol_types::storage::map::derive_storage_slot_in_map,
    test::helpers::{cheatcodes, test_environment::TestEnvironment},
};


pub unconstrained fn setup(
    with_account_contracts: bool,
    )     -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress, AztecAddress,AztecAddress, AztecAddress) {
    // Setup env, generate keys
     let mut env = TestEnvironment::new();
    let (owner, recipient) = if with_account_contracts {
        let owner = env.create_account_contract(1);
        let recipient = env.create_account_contract(2);
        (owner, recipient)
    } else {
        let owner = env.create_account(1);
        let recipient = env.create_account(2);
        (owner, recipient)
    };

    // Start the test in the account contract address
    env.impersonate(owner);


    // Deploy LP
    let initializer_call_interface_lp = Token::interface().constructor(
        owner,
        "LPToken000000000000000000000000",
        "LP00000000000000000000000000000",
        18,
    );

    let token_contract_lp = env
        .deploy("../token/@token_contract", "Token")
        .with_public_void_initializer(owner,initializer_call_interface_lp);
    let lp_token_contract_address = token_contract_lp.to_address();
    env.advance_block_by(1);

    // Deploy tokenA
    let initializer_call_interface_a = Token::interface().constructor(
        owner,
        "AAToken000000000000000000000000",
        "AA00000000000000000000000000000",
        18,
    );
    let token_contract_a = env
        .deploy("../token/@token_contract", "Token")
        .with_public_void_initializer(owner,initializer_call_interface_a);
    let token_contract_address_a = token_contract_a.to_address();
    env.advance_block_by(1);

    // Deploy tokenB
    let initializer_call_interface_b = Token::interface().constructor(
        owner,
        "BBToken000000000000000000000000",
        "BB00000000000000000000000000000",
        18,
    );
    let token_contract_b = env
        .deploy("../token/@token_contract", "Token")
        .with_public_void_initializer(owner,initializer_call_interface_b);
    let token_contract_address_b = token_contract_b.to_address();
    env.advance_block_by(1);

    // Deploy Factory
    let my_public_initializer_call_interface = FactoryV3::interface().constructor(
        owner,
        lp_token_contract_address,
        10,
        token_contract_address_a,
        token_contract_address_b,
        600
    );
    let factory_contract =
        env.deploy("../factory/@factory_contract","FactoryV3").with_public_void_initializer(owner,my_public_initializer_call_interface);
    let factory_contract_address = factory_contract.to_address();
    env.advance_block_by(1);

     // Deploy Router
    let router_initializer_call_interface = RouterV3::interface().constructor(
        factory_contract_address
    );
    let router_contract =
        env.deploy_self("RouterV3").with_public_void_initializer(owner,router_initializer_call_interface);
    let router_contract_address = router_contract.to_address();
    env.advance_block_by(1);
    (
        &mut env, lp_token_contract_address, token_contract_address_a, token_contract_address_b,
        factory_contract_address, router_contract_address,owner, recipient,
    )
}

