# Faker SQL Library Documentation

## Overview

Faker SQL is a PostgreSQL-based library for generating deterministic, reproducible fake user data. All data generation logic is implemented as SQL stored procedures, making it portable and database-native.

## Table of Contents

1. [Architecture](#architecture)
2. [Database Schema](#database-schema)
3. [Core Functions](#core-functions)
4. [Data Generators](#data-generators)
5. [Main API](#main-api)
6. [Algorithms](#algorithms)
7. [Usage Examples](#usage-examples)
8. [Extending the Library](#extending-the-library)

---

## Architecture

### Design Principles

| Principle | Implementation |
|-----------|----------------|
| Extensibility | Single lookup tables with `locale_code` field |
| Reproducibility | Deterministic PRNG with seed-based generation |
| Modularity | Small, focused functions with single responsibility |
| Performance | Batch generation with minimal database round-trips |

### Technology Stack

- **Database**: PostgreSQL 14+
- **Language**: PL/pgSQL stored procedures
- **Web Framework**: Python Flask
- **Deployment**: Docker, Render.com

---

## Database Schema

### Lookup Tables

| Table | Description | Key Fields |
|-------|-------------|------------|
| `locales` | Locale configuration | `code`, `name`, `phone_country_code` |
| `lookup_names` | First, middle, last names | `locale_code`, `name_type`, `gender`, `value` |
| `lookup_titles` | Honorific titles | `locale_code`, `gender`, `value` |
| `lookup_streets` | Street names and types | `locale_code`, `street_type`, `street_name` |
| `lookup_cities` | Cities with state codes | `locale_code`, `city_name`, `state_code` |
| `lookup_states` | State/region names | `locale_code`, `state_name`, `state_code` |
| `lookup_countries` | Country names | `locale_code`, `country_name` |
| `lookup_domains` | Email domains | `locale_code`, `domain_name` |
| `lookup_eye_colors` | Eye colors with frequency | `locale_code`, `color_name`, `frequency` |
| `lookup_phone_formats` | Phone format patterns | `locale_code`, `format_pattern` |
| `lookup_markov_chains` | Text generation data | `locale_code`, `chain_type`, `prefix`, `suffix` |

---

## Core Functions

### Random Number Generation

#### `generate_deterministic_seed`

Creates a unique seed for each record by combining locale, user seed, batch index, and record index.

```sql
generate_deterministic_seed(
    p_locale_code VARCHAR(10),
    p_seed BIGINT,
    p_batch_index INT,
    p_record_index INT
) RETURNS BIGINT
```

**Algorithm**: Prime number mixing with overflow protection:
```
safe_seed = seed & 2147483647
combined = (safe_seed * 31337 + batch_index * 65537 + record_index * 257 + locale_hash) & 2147483647
```

#### `lcg_next`

Linear Congruential Generator - the core PRNG.

```sql
lcg_next(p_state BIGINT)
RETURNS (next_state BIGINT, random_value DOUBLE PRECISION)
```

**Algorithm**: Numerical Recipes constants
```
next = (state * 1103515245 + 12345) mod 2^31
value = next / 2^31
```

**Properties**:
- Period: 2^31 (over 2 billion values)
- Deterministic: same input always produces same output

#### `random_int_range` / `random_double_range`

Generate random values within specified ranges.

```sql
random_int_range(p_state BIGINT, p_min INT, p_max INT)
RETURNS (next_state BIGINT, result INT)

random_double_range(p_state BIGINT, p_min DOUBLE, p_max DOUBLE)
RETURNS (next_state BIGINT, result DOUBLE)
```

---

## Algorithms

### Normal Distribution (Box-Muller Transform)

Used for generating height and weight with realistic distributions.

```sql
random_normal(p_state BIGINT, p_mean DOUBLE, p_stddev DOUBLE)
```

**Mathematical Formula**:
```
u1, u2 = two uniform random values in (0, 1)
z = sqrt(-2 * ln(u1)) * cos(2π * u2)
result = mean + z * stddev
```

### Uniform Sphere Distribution

Generates latitude/longitude pairs uniformly distributed on Earth's surface.

```sql
random_geo_coordinates(p_state BIGINT)
RETURNS (next_state BIGINT, latitude DOUBLE, longitude DOUBLE)
```

**Algorithm**:
- Longitude: uniform distribution in [-180, 180)
- Latitude: `arcsin(2u - 1)` where u is uniform in [0, 1)

**Why arcsin?** Simple uniform latitude would cluster points at poles. The arcsin distribution ensures equal probability per unit area on the sphere surface.

---

## Data Generators

### Name Generation

```sql
generate_full_name(p_state BIGINT, p_locale_code VARCHAR)
RETURNS (next_state BIGINT, result VARCHAR, gender VARCHAR)
```

**Variations**:
- 30% probability of title (Mr., Mrs., Dr., etc.)
- 40% probability of middle name
- 50/50 gender distribution

**Output Examples**:
- `Dr. James Michael Smith`
- `Anna Mueller`
- `Mrs. Sarah Johnson`

### Address Generation

```sql
generate_full_address(p_state BIGINT, p_locale_code VARCHAR)
RETURNS (next_state BIGINT, result TEXT)
```

**Locale-Specific Formatting**:

| Locale | Format |
|--------|--------|
| en_US | `123 Main Street, Apt 5, New York, NY 10001, United States` |
| de_DE | `Hauptstraße 42, Wohnung 3, 10115 Berlin, Deutschland` |

### Physical Attributes

```sql
generate_physical_attributes(p_state BIGINT, p_gender VARCHAR)
RETURNS (next_state BIGINT, height_cm DOUBLE, weight_kg DOUBLE)
```

**Distribution Parameters**:

| Attribute | Male (mean ± std) | Female (mean ± std) |
|-----------|-------------------|---------------------|
| Height | 175 ± 7 cm | 162 ± 6.5 cm |
| Weight | 80 ± 15 kg | 65 ± 13 kg |

**Note**: Weight is correlated with height deviation for realism.

### Phone Number

```sql
generate_phone_number(p_state BIGINT, p_locale_code VARCHAR)
RETURNS (next_state BIGINT, result VARCHAR)
```

**Format Patterns** (# = random digit):
- US: `(###) ###-####`
- DE: `0### #######`

30% probability of including country code prefix.

### Email

```sql
generate_email(p_state BIGINT, p_locale_code VARCHAR, p_full_name VARCHAR)
RETURNS (next_state BIGINT, result VARCHAR)
```

**Format Variations**:
1. `firstname.lastname@domain`
2. `firstnamelastname@domain`
3. `f.lastname@domain`
4. `firstname.lastname123@domain`
5. `firstname123@domain`
6. `lastname.firstname@domain`

---

## Main API

### `generate_fake_users`

Main entry point for generating batches of fake users.

```sql
generate_fake_users(
    p_locale_code VARCHAR(10),
    p_seed BIGINT,
    p_batch_index INT DEFAULT 0,
    p_batch_size INT DEFAULT 10,
    p_include_bio BOOLEAN DEFAULT FALSE
) RETURNS SETOF fake_user
```

**Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| p_locale_code | VARCHAR(10) | required | Locale identifier (en_US, de_DE) |
| p_seed | BIGINT | required | Seed for reproducible generation |
| p_batch_index | INT | 0 | Batch number (0-based) |
| p_batch_size | INT | 10 | Users per batch (1-100) |
| p_include_bio | BOOLEAN | FALSE | Include Markov chain bio text |

**Return Type** (`fake_user`):
```sql
(
    record_index INT,
    full_name VARCHAR(200),
    gender VARCHAR(10),
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    height_cm NUMERIC(5,1),
    weight_kg NUMERIC(5,1),
    eye_color VARCHAR(50),
    phone VARCHAR(50),
    email VARCHAR(200),
    bio TEXT
)
```

### `benchmark_generation`

Measures generation performance.

```sql
benchmark_generation(
    p_locale_code VARCHAR(10) DEFAULT 'en_US',
    p_iterations INT DEFAULT 100
) RETURNS TABLE (users_generated INT, duration_ms DOUBLE, users_per_second DOUBLE)
```

---

## Usage Examples

### Generate 10 users
```sql
SELECT * FROM generate_fake_users('en_US', 12345, 0, 10, FALSE);
```

### Generate next batch (same seed)
```sql
SELECT * FROM generate_fake_users('en_US', 12345, 1, 10, FALSE);
```

### German locale
```sql
SELECT * FROM generate_fake_users('de_DE', 99999, 0, 20, FALSE);
```

### Run benchmark
```sql
SELECT * FROM benchmark_generation('en_US', 1000);
```

---

## Extending the Library

### Adding a New Locale

1. Insert into `locales` table:
```sql
INSERT INTO locales (code, name, country_code, phone_country_code)
VALUES ('fr_FR', 'French (France)', 'FR', '+33');
```

2. Add names to `lookup_names`
3. Add cities/states/streets
4. Add phone formats

### Adding New Data Types

1. Create lookup table with `locale_code` field
2. Create generator function following the pattern:
   - Accept `p_state BIGINT` and `p_locale_code VARCHAR`
   - Return `(next_state BIGINT, result TYPE)`
   - Use existing random utilities

---

## Supported Locales

| Code | Name | Data Points |
|------|------|-------------|
| en_US | English (USA) | 400 first names, 500 last names, 200 cities |
| de_DE | German (Germany) | 400 first names, 500 last names, 150 cities |

**Capacity**: Supports generating 10,000 to 1,000,000+ unique user profiles.

---

## Reproducibility Guarantee

The system guarantees that:
```sql
SELECT * FROM generate_fake_users('en_US', 12345, 0, 10);
```

Will **always** produce the exact same 10 users, regardless of:
- Time of execution
- Database server
- System configuration

This is achieved through:
1. Deterministic seed generation per record
2. Pure functional PRNG (no external state)
3. Stable ordering in lookup queries (`ORDER BY id`)

---

## Performance

Typical benchmark results:

| Users | Time | Throughput |
|-------|------|------------|
| 100 | ~50ms | ~2,000/sec |
| 1,000 | ~400ms | ~2,500/sec |
| 10,000 | ~4s | ~2,500/sec |

Performance is primarily bound by lookup table access and function call overhead.
