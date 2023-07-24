import sys
from web3 import Web3
from json import dumps
from time import sleep

# Replace with the actual address of the Ethereum node
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Replace with the private key of the oracle account
private_key = 'YOUR_PRIVATE_KEY'

# Replace with the actual contract address and ABI
contract_address = '0x123456789ABCDEF'  # Replace with the contract address
contract_abi = [...]  # Replace with the contract ABI

def handle_payment(event, payment_received):
    

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Please enter the payment status ('true' or 'false') as a command line argument.")
        sys.exit(1)

    payment_received = sys.argv[1]
    if payment_received.lower() not in ['true', 'false']:
        print("Invalid payment status. Please enter 'true' or 'false'.")
        sys.exit(1)

    # Replace 'CheckPayment' with the actual event name
    event_filter = w3.eth.contract(address=contract_address, abi=contract_abi).events.CheckPayment.createFilter(fromBlock='latest', topics=[Web3.sha3(text='CheckPayment')])

    while True:
        for event in event_filter.get_new_entries():
            handle_payment(event, payment_received)
        sleep(2)  # Check for new events every 2 seconds
