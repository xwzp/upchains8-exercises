from dataclasses import dataclass
import hashlib
import itertools
import time
import uuid


@dataclass
class Block:
    nonce: int
    hex_dig: str
    message: str
    difficulty: int
    count: int

def mine(difficulty, name):
    for count in itertools.count(start=0, step=1):
        nonce = uuid.uuid4() 
        message = f"{name}{nonce}".encode('utf-8')
        hex_dig = hashlib.sha256(message).hexdigest()
        if hex_dig.startswith("0" * difficulty):
            return Block(
                nonce=nonce,
                hex_dig=hex_dig,
                message=message,
                difficulty=difficulty,
                count=count
            ) 

if __name__ == "__main__":
    YOUR_NAME = "xwzp"

    start_time = time.time()
    block = mine(difficulty=4, name=YOUR_NAME)
    print(f"difficulty: {block.difficulty}")
    print(f"count: {block.count}")
    print(f"Time taken: {time.time() - start_time} seconds")
    print(f"nonce: {block.nonce}")
    print(f"message: {block.message}")
    print(f"hex_dig: {block.hex_dig}")
    print("--------------------------------")


    start_time = time.time()
    block = mine(difficulty=5, name=YOUR_NAME)
    print(f"difficulty: {block.difficulty}")
    print(f"count: {block.count}")
    print(f"Time taken: {time.time() - start_time} seconds")
    print(f"nonce: {block.nonce}")
    print(f"message: {block.message}")
    print(f"hex_dig: {block.hex_dig}")
    print("--------------------------------")