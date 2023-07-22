import json
from web3 import Web3
import sqlite3
# Connect to a local Ethereum node (Ganache)
web3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

truffleFile = json.load(open('./build/contracts/LandTitle.json'))

contract_abi = truffleFile['abi']
# get address from network in trufleFile, it is the last address in the dictionary
latest_timestamp = max(truffleFile["networks"].keys())
contract_address = truffleFile["networks"][latest_timestamp]["address"]

# Load the contract
contract = web3.eth.contract(address=contract_address, abi=contract_abi)
def input_data():
    property_details = {}
    property_details['owner'] = input("Enter the name of the property owner: ")
    property_details['address'] = input("Enter the address of the property: ")
    property_details['area'] = input("Enter the area of the property in square feet: ")
    # property_details['location'] = input("Enter the location of the property: ")
    return property_details

def store_data_in_db(token_id, property_details):


    conn = sqlite3.connect('database.db')  # This will create a new sqlite file if it doesn't exist
    cursor = conn.cursor()

    # Create a new table if it doesn't exist
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS properties(
            tokenId INTEGER PRIMARY KEY,
            owner TEXT,
            address TEXT,
            area TEXT
        )
    ''')

    # Insert the property details
    cursor.execute('''
        INSERT INTO properties(tokenId, owner, address, area) VALUES(?,?,?,?)
    ''', (token_id, property_details['owner'], property_details['address'], property_details['area']))

    conn.commit()
    conn.close()

def register_title(private_key):
    data = input_data()
    # data = {
    #     "name": "randwick",
    #     "price": 250
    # }
    # Convert data to hash string
    hash_data = web3.solidity_keccak(['string'], [json.dumps(data)])

    # Get the account address
    account_address = web3.eth.account.from_key(private_key).address
    print("account: " + account_address)

    # Build the transaction
    txn_dict = contract.functions.registerTitle(hash_data.hex()).build_transaction({
        'chainId': 1337, # Replace with your network's chainId
        'gas': 500000,
        'gasPrice': web3.to_wei('20', 'gwei'),
        'nonce': web3.eth.get_transaction_count(account_address),
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
    store_data_in_db(token_id, data)
    print(f"Newly minted token ID: {token_id}")
    # print(f"Transaction receipt: {receipt}")

    return receipt


def transfer_title(token_id, to_address, from_private_key):
    # Get the account address from the private key
    account_address = web3.eth.account.from_key(from_private_key).address

    nonce = web3.eth.get_transaction_count(account_address)
    txn_dict = contract.functions.transferTitle(int(token_id), web3.to_checksum_address(to_address)).build_transaction({
        'chainId': 1337, # Replace with your network's chainId
        'gas': 500000,
        'gasPrice': web3.to_wei('20', 'gwei'),
        'nonce': nonce,
    })

    # Sign the transaction
    signed_txn = web3.eth.account.sign_transaction(txn_dict, from_private_key)

    # Send the transaction
    tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)

    # Wait for transaction to be mined and get the transaction receipt
    receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    from_address = receipt['from']
    to_address = receipt['to']
    print (f"Transfer from {from_address} to {to_address} successful")
    # print(f"Transaction receipt: {receipt}")

    return receipt

def get_title(token_id):
    response = contract.functions.getTitleDetails(token_id).call()
    print(response)

def verify_title(token_id, account_address):
    # account_address = web3.eth.account.from_key(private_key).address
    response = contract.functions.verifyTitle(token_id).call({'from': account_address})
    print(response)


if __name__ == "__main__":
    # network_id = web3.net.version
    # print(network_id)
    #account 0
    sender_address = web3.eth.accounts[0]

    #account 0
    # replace with the account0 private key
    private_key = "0x7eb43f72f4b8e11613e872e773643127ead0072623ba9c0e3a7628b8487d9fa1"

    #account 1
    receiver_address = web3.eth.accounts[1]
    print(receiver_address)
    while True:
        command = input("Enter command: ")
        if command == "register":
            register_title(private_key)
        elif command == "transfer":
            token_id = input("Enter token id: ")
            to_address = input("Enter receiver address: ")
            transfer_title(token_id, to_address, private_key)
            # to_private_key = "0x96b29ae05803ef66b8af63fb1509e98b4911aa276c28ce14d090de4a2fdee477"
            # transfer_title(token_id, receiver_address, private_key)
        elif command == "verify":
            token_id = input("Enter token id: ")
            account_address = input("Enter account address: ")
            verify_title(int(token_id), account_address)
        elif command == "get":
            token_id = input("Enter token id: ")
            get_title(int(token_id))
    print("sender address: " + sender_address + "\nreceiver_address: " + receiver_address)