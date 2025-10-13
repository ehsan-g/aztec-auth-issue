mod test;

use dep::aztec::macros::aztec;

#[aztec]
contract RouterV3 {
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
    use dep::aztec::protocol_types::address::AztecAddress;
    use dep::aztec::protocol_types::traits::{FromField, ToField};
    use dep::factory::FactoryV3;
    use aztec::authwit::auth::{
        assert_current_call_valid_authwit, assert_current_call_valid_authwit_public,
        compute_authwit_nullifier,
    };

    #[storage]
    struct Storage<Context> {
        factory: PublicMutable<AztecAddress, Context>,
        liquidityToBeMinted: Map<AztecAddress, Map<AztecAddress, Map<u32, Map<AztecAddress, PublicMutable<u128, Context>, Context>, Context>, Context>, Context>, // tokenA => tokenB => fee => user => to be Minted - we add this to help with Gas
    }

    #[public]
    #[initializer]
    fn constructor(_factory: AztecAddress) {
        storage.factory.write(_factory);
    }

    #[authorize_once("from", "authwit_nonce")]
    #[private]
    fn _mint_private(
        tokenA: AztecAddress,
        tokenB: AztecAddress,
        fee: Field,
        nonce: Field,
        from: AztecAddress,
        recipient: AztecAddress,
        authwit_nonce: Field,
    ) {
        let _ = RouterV3::at(context.this_address())
            ._mint_public(tokenA, tokenB, fee, recipient, nonce)
            .enqueue(&mut context);
    }

    #[public]
    #[internal]
    fn _mint_public(
        tokenA: AztecAddress,
        tokenB: AztecAddress,
        fee: Field, // uint24
        recipient: AztecAddress,
        nonce: Field,
    ) -> pub [Field; 2] {
        let return_values = FactoryV3::at(storage.factory.read())
            ._mint(tokenA, tokenB, fee as u32, recipient, nonce)
            .call(&mut context);
        let amount0 = return_values[0];
        let amount1 = return_values[1];

        [amount0, amount1]
    }

}
