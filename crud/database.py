import mysql.connector
from mysql.connector import pooling
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database configuration
db_config = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "task_manager"),
    "port": int(os.getenv("DB_PORT", "3306"))
}

# Create connection pool
try:
    connection_pool = mysql.connector.pooling.MySQLConnectionPool(
        pool_name="task_manager_pool",
        pool_size=5,
        **db_config
    )
    print("Connection pool created successfully")
except Exception as e:
    print(f"Error creating connection pool: {e}")
    raise

def get_db():
    """
    Get a connection from the pool and create a cursor.
    This will be used as a dependency in FastAPI routes.
    """
    connection = connection_pool.get_connection()
    cursor = connection.cursor(dictionary=True)
    try:
        yield connection, cursor
    finally:
        cursor.close()
        connection.close()