#!/usr/bin/env python3
import mysql.connector
import random
import string
from datetime import datetime, timedelta

def create_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='testpass',
        database='testdb'
    )

def create_table():
    conn = create_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS test_records (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100),
            email VARCHAR(100),
            age INT,
            city VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    conn.commit()
    cursor.close()
    conn.close()
    print("Table created successfully")

def generate_test_data(num_records=1000000):
    conn = create_connection()
    cursor = conn.cursor()
    
    cities = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose']
    
    print(f"Inserting {num_records} records...")
    
    # Insert in batches for better performance
    batch_size = 10000
    for i in range(0, num_records, batch_size):
        batch_data = []
        for j in range(batch_size):
            if i + j >= num_records:
                break
            
            name = ''.join(random.choices(string.ascii_letters, k=10))
            email = f"{name.lower()}@example.com"
            age = random.randint(18, 80)
            city = random.choice(cities)
            
            batch_data.append((name, email, age, city))
        
        cursor.executemany(
            "INSERT INTO test_records (name, email, age, city) VALUES (%s, %s, %s, %s)",
            batch_data
        )
        
        if (i + batch_size) % 100000 == 0:
            print(f"Inserted {i + batch_size} records...")
    
    conn.commit()
    cursor.close()
    conn.close()
    print(f"Successfully inserted {num_records} records")

if __name__ == "__main__":
    create_table()
    generate_test_data(1000000)
