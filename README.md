# 🎲 Faker SQL

A web application for generating random, reproducible fake user data powered entirely by SQL stored procedures.

## Features

- ✅ **Deterministic Generation**: Same seed = same data, always
- ✅ **Multiple Locales**: English (US) and German (Germany) supported
- ✅ **Rich Data**: Names, addresses, coordinates, physical attributes, phones, emails
- ✅ **Uniform Sphere Distribution**: Geolocation uses proper arcsin distribution
- ✅ **Normal Distribution**: Height/weight follow realistic bell curves
- ✅ **Markov Chain Text**: Optional bio generation using Markov chains
- ✅ **Batch Processing**: Generate any number of users in batches
- ✅ **Extensible**: Easy to add new locales and data types

## Quick Start

### Prerequisites

- PostgreSQL 14+
- Python 3.10+

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd faker-sql
```

2. **Set up PostgreSQL database**
```bash
# Create database and user
sudo -u postgres psql
CREATE DATABASE faker_db;
CREATE USER faker_user WITH PASSWORD 'faker_password';
GRANT ALL PRIVILEGES ON DATABASE faker_db TO faker_user;
\q
```

3. **Run SQL scripts**
```bash
# Connect to database and run scripts in order
psql -U faker_user -d faker_db -f sql/01_schema.sql
psql -U faker_user -d faker_db -f sql/02_seed_data.sql
psql -U faker_user -d faker_db -f sql/02_seed_data_cities.sql
psql -U faker_user -d faker_db -f sql/03_random_utils.sql
psql -U faker_user -d faker_db -f sql/04_generators.sql
psql -U faker_user -d faker_db -f sql/05_main_procedure.sql
```

4. **Install Python dependencies**
```bash
pip install -r requirements.txt
```

5. **Configure environment**
```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=faker_db
export DB_USER=faker_user
export DB_PASSWORD=faker_password
export FLASK_PORT=5000
```

6. **Run the application**
```bash
python -m app.main
```

7. **Open in browser**
```
http://localhost:5000
```

## API Endpoints

### GET /api/generate
Generate fake users.

**Parameters:**
- `locale` - Locale code (en_US, de_DE)
- `seed` - Seed value for reproducibility
- `batch_index` - Batch number (0-based)
- `batch_size` - Users per batch (1-100)
- `include_bio` - Include generated bio text (true/false)

**Example:**
```bash
curl "http://localhost:5000/api/generate?locale=en_US&seed=12345&batch_size=10"
```

### GET /api/benchmark
Run performance benchmark.

**Parameters:**
- `locale` - Locale code
- `iterations` - Number of users to generate

**Example:**
```bash
curl "http://localhost:5000/api/benchmark?locale=en_US&iterations=1000"
```

### GET /api/locales
Get available locales.

### GET /api/health
Health check endpoint.

## SQL Functions

### Main Entry Point
```sql
SELECT * FROM generate_fake_users('en_US', 12345, 0, 10, FALSE);
```

### Benchmark
```sql
SELECT * FROM benchmark_generation('en_US', 1000);
```

### Individual Generators
```sql
-- Generate name
SELECT * FROM generate_full_name(12345, 'en_US');

-- Generate address
SELECT * FROM generate_full_address(12345, 'en_US');

-- Generate coordinates (uniform on sphere)
SELECT * FROM random_geo_coordinates(12345);

-- Generate physical attributes
SELECT * FROM generate_physical_attributes(12345, 'male');
```

## Data Capacity

The lookup tables support generating **10,000 - 1,000,000 unique users**:

| Data Type | en_US | de_DE |
|-----------|-------|-------|
| First Names | 400 | 400 |
| Last Names | 500 | 500 |
| Middle Names | 100 | 50 |
| Cities | 200 | 150 |
| States | 50 | 16 |
| Streets | 300 | 300 |

**Theoretical Combinations:**
- Names: 400 × 500 = 200,000 base combinations
- With middle names, titles, variations: 2,000,000+ combinations
- Combined with addresses: Billions of unique profiles

## Algorithm Details

### Reproducibility
Uses Linear Congruential Generator (LCG) with Numerical Recipes constants:
- Multiplier: 1103515245
- Increment: 12345
- Modulus: 2^31

### Uniform Sphere Distribution
Latitude uses arcsin distribution: `lat = arcsin(2u - 1)`
This ensures points are uniformly distributed on the sphere surface.

### Normal Distribution
Box-Muller transform:
```
z = sqrt(-2 * ln(u1)) * cos(2π * u2)
result = mean + z * stddev
```

## Project Structure

```
faker-sql/
├── app/
│   ├── __init__.py
│   ├── main.py           # Flask application
│   ├── database.py       # Database connection
│   ├── faker_service.py  # Business logic
│   ├── routes.py         # HTTP routes
│   └── templates/
│       └── index.html    # Web interface
├── sql/
│   ├── 01_schema.sql     # Database schema
│   ├── 02_seed_data.sql  # Lookup data
│   ├── 03_random_utils.sql    # PRNG utilities
│   ├── 04_generators.sql      # Data generators
│   └── 05_main_procedure.sql  # Main functions
├── docs/
│   └── DOCUMENTATION.md  # Full documentation
├── requirements.txt
└── README.md
```

## License

MIT License

## Author

Task 6_DATA Implementation
