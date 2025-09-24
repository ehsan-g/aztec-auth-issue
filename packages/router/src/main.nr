mod test;
use dep::aztec::macros::aztec;
use dep::aztec::oracle::debug_log::{ debug_log, debug_log_format };

#[aztec]
contract RouterV3 {
    use dep::aztec::oracle::debug_log::{ debug_log, debug_log_format };
    use dep::aztec::{
        context::{PrivateCallInterface, PrivateContext},
        prelude::{AztecAddress, Map, PublicMutable},
    };
    use dep::aztec::macros::{
        events::event,
        functions::{initializer, internal, private, public, view},
        storage::storage,
    };
    use aztec::protocol_types::traits::ToField;

    use aztec::authwit::auth::{
        assert_current_call_valid_authwit, assert_current_call_valid_authwit_public,
        compute_authwit_nullifier,
    };
    use dep::factory::FactoryV3;

    #[storage]
    struct Storage<Context> {
        factory: PublicMutable<AztecAddress, Context>,
        liquidityToBeMinted: Map<AztecAddress, Map<AztecAddress, Map<u32, Map<AztecAddress, PublicMutable<u128, Context>, Context>, Context>, Context>, Context>,// tokenA => tokenB => fee => user => to be Minted - we add this to help with Gas
    }

    #[public]
    #[initializer]
    fn constructor(_factory: AztecAddress) {
        storage.factory.write(_factory);
    }

    #[private]
    fn _mint_private(
        tokenA: AztecAddress,
        tokenB: AztecAddress,
        fee: Field, 
        nonce: Field,
        recipient: AztecAddress,
    ) {
        if (!recipient.eq(context.msg_sender())) {
            assert_current_call_valid_authwit(&mut context, recipient);
        } else {
            assert(nonce == 0, "invalid nonce");
        }

        let _ = RouterV3::at(context.this_address())
            ._mint_public(
                tokenA,
                tokenB,
                fee,
                recipient,
                nonce,
            )
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
            ._mint(
                tokenA,
                tokenB,
                fee as u32,
                recipient,
                nonce
            )
            .call(&mut context);
        let amount0 = return_values[0];
        let amount1 = return_values[1];
  
        [amount0, amount1]
    }

}
