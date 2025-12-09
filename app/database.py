"""
Database connection module for Faker SQL.
Provides connection pooling and query execution utilities.
"""

import os
import psycopg
from psycopg.rows import dict_row
from psycopg_pool import ConnectionPool
from contextlib import contextmanager
from typing import Optional, List, Dict, Any


class DatabaseConfig:
    """Configuration class for database connection."""
    
    def __init__(self):
        database_url = os.environ.get('DATABASE_URL')
        
        if database_url:
            self.conninfo = database_url
        else:
            host = os.environ.get('DB_HOST', 'localhost')
            port = os.environ.get('DB_PORT', '5432')
            dbname = os.environ.get('DB_NAME', 'faker_db')
            user = os.environ.get('DB_USER', 'faker_user')
            password = os.environ.get('DB_PASSWORD', 'faker_password')
            self.conninfo = f"host={host} port={port} dbname={dbname} user={user} password={password}"
        
        self.min_connections = int(os.environ.get('DB_MIN_CONN', 1))
        self.max_connections = int(os.environ.get('DB_MAX_CONN', 10))


class DatabasePool:
    """Database connection pool manager. Singleton pattern."""
    
    _instance: Optional['DatabasePool'] = None
    _pool: Optional[ConnectionPool] = None
    
    def __new__(cls) -> 'DatabasePool':
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def initialize(self, config: DatabaseConfig) -> None:
        if self._pool is None:
            self._pool = ConnectionPool(
                config.conninfo,
                min_size=config.min_connections,
                max_size=config.max_connections
            )
    
    def get_connection(self):
        if self._pool is None:
            raise RuntimeError("Database pool not initialized")
        return self._pool.getconn()
    
    def return_connection(self, conn) -> None:
        if self._pool is not None:
            self._pool.putconn(conn)
    
    def close_all(self) -> None:
        if self._pool is not None:
            self._pool.close()
            self._pool = None


@contextmanager
def get_db_connection():
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
    with get_db_connection() as conn:
        cursor = conn.cursor(row_factory=dict_row)
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
    with get_db_cursor() as cursor:
        cursor.execute(query, params)
        return cursor.fetchall()


def execute_function(func_name: str, *args) -> List[Dict[str, Any]]:
    placeholders = ', '.join(['%s'] * len(args))
    query = f"SELECT * FROM {func_name}({placeholders})"
    return execute_query(query, args)


def call_stored_procedure(proc_name: str, *args) -> List[Dict[str, Any]]:
    return execute_function(proc_name, *args)


def init_database(config: DatabaseConfig) -> None:
    db_pool = DatabasePool()
    db_pool.initialize(config)


def close_database() -> None:
    db_pool = DatabasePool()
    db_pool.close_all()
