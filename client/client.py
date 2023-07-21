import json
from web3 import Web3

# Connect to a local Ethereum node (Ganache)
web3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

truffleFile = json.load(open('./build/contracts/LandTitle.json'))

contract_abi = truffleFile['abi']
contract_address = "0x274C9565b080DB5A2F418a03e3072C6DACbe1Dfe"

# Load the contract
contract = web3.eth.contract(address=contract_address, abi=contract_abi)

def register_title(token_id, data_hash, private_key):
    contract.functions.registerTitle()

if __name__ == "__main__":
    sender_address = web3.eth.accounts[0]
    receiver_address = web3.eth.accounts[1]

    print("sender address: " + sender_address + "\nreceiver_address: " + receiver_address)
