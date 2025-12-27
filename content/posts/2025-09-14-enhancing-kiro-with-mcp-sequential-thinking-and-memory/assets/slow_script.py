#!/usr/bin/env python3
import mysql.connector
import time

def create_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='testpass',
        database='testdb'
    )

def process_records():
    """Slow version - individual queries for demonstration"""
    conn = create_connection()
    cursor = conn.cursor()
    
    # Get all record IDs first
    cursor.execute("SELECT id FROM test_records LIMIT 10000")  # Using 10k for demo
    record_ids = [row[0] for row in cursor.fetchall()]
    
    print(f"Processing {len(record_ids)} records individually...")
    start_time = time.time()
    
    processed_count = 0
    for record_id in record_ids:
        # Individual query for each record (SLOW!)
        cursor.execute("SELECT * FROM test_records WHERE id = %s", (record_id,))
        record = cursor.fetchone()
        
        if record:
            # Simulate some processing
            processed_count += 1
            
        if processed_count % 1000 == 0:
            print(f"Processed {processed_count} records...")
    
    end_time = time.time()
    cursor.close()
    conn.close()
    
    print(f"Processing completed: {processed_count} records in {end_time - start_time:.2f} seconds")

if __name__ == "__main__":
    process_records()
