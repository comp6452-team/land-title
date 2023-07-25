from web3 import Web3
from time import sleep
import json

# Replace with the actual address of the Ethereum node
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Replace with the private key of the oracle account
private_key = '0xceb1d8bc2c141e448d3d31fb5671a1b03a552a8d5ec683ad9513aa8289b84a8b'

truffleFile = json.load(open('./build/contracts/Escrow.json'))
contract_abi = truffleFile['abi']
latest_timestamp = max(truffleFile["networks"].keys())
contract_address = truffleFile["networks"][latest_timestamp]["address"]

oracle_address = "0xA1e77EC2f0ad59121DA812cd5be61E3CAc30F472"
# contract_address = "0x1e16c152937A0d98f8a87ff03E24e48eC6f32342"

def handle_payment():
    # escrow_contract = w3.eth.contract(address=contract_address, abi=contract_abi)
    # transaction = escrow_contract.functions.paymentReceived().build_transaction({
    #     'gas': 2000000,
    #     'gasPrice': w3.to_wei('40', 'gwei'),
    #     'nonce': w3.eth.get_transaction_count(oracle_address),
    # })

    # signed_transaction = w3.eth.account.sign_transaction(transaction, private_key)
    # tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
    # tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    # print(f"Transaction Hash: {tx_receipt.transactionHash.hex()}")
    print("payment called")


if __name__ == '__main__':
    # event_filter = w3.eth.contract(address=contract_address, abi=contract_abi).events.CheckPayment.create_filter(fromBlock='latest')
    # # event_filter = w3.eth.contract(address=contract_address, abi=contract_abi).events.CheckPayment.create_filter(fromBlock='latest', topics=[Web3.sha3(text='CheckPayment')])
    # # event_filter.on('CheckPayment', handle_payment)
    # event_filter.on('data', handle_payment)

    # try:
    #     # Keep the script running
    #     while True:
    #         pass
    # except KeyboardInterrupt:
    #     print("Exiting...")


    contract = w3.eth.contract(address=Web3.to_checksum_address(contract_address), abi=contract_abi)
    logs = contract.events.Transfer().get_logs()
    print(logs)
    
    event_filter = contract.events.CheckPayment.create_filter(fromBlock='latest')
    while True:
        for event in event_filter.get_all_entries():
            print(event)
        sleep(5)
    # while True:
    #     # command = input("Payment complete (true or false): ")
    #     print(event_filter.get_new_entries())
    #     for CheckPayment in event_filter.get_new_entries():
    #         handle_payment()

    #     sleep(2)  # Check for new events every 2 seconds
    