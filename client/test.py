from web3 import Web3
import json

web3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

escrow_truffle_file = json.load(open('./build/contracts/Escrow.json'))
escrow_abi = escrow_truffle_file['abi']
contract_address = escrow_truffle_file['networks']['1337']['address']
print(contract_address)
escrow_contract = web3.eth.contract(address=contract_address, abi=escrow_abi)

from_account_address = "0x8dE930dbAd0D99759Db57C2F906010f87D4185FF"


tx_check_hash = escrow_contract.functions.emitCheckPayment().build_transaction({
    'chainId': 1337,
    'gas': 500000,
    'gasPrice': web3.to_wei('20', 'gwei'),
    'nonce': web3.eth.get_transaction_count(from_account_address),
    'from': from_account_address})

tx_hash = web3.eth.send_transaction(tx_check_hash)
receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
print(receipt)