import sys
from web3 import Web3
from json import dumps
from time import sleep
import json

# Replace with the actual address of the Ethereum node
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Replace with the private key of the oracle account
private_key = '0xaefcaad212aba1ac9c96f94f5dcef495467fb745179976fbe31711bc559fedcf'

truffleFile = json.load(open('./build/contracts/Escrow.json'))
contract_abi = truffleFile['abi']
# latest_timestamp = max(truffleFile["networks"].keys())
# contract_address = truffleFile["networks"][latest_timestamp]["address"]
contract_address = "0x1e16c152937A0d98f8a87ff03E24e48eC6f32342"

def handle_payment():
    escrow_contract = w3.eth.contract(address=contract_address, abi=contract_abi)
    transaction = escrow_contract.functions.paymentReceived().buildTransaction({
        'gas': 2000000,
        'gasPrice': w3.toWei('40', 'gwei'),
        'nonce': w3.eth.getTransactionCount(w3.eth.defaultAccount),
    })

    signed_transaction = w3.eth.account.signTransaction(transaction, private_key)
    tx_hash = w3.eth.sendRawTransaction(signed_transaction.rawTransaction)
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    print(f"Transaction Hash: {tx_receipt.transactionHash.hex()}")


if __name__ == '__main__':
    # event_filter = w3.eth.contract(address=contract_address, abi=contract_abi).events.CheckPayment.create_filter(fromBlock='latest', topics=[Web3.sha3(text='CheckPayment')])
    event_filter = w3.eth.contract(address=contract_address, abi=contract_abi).events.CheckPayment.create_filter(fromBlock='latest', topics=[w3.keccak(text='CheckPayment')])

    while True:
        command = input("Payment complete (true or false): ")
        value = False
        if command == "true":
            value = True

        for event in event_filter.get_new_entries():
            if value == True:
                handle_payment(event, value)
        sleep(2)  # Check for new events every 2 seconds
