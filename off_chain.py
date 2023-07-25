import sqlite3
import json
from web3 import Web3

# Connect to local Ethereum node
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

#create a new database

# Set up SQLite database for transaction history
conn = sqlite3.connect('database.db')
c = conn.cursor()
assert w3.is_connected()
truffleFile = json.load(open('./build/contracts/LandRegistry.json'))
abi = truffleFile['abi']
bytecode = truffleFile['bytecode']
contract_address = "0x8B784c484e80E9164C40e138a38d58040bEce87A"
contract = w3.eth.contract(address=contract_address, abi=abi)

# convert dictionary to hash

response = contract.functions.addProperty("randwick", 250)
print(response)

# # Fetch the latest block
latest_block = w3.eth.get_block('latest')
print(latest_block)

# # Insert all transactions in the block into the database
# for tx_hash in latest_block['transactions']:
#     tx = w3.eth.getTransaction(tx_hash)
#     c.execute('INSERT INTO transactions VALUES (?,?,?,?,?,?)', (tx['hash'], tx['from'], tx['to'], tx['value'], tx['gas'], tx['input']))

# # Save (commit) the changes
# conn.commit()

# # Close the connection
# conn.close()
