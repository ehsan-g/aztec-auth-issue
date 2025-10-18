#!/bin/bash

cd packages/token && RUST_BACKTRACE=1 aztec-nargo compile && aztec-postprocess-contract && rm -rf ./codegenCache.json  && aztec codegen target --outdir src/artifacts
wait
cd ../../

cd packages/factory && RUST_BACKTRACE=1 aztec-nargo compile && aztec-postprocess-contract && rm -rf ./codegenCache.json  && aztec codegen target --outdir src/artifacts
wait
cd ../../

cd packages/router && RUST_BACKTRACE=1 aztec-nargo compile && aztec-postprocess-contract && rm -rf ./codegenCache.json  && aztec codegen target --outdir src/artifacts
wait