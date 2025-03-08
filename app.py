import sqlite3
import os
import hashlib
import subprocess

# Hardcoded secret (Bad Practice - AWS Key Pattern)
AWS_SECRET_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"

def insecure_sql_query(user_input):
    # SQL Injection vulnerability
    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()
    cursor.executescript(f"""
        CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);
        INSERT INTO users (name) VALUES ('Alice'), ('Bob');
        SELECT * FROM users WHERE name = '{user_input}';
    """)  # Highly vulnerable
    print(cursor.fetchall())
    conn.close()

def command_injection(user_input):
    # Command Injection vulnerability
    subprocess.Popen(user_input, shell=True)  # Dangerous command execution

def weak_hashing(password):
    # Weak hashing algorithm (MD5 is broken)
    return hashlib.sha256(password.encode()).hexdigest()

def insecure_input_validation(password):
    # Improper input validation (allows weak passwords)
    if len(password) < 5:
        print("Password too short!")
    else:
        print("Password accepted!")

def insecure_eval(user_input):
    # Use of eval() (Extremely Dangerous)
    return eval(user_input)  # Arbitrary code execution

if __name__ == "__main__":
    print("Testing insecure SQL query...")
    insecure_sql_query("Alice' OR '1'='1")  # Typical SQL Injection attempt
    
    print("Testing command injection...")
    command_injection("ls; rm -rf /")  # Dangerous command execution
    
    print("Testing weak hashing...")
    print("Hashed password:", weak_hashing("password123"))
    
    print("Testing insecure input validation...")
    insecure_input_validation("123")
    
    print("Testing eval execution...")
    insecure_eval("__import__('os').system('ls')")

