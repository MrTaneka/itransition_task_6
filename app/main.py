"""
Main Flask Application Module.
Entry point for the Faker SQL web application.
"""

import os
from flask import Flask
from app.database import DatabaseConfig, init_database, close_database
from app.routes import faker_bp


def create_app(config: DatabaseConfig = None) -> Flask:
    """
    Application factory function.
    Creates and configures the Flask application.
    
    Args:
        config: Database configuration object
    
    Returns:
        Configured Flask application
    """
    app = Flask(__name__, 
                template_folder='templates',
                static_folder='../static')
    
    # Load configuration
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'faker-sql-secret-key')
    app.config['JSON_SORT_KEYS'] = False
    
    # Initialize database
    if config is None:
        config = DatabaseConfig()
    
    with app.app_context():
        init_database(config)
    
    # Register blueprints
    app.register_blueprint(faker_bp)
    
    # Register shutdown handler
    @app.teardown_appcontext
    def shutdown_session(exception=None):
        pass  # Pool handles connection management
    
    return app


def main():
    """
    Main entry point for running the application.
    """
    # Create application
    app = create_app()
    
    # Get host and port from environment
    host = os.environ.get('FLASK_HOST', '0.0.0.0')
    port = int(os.environ.get('FLASK_PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'false').lower() == 'true'
    
    # Run application
    try:
        app.run(host=host, port=port, debug=debug)
    finally:
        close_database()


if __name__ == '__main__':
    main()
