from dataclasses import dataclass
from fastapi import FastAPI 
import click
import uvicorn
import hashlib
import itertools
import time
import requests

def delkey(d: dict, key: str):
    d2 = d.copy()
    del d2[key]
    return d2

@dataclass
class Transaction:
    sender: str
    recipient: str
    amount: int

    def __str__(self):
        return f"Transaction(sender={self.sender}, recipient={self.recipient}, amount={self.amount})"

    @property
    def hash(self):
        message = f'{self.sender}{self.recipient}{self.amount}'
        return hashlib.sha256(message.encode("utf-8")).hexdigest()

@dataclass
class Block:
    index: int
    timestamp: int
    transactions: list[Transaction]
    proof: int
    previous_hash: str

    @property
    def hash(self):
        message = f'{self.index}{self.transactions}{self.previous_hash}{self.proof}'
        return hashlib.sha256(message.encode("utf-8")).hexdigest()

    def add_transaction(self, transaction: Transaction):
        self.transactions.append(transaction)


class BlockchainNode:
    blocks: list[Block]
    difficulty: int
    mempool: dict[str, Transaction]
    nodes: set[str]

    def __init__(self):
        self.blocks = [] 
        self.mempool = {}
        self.nodes = set()
        self.difficulty = 4

    def add_transaction(self, transaction: Transaction):
        self.mempool[transaction.hash] = transaction

    def new_block(self):
        block = Block(
            index=len(self.blocks) + 1,
            timestamp=0,
            transactions=[],
            proof=0,
            previous_hash=self.blocks[-1].hash if self.blocks else ""
        )

        # 最多取 10 个交易, 模拟区块的大小限制
        hashes = list(self.mempool.keys())[:10]
        for hash in hashes:
            transaction = self.mempool[hash]
            block.add_transaction(transaction)
            del self.mempool[hash]
        return block

    def mine_block(self):
        block = self.new_block()
        proof = self.proof_of_work(block)
        block.proof = proof
        block.timestamp = int(time.time())

        self.blocks.append(block)
        return block

    def proof_of_work(self, block: Block):
        for nonce in itertools.count(start=0, step=1):
            message = f'{block.index}{block.transactions}{block.previous_hash}{nonce}'
            hash = hashlib.sha256(message.encode("utf-8")).hexdigest()
            if hash.startswith("0" * self.difficulty):
                return nonce
    
    def register_node(self, node: str):
        self.nodes.add(node)

    def resolve_conflicts(self):
        longest_chain = None
        max_length = len(self.blocks)
        for node in self.nodes:
            response = requests.get(f"{node}/chain")
            if response.status_code == 200:
                chain = response.json()["chain"]
                if len(chain) > max_length:
                    max_length = len(chain)
                    longest_chain = [Block(**delkey(block, "hash")) for block in chain]
        if longest_chain:
            self.blocks = longest_chain
            return True
        return False

app = FastAPI()
blockchain_node = BlockchainNode()

@app.post("/transaction/new")
async def new_transaction(transaction: Transaction):
    blockchain_node.add_transaction(transaction)
    return {"message": "Transaction will be added to the next block"}

@app.post("/block/mine")
async def mine_block():
    mined_block = blockchain_node.mine_block()
    return {"message": f"New block mined, block={mined_block}"}

@app.get("/chain")
async def get_chain():
    blocks = []
    for block in blockchain_node.blocks:
        blocks.append({
            "index": block.index,
            "timestamp": block.timestamp,
            "transactions": block.transactions,
            "proof": block.proof,
            "previous_hash": block.previous_hash,
            "hash": block.hash
        })
    return {"chain": blocks}

@app.post("/nodes/register")
async def register_nodes(nodes: list[str]):
    for node in nodes:
        blockchain_node.register_node(node)
    return {"message": "Nodes registered"}

@app.post("/nodes/resolve")
async def resolve_conflicts():
    replaced = blockchain_node.resolve_conflicts()
    if replaced:
        return {"message": "Nodes replaced"}
    else:
        return {"message": "Nodes not replaced"}

@click.command(
    help="Start the blockchain node"
)
@click.option("--host", default="0.0.0.0", help="Host to bind to")
@click.option("--port", default=8000, help="Port to listen on")
def main(host, port):
    uvicorn.run(app, host=host, port=port)

if __name__ == "__main__":
    main()
