# Faker SQL

**Professional Fake User Data Generator** powered by PostgreSQL Stored Procedures.

![Faker SQL](https://img.shields.io/badge/PostgreSQL-14%2B-blue?logo=postgresql) ![Python](https://img.shields.io/badge/Python-3.10%2B-yellow?logo=python) ![Docker](https://img.shields.io/badge/Docker-Supported-blue?logo=docker) ![License](https://img.shields.io/badge/License-MIT-green)

---

## 📚 Documentation

**[Read full technical documentation here](docs/DOCUMENTATION.md)**

## 🚀 Live Demo
**[https://faker-sql.onrender.com](https://faker-sql-n6sb.onrender.com/)**

---

## Overview

Faker SQL is a high-performance, database-native library for generating deterministic, reproducible fake user data. Unlike traditional generators that run in application code, Faker SQL executes entirely within PostgreSQL using PL/pgSQL stored procedures.

### Key Features

| Feature | Description |
|---------|-------------|
| **Deterministic Generation** | Same seed + same settings = exact same data, always. |
| **High Performance** | Generates thousands of records per second directly in the DB. |
| **Multiple Locales** | Supports `en_US` (USA) and `de_DE` (Germany) out of the box. |
| **Rich Data Types** | Names, addresses, phones, emails, physical stats, and bio. |
| **Realistic Distributions** | Normal distribution for heights/weights, uniform sphere for coords. |
| **Batch Processing** | Generate 10 or 10,000 users in a single efficient query. |

---

## 🛠 Architecture

### Design Principles

- **Extensibility**: All data is stored in normalized lookup tables. Adding a locale is just an `INSERT`.
- **Reproducibility**: Uses a custom implementation of Linear Congruential Generator (LCG) inside SQL.
- **Modularity**: Small, single-responsibility SQL functions (`generate_name`, `generate_email`, etc.).

### Technology Stack

- **Database**: PostgreSQL 14+
- **Backend**: Python Flask (Web Interface)
- **Deployment**: Render.com / Docker

---

## ⚡ Quick Start

### 1. Requirements
- PostgreSQL 14 or higher
- Python 3.10+

### 2. Installation

```bash
# Clone repository
git clone https://github.com/MrTaneka/itransition_task_6.git
cd faker-sql

# Create database
psql -U postgres -c "CREATE DATABASE facker_db;"
psql -U postgres -c "CREATE USER facker_db_user WITH PASSWORD 'password';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE facker_db TO facker_db_user;"

# Run SQL scripts (in order)
psql -d facker_db -f sql/init.sql
psql -d facker_db -f sql/03_random_utils.sql
psql -d facker_db -f sql/04_generators.sql
psql -d facker_db -f sql/05_main_procedure.sql
```

### 3. Run Web App

```bash
# Install dependencies
pip install -r requirements.txt

# Run server
export DATABASE_URL="postgresql://facker_db_user:password@localhost/facker_db"
python -m app.main
```

---

## 📖 Main API

### SQL Generation
The core function to generate users:

```sql
SELECT * FROM generate_fake_users(
    p_locale_code := 'en_US',
    p_seed := 12345,
    p_batch_index := 0,
    p_batch_size := 10,
    p_include_bio := false
);
```

### Benchmark
Measure performance directly in SQL:

```sql
SELECT * FROM benchmark_generation('en_US', 1000);
```

## 🌍 Supported Locales

| Locale | Code | Features |
|--------|------|----------|
| 🇺🇸 English (US) | `en_US` | US Addresses, Phones, Names |
| 🇩🇪 German | `de_DE` | DE Addresses, Phones, Names |
