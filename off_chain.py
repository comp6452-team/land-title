import sqlite3
from web3 import Web3

# Connect to local Ethereum node
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

#create a new database

# Set up SQLite database for transaction history
conn = sqlite3.connect('database.db')
c = conn.cursor()

# #crerate table for properties
# c.execute('''
#     CREATE TABLE properties (
#         property_id INTEGER PRIMARY KEY,
#         address TEXT,
#         city TEXT,
#         state TEXT,
#         zip TEXT,
#         price REAL,
#         square_footage REAL,
#         year_built INTEGER,
#         number_of_bedrooms INTEGER

#     )''')
# # Create 'owners' table

# c.execute('''
#     CREATE TABLE owners (
#         owner_id INTEGER PRIMARY KEY,
#         first_name TEXT,
#         last_name TEXT,
#         date_of_birth TEXT
#     )
# ''')

# # Create 'transactions' table
# c.execute('''
#     CREATE TABLE transactions (
#         transaction_id INTEGER PRIMARY KEY,
#         property_id INTEGER,
#         previous_owner_id INTEGER,
#         new_owner_id INTEGER,
#         transaction_date TEXT,
#         price REAL,
#         FOREIGN KEY (property_id) REFERENCES properties(property_id),
#         FOREIGN KEY (previous_owner_id) REFERENCES owners(owner_id),
#         FOREIGN KEY (new_owner_id) REFERENCES owners(owner_id)
#     )
# ''')
# c.execute('''
#     CREATE TABLE tax_payment (
#         tax_payment_id INTEGER PRIMARY KEY,
#         property_id INTEGER,
#         owner_id INTEGER,
#         tax_payment_date TEXT,
#         tax_payment_amount REAL,
#         FOREIGN KEY (property_id) REFERENCES properties(property_id),
#         FOREIGN KEY (owner_id) REFERENCES owners(owner_id)
#     )
# ''')

# Fetch the latest block
latest_block = w3.eth.get_block('latest')


# Insert all transactions in the block into the database
for tx_hash in latest_block['transactions']:
    tx = w3.eth.getTransaction(tx_hash)
    c.execute('INSERT INTO transactions VALUES (?,?,?,?,?,?)', (tx['hash'], tx['from'], tx['to'], tx['value'], tx['gas'], tx['input']))

# Save (commit) the changes
conn.commit()

# Close the connection
conn.close()
