"""
Generate a random 4-byte hex salt for test data isolation.
Usage: python scripts/generate_salt.py
Output: prints SALT=<8-char hex string>
"""
import secrets

salt = secrets.token_hex(4)
print(f"SALT={salt}")
