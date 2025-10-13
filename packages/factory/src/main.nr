mod pairV3;

use dep::aztec::macros::aztec;

#[aztec]
pub contract FactoryV3 {
    use crate::pairV3::Pair;
    use dep::aztec::{
        context::{PrivateCallInterface, PrivateContext, PublicContext},
        event::event_interface::{emit_event_in_private, MessageDelivery},
        macros::{
            events::event,
            functions::{authorize_once, initializer, internal, private, public, utility, view},
            storage::storage,
        },
        messages::logs::note::{encode_and_encrypt_note, encode_and_encrypt_note_unconstrained},
        state_vars::{Map, PublicImmutable, PublicMutable},
    };
    use dep::aztec::oracle::debug_log::{debug_log, debug_log_format};
    use dep::aztec::protocol_types::address::AztecAddress;
    use dep::aztec::protocol_types::traits::{FromField, ToField};
    use dep::bignum::{BigNum, bignum::to_field, U256};
    use dep::token::Token;
    use std::hash::pedersen_hash;
    use std::ops::{Add, Div, Mul, Neg, Sub};

    #[storage]
    struct Storage<Context> {
        admin: PublicMutable<AztecAddress, Context>, // DAO address
        pools: Map<AztecAddress, Map<AztecAddress, Map<u32, PublicMutable<Pair, Context>, Context>, Context>, Context>, // tokenA => tokenB => fee = pool
        // if tickSpacing is 10, only multiples of 10 will be valid as tick indexes (10, 20, 5000, 5010, but not 8, 12, 5001, etc.).
        feeAmountTickSpacing: Map<Field, PublicMutable<Field, Context>, Context>, // uint24, int24
        approved_lps: Map<AztecAddress, Map<Field, PublicMutable<bool, Context>, Context>, Context>,
    }

    #[public]
    #[initializer]
    fn constructor(
        admin: AztecAddress,
        lpToken: AztecAddress,
        lp_contract_id: Field,
    ) {
        storage.admin.write(admin);
        storage.approved_lps.at(lpToken).at(lp_contract_id).write(true);
        storage.feeAmountTickSpacing.at(10000).write(200);
    }

    #[public]
    fn _mint(
        tokenA: AztecAddress,
        tokenB: AztecAddress,
        fee: u32, // uint24,
        recipient: AztecAddress, //address
        nonce: Field,
    ) -> [Field; 2] {
        let balance0Before =
            Token::at(tokenA).get_balance_of_public(context.this_address()).call(&mut context);
        let balance1Before =
            Token::at(tokenB).get_balance_of_public(context.this_address()).call(&mut context);

        let pool_storage = storage.pools.at(tokenA).at(tokenB).at(fee as u32);
        let mut pool = pool_storage.read();
        let (amount0, amount1): (Field, Field) = pool.mint();

        if (amount0 as u128 > 0 as u128) {
            let _res = Token::at(tokenA)
                .transfer_in_public(recipient, context.this_address(), (amount0) as u128, nonce)
                .call(&mut context);
        }

        if (amount1 as u128 > 0 as u128) {
            let _res = Token::at(tokenB)
                .transfer_in_public(recipient, context.this_address(), (amount1) as u128, nonce)
                .call(&mut context);
        }

        let balance0Now =
            Token::at(tokenA).get_balance_of_public(context.this_address()).call(&mut context);
        let balance1Now =
            Token::at(tokenB).get_balance_of_public(context.this_address()).call(&mut context);

        assert(amount0 == 0, "Random assertion!");

        [amount0, amount1]
    }
}
