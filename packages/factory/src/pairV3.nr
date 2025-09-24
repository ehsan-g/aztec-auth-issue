use dep::aztec::{
    prelude::AztecAddress,
    protocol_types::traits::{Deserialize, Packable, Serialize, ToField},
};
use dep::bignum::{BigNum, bignum::to_field, U256};

#[derive(Deserialize, Packable, Serialize)]
pub struct Pair {
    token0: AztecAddress,
    token1: AztecAddress,
    fee: u32,
    tickSpacing: i32,
}

impl Pair {
    pub fn mint(&mut self) -> (Field, Field) {
        (22, 33)
    }
}
