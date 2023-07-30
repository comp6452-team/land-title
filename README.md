# Project Title: Blockchain-Based Land Title Management

## Project Description:
This project is a Blockchain application, developed to manage and record transactions related to Land Titles. It utilizes the Ethereum Blockchain, Solidity for smart contract development, Python for backend processing, SQLite for data storage, and Ganache for running a local Ethereum Blockchain.

## Technologies Used:

- **Solidity:** Solidity is a statically-typed programming language designed for developing smart contracts that run on the Ethereum Virtual Machine. In our project, it's used for creating and managing the smart contracts related to land title transactions.

- **Python:** Python is an interpreted high-level programming language for general-purpose programming. We use it for backend processing and interacting with the Ethereum blockchain.

- **SQLite:** SQLite is a C library that provides a lightweight disk-based database that doesn’t require a separate server process. In our project, we use SQLite for storing and managing data related to the transactions.

- **Ganache:** Ganache is a personal Ethereum blockchain which can be used for Ethereum software development and testing. In this project, it is used for deploying and testing the smart contracts locally.

## Installation Guide:

1. **Prerequisites:** You should have Solidity, Python, and Ganache installed in your system. Also, an SQLite database is required.

2. **Clone the repository:** Clone this repository to your local machine.

3. **Setting up the environment:** Create a virtual environment and install the requirements with `pip install -r requirements.txt`.

4. **Configure Ganache:** Open Ganache and create a new workspace pointing to the `truffle-config.js` in this project.

5. **Compile and migrate the smart contract:** Use `truffle compile` and `truffle migrate` to compile and deploy your contract on Ganache.

6. **Run the Python backend:** Run the Python scripts to interact with the blockchain and manage the SQLite database.

