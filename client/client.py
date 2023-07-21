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
contract_address = "0x32A2c37838456cDBFff6283DD9dDc7F0E621dE4A"

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
        'gas': 700000,
        'gasPrice': web3.to_wei('30', 'gwei'),
        'nonce': nonce,
    })
    # # Sign the transaction
    signed_txn = web3.eth.account.sign_transaction(txn_dict, private_key)

    # # Send the transaction
    tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)

    # # Wait for transaction to be mined and get the transaction receipt
    receipt = web3.eth.wait_for_transaction_receipt(tx_hash)

    print(f"Transaction receipt: {receipt}")

    return receipt


def transfer_title(token_id, to_address, private_key):
    contract.functions.transferTitle()
def get_title(token_id):
    contract.functions.getTitle()

if __name__ == "__main__":
    network_id = web3.net.version
    print(network_id)
    sender_address = web3.eth.accounts[0]
    private_key = "0x938ac5df84578a8d43734bce5ee711f2aefbfb8dff8e2bea27bedb809f704577"
    receiver_address = web3.eth.accounts[1]
    while True:
        command = input("Enter command: ")
        if command == "register":
            register_title(private_key)

    print("sender address: " + sender_address + "\nreceiver_address: " + receiver_address)
