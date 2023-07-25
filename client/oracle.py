from web3 import Web3
from time import sleep
import json

# Replace with the actual address of the Ethereum node
web3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Replace with the private key of the oracle account
private_key = '0xceb1d8bc2c141e448d3d31fb5671a1b03a552a8d5ec683ad9513aa8289b84a8b'

truffleFile = json.load(open('./build/contracts/Escrow.json'))
contract_abi = truffleFile['abi']
latest_timestamp = max(truffleFile["networks"].keys())
contract_address = truffleFile["networks"][latest_timestamp]["address"]

contract = web3.eth.contract(address=contract_address, abi=contract_abi)

oracle_address = "0xA1e77EC2f0ad59121DA812cd5be61E3CAc30F472"
# contract_address = "0x1e16c152937A0d98f8a87ff03E24e48eC6f32342"

def handle_payment():
    # escrow_contract = w3.eth.contract(address=contract_address, abi=contract_abi)
    txn_dict = contract.functions.paymentReceived().build_transaction({
        'chainId': 1337,
        'gas': 2000000,
        'gasPrice': web3.to_wei('40', 'gwei'),
        'nonce': web3.eth.get_transaction_count(oracle_address),
        'from': oracle_address
    })

    tx_hash = web3.eth.send_transaction(txn_dict)
    receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    # signed_transaction = w3.eth.account.sign_transaction(transaction, private_key)
    # tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    # tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    # print(f"Transaction Hash: {tx_receipt.transactionHash.hex()}")
    print("payment called")
    print(receipt)


if __name__ == '__main__':
    print(contract_address)

    while True:
        block = web3.eth.get_block('latest')
        for tx_hash in block.transactions:
            tx = web3.eth.get_transaction(tx_hash)
            if tx['to'] == contract_address:
                # print(f'Found interaction with WETH contract! {tx}') 
                input_data = tx['input']
                function_selector = input_data[:10]  # 4 bytes (8 characters) function selector
                if tx['input'] == '0xdb006a750000000000000000000000000000000000000000000000000000000000000001':  # Keccak hash of the function name   0x73844c56
                    print(f'Found interaction with function emitCheckPayment!\n')
                    handle_payment()
                # print(tx)

        sleep(5)
    # event_filter = contract.events.CheckPayment.create_filter(fromBlock='latest')
    # while True:
    #     for event in event_filter.get_all_entries():
    #         print(event)
    #     sleep(5)

    