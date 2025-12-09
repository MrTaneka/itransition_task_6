# Faker SQL - Documentation

## Overview

Faker SQL is a PostgreSQL-based fake data generation library implemented entirely as SQL stored procedures. It provides deterministic, reproducible generation of realistic fake user data with support for multiple locales.

## Architecture

### Design Principles

1. **Extensibility**: Single lookup tables with `locale_code` field instead of separate tables per locale
2. **Reproducibility**: Deterministic PRNG ensures identical seeds produce identical results
3. **Modularity**: Small, focused functions following SOLID principles
4. **Performance**: Optimized for batch generation with minimal database round-trips

### Database Schema

```
locales                  - Locale configuration
lookup_names            - First, middle, last names by locale
lookup_titles           - Honorific titles (Mr., Mrs., etc.)
lookup_streets          - Street names and types
lookup_cities           - City names with state codes
lookup_states           - State/region names and codes
lookup_countries        - Country names
lookup_domains          - Email domains
lookup_eye_colors       - Eye colors with frequency weights
lookup_phone_formats    - Phone number format patterns
lookup_address_formats  - Address formatting templates
lookup_markov_chains    - Markov chain data for text generation
```

## Core Functions

### Random Number Generation

#### `generate_deterministic_seed(locale_code, seed, batch_index, record_index) → BIGINT`

Creates a unique deterministic seed for each record by combining:
- Locale code (hashed via MD5)
- User-provided seed
- Batch index
- Record index within batch

**Algorithm**: Uses prime number mixing with overflow protection:
```
safe_seed = seed & 2147483647  // 31-bit mask
combined = (safe_seed * 31337 + batch_index * 65537 + 
           record_index * 257 + locale_hash) & 2147483647
```

#### `lcg_next(state) → (next_state, random_value)`

Linear Congruential Generator - the core PRNG.

**Algorithm**: Uses Numerical Recipes constants:
```
next = (state * 1103515245 + 12345) mod 2^31
value = next / 2^31  // Normalized to [0, 1)
```

**Properties**:
- Period: 2^31
- Full period guaranteed with these constants
- Fast single multiplication + addition

#### `random_int_range(state, min, max) → (next_state, result)`

Generates integer in range [min, max] inclusive.

**Algorithm**:
```
result = min + floor(random_value * (max - min + 1))
```

#### `random_double_range(state, min, max) → (next_state, result)`

Generates double in range [min, max).

**Algorithm**: Linear interpolation:
```
result = min + random_value * (max - min)
```

### Normal Distribution

#### `random_normal(state, mean, stddev) → (next_state, result)`

Generates normally distributed values using Box-Muller transform.

**Algorithm**:
```
u1, u2 = two uniform random values in (0, 1)
z = sqrt(-2 * ln(u1)) * cos(2π * u2)
result = mean + z * stddev
```

**Properties**:
- Produces true normal distribution
- Uses two uniform values to generate one normal value
- Guard against log(0) with minimum threshold

#### `random_normal_bounded(state, mean, stddev, min, max) → (next_state, result)`

Truncated normal distribution with bounds using rejection sampling.

**Algorithm**:
1. Generate value from normal distribution
2. If within bounds, accept
3. Otherwise, regenerate (max 100 attempts)
4. Clamp if still out of bounds

### Spherical Coordinates

#### `random_latitude(state) → (next_state, result)`

Generates latitude uniformly distributed on sphere surface.

**Algorithm**: Uses arcsin distribution (NOT uniform in degrees):
```
u = uniform random in [0, 1)
latitude = arcsin(2u - 1) * (180/π)
```

**Mathematical Basis**:
- Simple uniform latitude would cluster points at poles
- arcsin distribution ensures uniform area coverage
- Derived from: dA = cos(lat) d(lat) d(lon)

#### `random_longitude(state) → (next_state, result)`

Generates longitude uniformly in [-180, 180).

**Algorithm**: Simple linear mapping:
```
longitude = -180 + random_value * 360
```

#### `random_geo_coordinates(state) → (next_state, latitude, longitude)`

Combines latitude and longitude generation for complete coordinates.

### Data Generators

#### `generate_full_name(state, locale_code) → (next_state, result, gender)`

Generates complete name with variations.

**Variations** (probabilistic):
- 30% chance of title (Mr., Mrs., Dr., etc.)
- 40% chance of middle name
- 50/50 male/female gender

**Format**:
```
[Title] FirstName [MiddleName] LastName
```

#### `generate_full_address(state, locale_code) → (next_state, result)`

Generates complete formatted address.

**Components**:
- Street address (number + name + type)
- Optional apartment number (25% chance)
- City
- State/Province
- Postal code
- Country

**Format by locale**:
- en_US: `123 Main Street, City, ST 12345, United States`
- de_DE: `Hauptstraße 123, 12345 Berlin, Deutschland`

#### `generate_phone_number(state, locale_code) → (next_state, result)`

Generates phone number from locale-specific formats.

**Format patterns**:
- `#` replaced with random digit
- en_US: `(###) ###-####`
- de_DE: `0### #######`

**Features**:
- 30% chance of including country code
- Multiple format variations per locale

#### `generate_email(state, locale_code, full_name) → (next_state, result)`

Generates email address based on name.

**Format variations** (random selection):
1. `firstname.lastname@domain`
2. `firstnamelastname@domain`
3. `f.lastname@domain`
4. `firstname.lastname123@domain`
5. `firstname123@domain`
6. `lastname.firstname@domain`

**Domain selection**:
- Universal domains (gmail, yahoo, etc.)
- Locale-specific domains (gmx.de, t-online.de)

#### `generate_physical_attributes(state, gender) → (next_state, height_cm, weight_kg)`

Generates height and weight using normal distribution.

**Parameters by gender**:

| Attribute | Male | Female |
|-----------|------|--------|
| Height mean | 175 cm | 162 cm |
| Height stddev | 7 cm | 6.5 cm |
| Weight mean | 80 kg | 65 kg |
| Weight stddev | 15 kg | 13 kg |

**Correlation**: Weight is correlated with height:
```
adjusted_weight_mean = base_mean + (height - height_mean) * 0.5
```

**Bounds**: Height [140, 220] cm, Weight [40, 200] kg

### Markov Chain Text Generation

#### `generate_markov_text(state, locale_code, max_words) → (next_state, result)`

Generates pseudo-random text using word-level Markov chains.

**Algorithm**:
1. Start with random sentence-starting prefix
2. Look up possible suffix words
3. Select random suffix weighted by frequency
4. Slide window: new prefix = last word of old prefix + new word
5. Continue until max words or END token

**Data structure** (lookup_markov_chains):
- prefix: 1-2 word N-gram
- suffix: following word
- frequency: occurrence count for weighting

**Special tokens**:
- `START`: Marks sentence beginnings
- `END`: Marks sentence endings

## Main Entry Point

### `generate_fake_users(locale_code, seed, batch_index, batch_size, include_bio) → SETOF fake_user`

Main function for generating batches of fake users.

**Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| locale_code | VARCHAR(10) | - | Locale identifier |
| seed | BIGINT | - | Seed for reproducibility |
| batch_index | INT | 0 | Batch number (0-based) |
| batch_size | INT | 10 | Users per batch |
| include_bio | BOOLEAN | FALSE | Generate Markov text bio |

**Returns**: Set of `fake_user` composite type:
```sql
CREATE TYPE fake_user AS (
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
);
```

**Usage**:
```sql
SELECT * FROM generate_fake_users('en_US', 12345, 0, 10, FALSE);
```

### `benchmark_generation(locale_code, iterations) → TABLE`

Measures generation performance.

**Returns**:
- users_generated: Count of users generated
- duration_ms: Time in milliseconds
- users_per_second: Throughput rate

## Supported Locales

| Code | Name | Features |
|------|------|----------|
| en_US | English (USA) | 400 first names, 500 last names, 200 cities, US phone formats |
| de_DE | German (Germany) | 400 first names, 500 last names, 150 cities, German phone formats |

## Reproducibility Guarantee

The system guarantees that:
```
generate_fake_users('en_US', 12345, 0, 10) 
```
Will **always** produce the exact same 10 users, regardless of:
- Time of execution
- Database state
- Server configuration

This is achieved through:
1. Deterministic seed generation per record
2. Pure functional PRNG (no external state)
3. Stable ordering in lookup queries (ORDER BY id)

## Performance Characteristics

Typical benchmark results (PostgreSQL 14, modern hardware):

| Users | Time | Rate |
|-------|------|------|
| 100 | ~50ms | ~2,000/sec |
| 1,000 | ~400ms | ~2,500/sec |
| 10,000 | ~4s | ~2,500/sec |

Performance is primarily bound by:
- Lookup table access patterns
- Function call overhead
- String manipulation

## Extending the Library

### Adding a New Locale

1. Add locale to `locales` table
2. Insert names into `lookup_names`
3. Insert cities/states/streets
4. Add phone formats
5. Optionally add Markov chain data

### Adding New Data Types

1. Create lookup table with `locale_code` field
2. Create generator function following pattern:
   - Accept state and locale_code
   - Return (next_state, result)
   - Use existing random utilities

## API Reference Summary

| Function | Purpose |
|----------|---------|
| `generate_fake_users` | Main entry point |
| `generate_single_user` | Generate one user |
| `generate_full_name` | Name with variations |
| `generate_full_address` | Complete address |
| `generate_phone_number` | Formatted phone |
| `generate_email` | Email from name |
| `generate_physical_attributes` | Height/weight |
| `generate_eye_color` | Eye color selection |
| `random_geo_coordinates` | Uniform sphere point |
| `generate_markov_text` | Random text |
| `benchmark_generation` | Performance test |
| `get_available_locales` | List locales |
