use dep::aztec::protocol_types::{address::AztecAddress, traits::{Deserialize, Packable, Serialize}};
use dep::bignum::{BigNum, bignum::to_field, U256};

#[derive(Deserialize, Packable, Serialize)]
pub struct Pair {
    pub token0: AztecAddress,
    pub token1: AztecAddress,
    pub fee: u32,
    pub tickSpacing: i32,
}

impl Pair {
    pub fn mint(&mut self) -> (Field, Field) {
        (22, 33)
    }
}
