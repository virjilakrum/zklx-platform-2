#!/bin/bash

# wormhole-scaffolding-main/evm/forge-scripts/deploy_my_file_bridge.sh

forge create --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> src/MyFileBridge.sol:MyFileBridge
