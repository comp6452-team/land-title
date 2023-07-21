import json
from web3 import Web3

# Connect to a local Ethereum node (Ganache)
web3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

truffleFile = json.load(open('./build/contracts/LandTitle.json'))
contract_abi = truffleFile['abi']

# Contract address
contract_address = "0x274C9565b080DB5A2F418a03e3072C6DACbe1Dfe"

# Load the contract
contract = web3.eth.contract(address=contract_address, abi=contract_abi)

response = contract.functions.registerTitle(1, "abc")
print(response)

# # Fetch the latest block
latest_block = web3.eth.get_block('latest')
print(latest_block)
