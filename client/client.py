import json
from web3 import Web3
from getpass import getpass
from eth_utils import address
from web3 import Web3
import os
# from solc import compile_standard, install_solc
from dotenv import load_dotenv

# Connect to a local Ethereum node (Ganache)
web3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

truffleFile = json.load(open('./build/contracts/LandTitle.json'))

contract_abi = truffleFile['abi']
# get address from network in trufleFile, it is the last address in the dictionary
latest_timestamp = max(truffleFile["networks"].keys())
contract_address = truffleFile["networks"][latest_timestamp]["address"]

# Load the contract
contract = web3.eth.contract(address=contract_address, abi=contract_abi)

def register_title(private_key):
    data = {
        "name": "randwick",
        "price": 250
    }
# Convert data to hash string
    hash_data = web3.solidity_keccak(['string'], [json.dumps(data)])


    # Get the account address
    account_address = web3.eth.account.from_key(private_key).address
    print(account_address)
    # Get the nonce
    nonce = web3.eth.get_transaction_count(account_address)

    # Build the transaction
    txn_dict = contract.functions.registerTitle(hash_data.hex()).build_transaction({
        'chainId': 1337, # Replace with your network's chainId
        'gas': 500000,
        'gasPrice': web3.to_wei('20', 'gwei'),
        'nonce': nonce,
    })
    # print(txn_dict)
    # # Sign the transaction
    signed_txn = web3.eth.account.sign_transaction(txn_dict, private_key)

    # # Send the transaction
    tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)

    # # Wait for transaction to be mined and get the transaction receipt
    receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    logs = contract.events.Transfer().process_receipt(receipt)

    # Extract the token ID from the logs
    token_id = logs[0]['args']['tokenId']

    print(f"Newly minted token ID: {token_id}")
    # print(f"Transaction receipt: {receipt}")

    return receipt


def transfer_title(token_id, to_address, private_key):
    
    nonce = web3.eth.get_transaction_count(account_address)
    contract.functions.transferTitle(token_id, to_address).build_transaction({
        'chainId': 1337, # Replace with your network's chainId
        'gas': 500000,
        'gasPrice': web3.to_wei('20', 'gwei'),
        'nonce': nonce,
    })

def get_title(token_id):
    contract.functions.getTitle()

if __name__ == "__main__":
    network_id = web3.net.version
    print(network_id)
    sender_address = web3.eth.accounts[0]
    private_key = "0x8283f51fefb4703d508f0aebc37dcbbdea8d5e7553f3f8a4ebcf179c8d94ee87"
    receiver_address = web3.eth.accounts[1]
    while True:
        command = input("Enter command: ")
        if command == "register":
            register_title(private_key)
        elif command == "transfer":
            token_id = input("Enter token id: ")
            transfer_title(token_id, receiver_address, private_key)
        elif command == "get":

            get_title(token_id)

    print("sender address: " + sender_address + "\nreceiver_address: " + receiver_address)
