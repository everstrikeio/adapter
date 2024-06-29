# Everstrike Adapter

Everstrike Adapter.

Connect with Everstrike on social media:

- [twitter.com/everstrike_io](https://twitter.com/everstrike_io)
- [t.me/everstrike_io](https://t.me/everstrike_io)

## Requirements

- Docker `v20.10.8`
- 0.01 Amoy MATIC

## Local Setup

1. Specify your private key in hardhat.config.local.js and in client/node.js

```javascript
const PRIVATE_KEY = "<YOUR_PRIVATE_KEY>";
```

The default network is Polygon Amoy. You will need Amoy MATIC to run this adapter. Get Amoy MATIC here: [https://faucet.polygon.technology/](https://faucet.polygon.technology/)

2. Make sure you have Docker installed

```bash
docker version;
```

3. Build and run Docker image

```bash
bash build.sh;
```

4. Verify that container is running

```bash
docker logs adapter;
# Should see an output of wallet addresses and private keys
```

5. Compile contract

```bash
bash compile.sh;
```

6. Deploy contract

```bash
bash deploy.sh
```

7. Run our client (`client/node.js`) against the deployed contract

```bash
bash run.sh # this runs our client/node.js file
```

Voilà!

Don't forget to delete your container when you're done.

```bash
docker rm -f adapter;
```

## Copy local files to Docker container

Sync your Docker container with your local files

```bash
bash cp.sh
```

## Verify deployed contract

Change the 0x0000000000000000000000000000000000000000 address in the package.json verify:local task to the address of your newly deployed contract, and run the following:

```bash
bash verify.sh
```

For this to work, you will need to specify your Etherscan/Oklink API key in hardhat.config.local.js.

## Deploy Everstrike USDT

Deploy a new instance of Everstrike USDT, and grant yourself all of the supply

```bash
bash deploy_token.sh
```

## Deploy utility libraries

Deploy utility libraries (required for version 1.0.1 and up)

```bash
bash deploy_libraries.sh
```

## License

MIT License

Copyright (c) 2023-present Everstrike Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
