"""
Flask routes module.
Handles HTTP request routing and response formatting.
Follows Single Responsibility - only handles HTTP layer.
"""

from flask import Blueprint, render_template, request, jsonify
from app.faker_service import FakerService

# Create blueprint for faker routes
faker_bp = Blueprint('faker', __name__)


@faker_bp.route('/')
def index():
    """
    Main page - render the web interface.
    """
    locales = FakerService.get_available_locales()
    return render_template('index.html', locales=locales)


@faker_bp.route('/api/locales', methods=['GET'])
def get_locales():
    """
    API endpoint to get available locales.
    
    Returns:
        JSON list of locales
    """
    try:
        locales = FakerService.get_available_locales()
        return jsonify({
            'success': True,
            'data': [loc.to_dict() for loc in locales]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@faker_bp.route('/api/generate', methods=['GET', 'POST'])
def generate_users():
    """
    API endpoint to generate fake users.
    
    Query/Form parameters:
        locale: Locale code (required)
        seed: Seed value (required)
        batch_index: Batch number, default 0
        batch_size: Users per batch, default 10
        include_bio: Include generated bio, default false
    
    Returns:
        JSON with generated users
    """
    try:
        # Get parameters from request
        if request.method == 'POST':
            data = request.get_json() or request.form
        else:
            data = request.args
        
        # Extract and validate parameters
        locale_code = data.get('locale', 'en_US')
        seed = data.get('seed', '12345')
        batch_index = data.get('batch_index', '0')
        batch_size = data.get('batch_size', '10')
        include_bio = data.get('include_bio', 'false')
        
        # Validate locale
        if not FakerService.validate_locale(locale_code):
            return jsonify({
                'success': False,
                'error': f'Invalid locale: {locale_code}'
            }), 400
        
        # Validate seed
        seed_int = FakerService.validate_seed(seed)
        if seed_int is None:
            return jsonify({
                'success': False,
                'error': 'Invalid seed value. Must be a non-negative integer.'
            }), 400
        
        # Validate batch_index
        batch_idx = FakerService.validate_batch_index(batch_index)
        if batch_idx is None:
            return jsonify({
                'success': False,
                'error': 'Invalid batch_index. Must be a non-negative integer.'
            }), 400
        
        # Validate batch_size
        batch_sz = FakerService.validate_batch_size(batch_size)
        if batch_sz is None:
            return jsonify({
                'success': False,
                'error': 'Invalid batch_size. Must be between 1 and 100.'
            }), 400
        
        # Parse include_bio
        bio = include_bio.lower() in ('true', '1', 'yes') if isinstance(include_bio, str) else bool(include_bio)
        
        # Generate users
        users = FakerService.generate_users(
            locale_code=locale_code,
            seed=seed_int,
            batch_index=batch_idx,
            batch_size=batch_sz,
            include_bio=bio
        )
        
        return jsonify({
            'success': True,
            'data': {
                'locale': locale_code,
                'seed': seed_int,
                'batch_index': batch_idx,
                'batch_size': batch_sz,
                'next_batch_index': batch_idx + 1,
                'users': [user.to_dict() for user in users]
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@faker_bp.route('/api/benchmark', methods=['GET'])
def run_benchmark():
    """
    API endpoint to run performance benchmark.
    
    Query parameters:
        locale: Locale code, default 'en_US'
        iterations: Number of users to generate, default 100
    
    Returns:
        JSON with benchmark results
    """
    try:
        locale_code = request.args.get('locale', 'en_US')
        iterations = request.args.get('iterations', '100')
        
        # Validate
        if not FakerService.validate_locale(locale_code):
            return jsonify({
                'success': False,
                'error': f'Invalid locale: {locale_code}'
            }), 400
        
        try:
            iter_count = int(iterations)
            if iter_count < 1 or iter_count > 10000:
                raise ValueError()
        except ValueError:
            return jsonify({
                'success': False,
                'error': 'Iterations must be between 1 and 10000'
            }), 400
        
        # Run benchmark
        result = FakerService.run_benchmark(locale_code, iter_count)
        
        return jsonify({
            'success': True,
            'data': result.to_dict()
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@faker_bp.route('/api/health', methods=['GET'])
def health_check():
    """
    Health check endpoint.
    
    Returns:
        JSON indicating service health
    """
    try:
        # Try to get locales as a simple health check
        locales = FakerService.get_available_locales()
        return jsonify({
            'success': True,
            'status': 'healthy',
            'locales_available': len(locales)
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'status': 'unhealthy',
            'error': str(e)
        }), 503
