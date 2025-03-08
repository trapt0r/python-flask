import sqlite3
import os
import hashlib

# Hardcoded secret (Bad Practice)
SECRET_KEY = "mysecretkey123"

def insecure_sql_query(user_input):
    # SQL Injection vulnerability
    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()
    cursor.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
    cursor.execute("INSERT INTO users (name) VALUES ('Alice'), ('Bob')")
    query = f"SELECT * FROM users WHERE name = '{user_input}'"
    cursor.execute(query)  # Vulnerable to SQL Injection
    print(cursor.fetchall())
    conn.close()

def command_injection(user_input):
    # Command Injection vulnerability
    os.system(f"echo {user_input}")  # User input is directly passed to system command

def weak_hashing(password):
    # Weak hashing algorithm (MD5 is broken)
    return hashlib.md5(password.encode()).hexdigest()

def insecure_input_validation(password):
    # Improper input validation (allows weak passwords)
    if len(password) < 5:
        print("Password too short!")
    else:
        print("Password accepted!")

if __name__ == "__main__":
    print("Testing insecure SQL query...")
    insecure_sql_query("Alice' OR '1'='1")  # Typical SQL Injection attempt
    
    print("Testing command injection...")
    command_injection("; rm -rf /")  # Dangerous command execution
    
    print("Testing weak hashing...")
    print("Hashed password:", weak_hashing("password123"))
    
    print("Testing insecure input validation...")
    insecure_input_validation("123")
