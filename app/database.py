"""
Database connection module for Faker SQL.
Provides connection pooling and query execution utilities.
Following SOLID principles - Single Responsibility.
"""

import os
import psycopg2
from psycopg2 import pool
from psycopg2.extras import RealDictCursor
from contextlib import contextmanager
from typing import Optional, List, Dict, Any


class DatabaseConfig:
    """Configuration class for database connection."""
    
    def __init__(self):
        # Support DATABASE_URL format (used by Render, Heroku, etc.)
        database_url = os.environ.get('DATABASE_URL')
        
        if database_url:
            # Parse DATABASE_URL
            import urllib.parse
            parsed = urllib.parse.urlparse(database_url)
            self.host = parsed.hostname or 'localhost'
            self.port = parsed.port or 5432
            self.database = parsed.path[1:] if parsed.path else 'faker_db'
            self.user = parsed.username or 'faker_user'
            self.password = parsed.password or 'faker_password'
        else:
            self.host = os.environ.get('DB_HOST', 'localhost')
            self.port = int(os.environ.get('DB_PORT', 5432))
            self.database = os.environ.get('DB_NAME', 'faker_db')
            self.user = os.environ.get('DB_USER', 'faker_user')
            self.password = os.environ.get('DB_PASSWORD', 'faker_password')
        
        self.min_connections = int(os.environ.get('DB_MIN_CONN', 1))
        self.max_connections = int(os.environ.get('DB_MAX_CONN', 10))
    
    def to_dict(self) -> Dict[str, Any]:
        """Return connection parameters as dictionary."""
        return {
            'host': self.host,
            'port': self.port,
            'database': self.database,
            'user': self.user,
            'password': self.password
        }


class DatabasePool:
    """
    Database connection pool manager.
    Implements Singleton pattern for application-wide pool.
    """
    
    _instance: Optional['DatabasePool'] = None
    _pool: Optional[pool.ThreadedConnectionPool] = None
    
    def __new__(cls) -> 'DatabasePool':
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def initialize(self, config: DatabaseConfig) -> None:
        """Initialize the connection pool."""
        if self._pool is None:
            self._pool = pool.ThreadedConnectionPool(
                config.min_connections,
                config.max_connections,
                **config.to_dict()
            )
    
    def get_connection(self):
        """Get a connection from the pool."""
        if self._pool is None:
            raise RuntimeError("Database pool not initialized")
        return self._pool.getconn()
    
    def return_connection(self, conn) -> None:
        """Return a connection to the pool."""
        if self._pool is not None:
            self._pool.putconn(conn)
    
    def close_all(self) -> None:
        """Close all connections in the pool."""
        if self._pool is not None:
            self._pool.closeall()
            self._pool = None


@contextmanager
def get_db_connection():
    """
    Context manager for database connections.
    Ensures proper connection handling and return to pool.
    """
    db_pool = DatabasePool()
    conn = None
    try:
        conn = db_pool.get_connection()
        yield conn
    finally:
        if conn is not None:
            db_pool.return_connection(conn)


@contextmanager
def get_db_cursor(commit: bool = False):
    """
    Context manager for database cursor.
    Provides RealDictCursor for named column access.
    """
    with get_db_connection() as conn:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        try:
            yield cursor
            if commit:
                conn.commit()
        except Exception as e:
            conn.rollback()
            raise e
        finally:
            cursor.close()


def execute_query(query: str, params: tuple = None) -> List[Dict[str, Any]]:
    """
    Execute a SELECT query and return results as list of dicts.
    Args:
        query: SQL query string
        params: Query parameters
    Returns:
        List of dictionaries representing rows
    """
    with get_db_cursor() as cursor:
        cursor.execute(query, params)
        return cursor.fetchall()


def execute_function(func_name: str, *args) -> List[Dict[str, Any]]:
    """
    Execute a database function and return results.
    Args:
        func_name: Name of the function to call
        *args: Function arguments
    Returns:
        List of dictionaries representing result rows
    """
    placeholders = ', '.join(['%s'] * len(args))
    query = f"SELECT * FROM {func_name}({placeholders})"
    return execute_query(query, args)


def call_stored_procedure(proc_name: str, *args) -> List[Dict[str, Any]]:
    """
    Call a stored procedure (set-returning function).
    Args:
        proc_name: Name of the procedure
        *args: Procedure arguments
    Returns:
        List of result rows as dictionaries
    """
    return execute_function(proc_name, *args)


def init_database(config: DatabaseConfig) -> None:
    """
    Initialize the database pool with configuration.
    Should be called at application startup.
    """
    db_pool = DatabasePool()
    db_pool.initialize(config)


def close_database() -> None:
    """
    Close all database connections.
    Should be called at application shutdown.
    """
    db_pool = DatabasePool()
    db_pool.close_all()
