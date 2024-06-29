docker exec -it adapter sh -c 'export "CONTRACT_ADDRESS=$(cat .contract)" && export "WALLET_ADDRESS=$(cat .wallet)" && node client/web3.js'
