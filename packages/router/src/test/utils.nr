use crate::RouterV3;
use dep::factory::FactoryV3;
use dep::token::Token;
use aztec::{
    protocol_types::address::AztecAddress, test::helpers::test_environment::TestEnvironment,
};

pub unconstrained fn setup(
    with_account_contracts: bool,
    ) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    // Setup env, generate keys
    let mut env = TestEnvironment::new();
    let (owner, recipient) = if with_account_contracts {
        let owner = env.create_contract_account();
        let recipient = env.create_contract_account();
        (owner, recipient)
    } else {
        let owner = env.create_light_account();
        let recipient = env.create_light_account();

        (owner, recipient)
    };

    // Deploy LP
    let initializer_call_interface_lp = Token::interface().constructor(
        owner,
        "LPToken000000000000000000000000",
        "LP00000000000000000000000000000",
        18,
    );

    let lp_token_contract_address = env.deploy("../token/@token_contract/Token").with_public_initializer(
        owner,
        initializer_call_interface_lp,
    );

    // Deploy tokenA
    let initializer_call_interface_a = Token::interface().constructor(
        owner,
        "AAToken000000000000000000000000",
        "AA00000000000000000000000000000",
        18,
    );
    let token_contract_address_a = env.deploy(("../token/@token_contract/Token")).with_public_initializer(
        owner,
        initializer_call_interface_a,
    );

    // Deploy tokenB
    let initializer_call_interface_b = Token::interface().constructor(
        owner,
        "BBToken000000000000000000000000",
        "BB00000000000000000000000000000",
        18,
    );
    let token_contract_address_b = env.deploy("../token/@token_contract/Token").with_public_initializer(
        owner,
        initializer_call_interface_b,
    );

    // // Deploy Factory
    let my_public_initializer_call_interface1 =
        FactoryV3::interface().constructor(owner, lp_token_contract_address, 10);
    let factory_contract_address = env
        .deploy("../factory/@factory_contract/FactoryV3")
        .with_public_initializer(owner, my_public_initializer_call_interface1);

    // Deploy Router
    let my_public_initializer_call_interface2 =
        RouterV3::interface().constructor(factory_contract_address);
    let router_contract_address = env.deploy("RouterV3").with_public_initializer(
        owner,
        my_public_initializer_call_interface2,
    );
    (
        &mut env, lp_token_contract_address, token_contract_address_a, token_contract_address_b,
        factory_contract_address, router_contract_address, owner, recipient,
    )

}
