import hashlib
import itertools
import time
import uuid

YOUR_NAME = "wzp"

start_time = time.time()
difficulty = 4
for count in itertools.count(start=0, step=1):
    nonce = uuid.uuid4() 
    message = f"{YOUR_NAME}{nonce}".encode('utf-8')
    hex_dig = hashlib.sha256(message).hexdigest()
    if hex_dig.startswith("0" * difficulty):
        print(f"difficulty: {difficulty}")
        print(f"count: {count}")
        print(f"Time taken: {time.time() - start_time} seconds")
        print(f"nonce: {nonce}")
        print(f"message: {message}")
        print(f"hex_dig: {hex_dig}")
        print("--------------------------------")
        difficulty += 1
        if difficulty > 5:
            break
