This is a minimal Auth flow to demonstrate the TXE issue. Different variation of public and private Auth was used as discussed in Discord dev.

1- Compile
```bash
bash compile.sh
```

2- Test
```js
yarn test:router
``` 

## Produces:
```
Testing test::test_add_liquidity::test_add_liquidity ... FAIL
Failed calling external resolver. ErrorObject { code: ServerError(-32702), message: "Assertion failed: unauthorized 'true, authorized'", data: None }
```# aztec-auth-issue
