use crate::RouterV3;
use crate::test::utils;
use dep::aztec::oracle::random::random;
use dep::factory::FactoryV3;
use dep::token::Token;
use aztec::authwit::auth::{
    assert_current_call_valid_authwit, assert_current_call_valid_authwit_public,
    compute_authwit_nullifier,
};
use aztec::test::helpers::authwit::add_private_authwit_from_call_interface;
use aztec::test::helpers::authwit::add_public_authwit_from_call_interface;

#[test]
unconstrained fn test_add_liquidity() {
    // Setup without account contracts. We are not using authwits here, so dummy accounts are enough
    let (env, token_contract_address_lp, token_contract_address_a, token_contract_address_b, factoryV3_contract_address, routerV3_contract_address, owner, recipient) =
        utils::setup(/* with_account_contracts */ true);

    let tokenA = token_contract_address_a;
    let tokenB = token_contract_address_b;
    let fee = 500;
    let recipient = recipient;
    let nonce = 0;
    let amount0Desired = 100;
    let amount1Desired = 20;

    println("Preparing Auth");
    // AUTH
    let public_transfer_in_private_call_interface0 = Token::at(tokenA).transfer_in_public(
        recipient,
        factoryV3_contract_address,
        amount0Desired as u128,
        nonce,
    );

    let public_transfer_in_private_call_interface1 = Token::at(tokenB).transfer_in_public(
        recipient,
        factoryV3_contract_address,
        amount1Desired as u128,
        nonce,
    );

    add_public_authwit_from_call_interface(
        *env,
        recipient, //on behalf
        factoryV3_contract_address, //caller
        public_transfer_in_private_call_interface0,
    );

    add_public_authwit_from_call_interface(
        *env,
        recipient, //on behalf
        factoryV3_contract_address, //caller
        public_transfer_in_private_call_interface1,
    );
    println("Minting LP");

    let mint_private_call_interface = RouterV3::at(routerV3_contract_address)._mint_private(
        tokenA,
        tokenB,
        fee,
        nonce,
        recipient,
        owner,
        nonce
    );
    add_private_authwit_from_call_interface(
        recipient,
        routerV3_contract_address,
        mint_private_call_interface,
    );

    env.call_private(recipient, mint_private_call_interface);
    println("Minted Lp in private");
}
