from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256

from mining import mine

private_key = RSA.generate(2048)
public_key = private_key.publickey()

print("------ PRIVATE KEY HEX ------")
print(f"{private_key.export_key("DER").hex()}")
print("\n------ PUBLIC KEY HEX ------")
print(f"{public_key.export_key("DER").hex()}")

print("\n------ MINE BLOCK ------")
mined_block = mine(difficulty=4, name="wzp")
print(f"mined_block: {mined_block}")

print("\n------ SIGN MESSAGE ------")
hash = SHA256.new(mined_block.message)
signer = pkcs1_15.new(private_key)
signature = signer.sign(hash)
print(f"signature hex: {signature.hex()}")

print("\n------ VERIFY MESSAGE ------")
verifier = pkcs1_15.new(public_key)
try:
    verifier.verify(hash, signature)
    print("Signature verified")
except Exception as e:
    print(f"Signature verification failed: {e}")