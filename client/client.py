import json
from web3 import Web3, utils
import sqlite3
# Connect to a local Ethereum node (Ganache)
web3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

lt_truffle_file = json.load(open('./build/contracts/LandTitle.json'))

lt_abi = lt_truffle_file['abi']
# get address from network in trufleFile, it is the last address in the dictionary
latest_timestamp = max(lt_truffle_file["networks"].keys())
lt_contract_address = lt_truffle_file["networks"][latest_timestamp]["address"]

# Load the contract
lt_contract = web3.eth.contract(address=lt_contract_address, abi=lt_abi)

escrow_truffle_file = json.load(open('./build/contracts/Escrow.json'))
escrow_abi = escrow_truffle_file['abi']
escrow_contract_address = escrow_truffle_file['networks']['1337']['address']
escrow_contract = web3.eth.contract(address=escrow_contract_address, abi=escrow_abi)

def input_data():
    property_details = {}
    property_details['owner'] = input("Enter the name of the property owner: ")
    property_details['address'] = input("Enter the address of the property: ")
    property_details['area'] = input("Enter the area of the property in square feet: ")
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

    # Convert data to hash string
    hash_data = web3.solidity_keccak(['string'], [json.dumps(data)])

    # Get the account address
    account_address = web3.eth.account.from_key(private_key).address
    print("account: " + account_address)

    # Build the transaction
    txn_dict = lt_contract.functions.registerTitle(hash_data.hex()).build_transaction({
        'chainId': 1337, # Replace with your network's chainId
        'gas': 500000,
        'gasPrice': web3.to_wei('20', 'gwei'),
        'nonce': web3.eth.get_transaction_count(account_address),
    })

    # # Sign the transaction
    signed_txn = web3.eth.account.sign_transaction(txn_dict, private_key)

    # # Send the transaction
    tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)

    # # Wait for transaction to be mined and get the transaction receipt
    receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    logs = lt_contract.events.Transfer().process_receipt(receipt)

    # Extract the token ID from the logs
    token_id = logs[0]['args']['tokenId']
    store_data_in_db(token_id, data)
    print(f"Newly minted token ID: {token_id}")

    return receipt


def transfer_title(token_id, to_address, from_private_key):
    from_account_address = web3.eth.account.from_key(from_private_key).address
    oracle_address = web3.eth.accounts[2]

    # set the contract address
    # tx_contract_hash = escrow_contract.functions.setLandTitleContract(contract_address).build_transaction({
    #     'chainId': 1337,
    #     'gas': 500000,
    #     'gasPrice': web3.to_wei('20', 'gwei'),
    #     'nonce': web3.eth.get_transaction_count(from_account_address),
    #     'from': from_account_address
    #     })
    # tx_hash = web3.eth.send_transaction(tx_contract_hash)
    # receipt = web3.eth.wait_for_transaction_receipt(tx_hash)

    # print(receipt)

    # tx_oracle_hash = escrow_contract.functions.setOracle(oracle_address).build_transaction({
    #     'chainId': 1337,
    #     'gas': 500000,
    #     'gasPrice': web3.to_wei('20', 'gwei'),
    #     'nonce': web3.eth.get_transaction_count(from_account_address),
    #     'from': from_account_address})

    # tx_hash = web3.eth.send_transaction(tx_oracle_hash)
    # receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    # print(receipt)

    # release
    release(token_id, from_account_address, to_address)

    # redeem
    redeem(token_id, to_address)

    # tx_check_hash = escrow_contract.functions.emitCheckPayment().build_transaction({
    #     'chainId': 1337,
    #     'gas': 500000,
    #     'gasPrice': web3.to_wei('20', 'gwei'),
    #     'nonce': web3.eth.get_transaction_count(from_account_address),
    #     'from': from_account_address})

    # tx_hash = web3.eth.send_transaction(tx_check_hash)
    # receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    # print(receipt)

def release(token_id, from_address, to_address):
    oracle_address = web3.eth.accounts[2]
    # make sure lt contract address is correct
    txn_dict = escrow_contract.functions.release(web3.to_checksum_address(to_address), int(token_id), lt_contract_address, web3.to_checksum_address(oracle_address)).build_transaction({
        'chainId': 1337,
        'gas': 500000,
        'gasPrice': web3.to_wei('20', 'gwei'),
        'nonce': web3.eth.get_transaction_count(from_address),
        'from': from_address
    })

    tx_hash = web3.eth.send_transaction(txn_dict)
    receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    print(receipt)
    print("Token " + str(token_id) + " released by " + from_address + " to " + to_address)

def redeem(token_id, to_address):

    txn_dict = escrow_contract.functions.redeem(int(token_id)).build_transaction({
        'chainId': 1337,
        'gas': 500000,
        'gasPrice': web3.to_wei('20', 'gwei'),
        'nonce': web3.eth.get_transaction_count(to_address),
        'from': to_address
    })

    tx_hash = web3.eth.send_transaction(txn_dict)
    receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    print(receipt)
    print("Token " + str(token_id) + " redeemed by " + to_address)

def get_title(token_id):

    response = lt_contract.functions.getTitleDetails(token_id).call()
    print(response)

def verify_title(token_id, account_address):
    # txn_dict = lt_contract.functions.verifyTitle(int(token_id)).build_transaction({
    #     'chainId': 1337,
    #     'gas': 500000,
    #     'gasPrice': web3.to_wei('20', 'gwei'),
    #     'nonce': web3.eth.get_transaction_count(account_address),
    #     'from': account_address
    # })

    # tx_hash = web3.eth.send_transaction(txn_dict)
    # receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    # print(receipt)

    response = lt_contract.functions.verifyTitle(token_id).call({'from': account_address})
    print(response)


if __name__ == "__main__":
    #account 0
    sender_address = web3.eth.accounts[0]

    #account 0
    #######################################
    # replace with the account0 private key in the local ganache
    ########################################
    sender_private_key = "0x7eb43f72f4b8e11613e872e773643127ead0072623ba9c0e3a7628b8487d9fa1"

    while True:
        command = input("Enter command: ")
        if command == "register":
            register_title(sender_private_key)
        elif command == "transfer":
            token_id = input("Enter token id: ")
            receiver_address = input("Enter receiver address: ")
            transfer_title(int(token_id), receiver_address, sender_private_key)
        elif command == "verify":
            token_id = input("Enter token id: ")
            account_address = input("Enter account address: ")
            verify_title(int(token_id), account_address)
        elif command == "get":
            token_id = input("Enter token id: ")
            get_title(int(token_id))