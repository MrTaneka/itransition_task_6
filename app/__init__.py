"""
Faker SQL Application Package.
A web application for generating fake user data using SQL stored procedures.
"""

from app.main import create_app

__version__ = '1.0.0'

# Create app instance for gunicorn
app = create_app()

__all__ = ['create_app', 'app']
