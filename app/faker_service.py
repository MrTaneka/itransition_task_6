"""
Faker Service Module.
Business logic layer for generating fake user data.
Follows Single Responsibility Principle - only handles faker logic.
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from app.database import execute_query, call_stored_procedure


@dataclass
class FakeUser:
    """Data class representing a generated fake user."""
    record_index: int
    full_name: str
    gender: str
    address: str
    latitude: float
    longitude: float
    height_cm: float
    weight_kg: float
    eye_color: str
    phone: str
    email: str
    bio: Optional[str] = None
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'FakeUser':
        """Create FakeUser from database dictionary."""
        return cls(
            record_index=data.get('record_index', 0),
            full_name=data.get('full_name', ''),
            gender=data.get('gender', ''),
            address=data.get('address', ''),
            latitude=float(data.get('latitude', 0)),
            longitude=float(data.get('longitude', 0)),
            height_cm=float(data.get('height_cm', 0)),
            weight_kg=float(data.get('weight_kg', 0)),
            eye_color=data.get('eye_color', ''),
            phone=data.get('phone', ''),
            email=data.get('email', ''),
            bio=data.get('bio')
        )
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            'record_index': self.record_index,
            'full_name': self.full_name,
            'gender': self.gender,
            'address': self.address,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'height_cm': self.height_cm,
            'weight_kg': self.weight_kg,
            'eye_color': self.eye_color,
            'phone': self.phone,
            'email': self.email,
            'bio': self.bio
        }


@dataclass
class Locale:
    """Data class representing an available locale."""
    code: str
    name: str
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Locale':
        """Create Locale from database dictionary."""
        return cls(
            code=data.get('code', ''),
            name=data.get('name', '')
        )
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            'code': self.code,
            'name': self.name
        }


@dataclass
class BenchmarkResult:
    """Data class for benchmark results."""
    users_generated: int
    duration_ms: float
    users_per_second: float
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'BenchmarkResult':
        """Create BenchmarkResult from database dictionary."""
        return cls(
            users_generated=data.get('users_generated', 0),
            duration_ms=float(data.get('duration_ms', 0)),
            users_per_second=float(data.get('users_per_second', 0))
        )
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            'users_generated': self.users_generated,
            'duration_ms': self.duration_ms,
            'users_per_second': self.users_per_second
        }


class FakerService:
    """
    Service class for faker operations.
    Encapsulates all business logic for fake data generation.
    """
    
    @staticmethod
    def get_available_locales() -> List[Locale]:
        """
        Retrieve all available locales from database.
        
        Returns:
            List of Locale objects
        """
        results = call_stored_procedure('get_available_locales')
        return [Locale.from_dict(row) for row in results]
    
    @staticmethod
    def generate_users(
        locale_code: str,
        seed: int,
        batch_index: int = 0,
        batch_size: int = 10,
        include_bio: bool = False
    ) -> List[FakeUser]:
        """
        Generate a batch of fake users.
        
        Args:
            locale_code: Locale code (e.g., 'en_US', 'de_DE')
            seed: Seed value for reproducible generation
            batch_index: Which batch to generate (0-based)
            batch_size: Number of users per batch
            include_bio: Whether to generate bio text
        
        Returns:
            List of FakeUser objects
        """
        results = call_stored_procedure(
            'generate_fake_users',
            locale_code,
            seed,
            batch_index,
            batch_size,
            include_bio
        )
        return [FakeUser.from_dict(row) for row in results]
    
    @staticmethod
    def run_benchmark(
        locale_code: str = 'en_US',
        iterations: int = 100
    ) -> BenchmarkResult:
        """
        Run performance benchmark.
        
        Args:
            locale_code: Locale to use for benchmark
            iterations: Number of users to generate
        
        Returns:
            BenchmarkResult with performance metrics
        """
        results = call_stored_procedure(
            'benchmark_generation',
            locale_code,
            iterations
        )
        if results:
            return BenchmarkResult.from_dict(results[0])
        return BenchmarkResult(0, 0, 0)
    
    @staticmethod
    def validate_locale(locale_code: str) -> bool:
        """
        Check if a locale code is valid.
        
        Args:
            locale_code: Locale code to validate
        
        Returns:
            True if locale exists
        """
        locales = FakerService.get_available_locales()
        return any(loc.code == locale_code for loc in locales)
    
    @staticmethod
    def validate_seed(seed: Any) -> Optional[int]:
        """
        Validate and convert seed value.
        
        Args:
            seed: Seed value to validate
        
        Returns:
            Valid integer seed or None if invalid
        """
        try:
            seed_int = int(seed)
            if seed_int < 0:
                return None
            return seed_int
        except (ValueError, TypeError):
            return None
    
    @staticmethod
    def validate_batch_index(batch_index: Any) -> Optional[int]:
        """
        Validate batch index.
        
        Args:
            batch_index: Batch index to validate
        
        Returns:
            Valid integer or None if invalid
        """
        try:
            idx = int(batch_index)
            if idx < 0:
                return None
            return idx
        except (ValueError, TypeError):
            return None
    
    @staticmethod
    def validate_batch_size(batch_size: Any, max_size: int = 100) -> Optional[int]:
        """
        Validate batch size.
        
        Args:
            batch_size: Batch size to validate
            max_size: Maximum allowed batch size
        
        Returns:
            Valid integer or None if invalid
        """
        try:
            size = int(batch_size)
            if size < 1 or size > max_size:
                return None
            return size
        except (ValueError, TypeError):
            return None
