from web3 import Web3

# Connect to a local Ethereum node (Ganache)
web3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

contract_abi = [

]

# Contract address
contract_address = "0x123456789..."

# Load the contract
contract = web3.eth.contract(address=contract_address, abi=contract_abi)
