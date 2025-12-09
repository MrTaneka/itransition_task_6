-- =====================================================
-- Faker SQL Database Schema
-- Extensible design with locale support
-- =====================================================

-- Drop existing objects for clean slate
DROP TABLE IF EXISTS lookup_names CASCADE;
DROP TABLE IF EXISTS lookup_streets CASCADE;
DROP TABLE IF EXISTS lookup_cities CASCADE;
DROP TABLE IF EXISTS lookup_states CASCADE;
DROP TABLE IF EXISTS lookup_countries CASCADE;
DROP TABLE IF EXISTS lookup_domains CASCADE;
DROP TABLE IF EXISTS lookup_eye_colors CASCADE;
DROP TABLE IF EXISTS lookup_titles CASCADE;
DROP TABLE IF EXISTS lookup_phone_formats CASCADE;
DROP TABLE IF EXISTS lookup_address_formats CASCADE;
DROP TABLE IF EXISTS lookup_markov_chains CASCADE;
DROP TABLE IF EXISTS locales CASCADE;

-- =====================================================
-- LOCALE TABLE - Central configuration for each locale
-- =====================================================
CREATE TABLE locales (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,        -- e.g., 'en_US', 'de_DE'
    name VARCHAR(100) NOT NULL,               -- e.g., 'English (USA)'
    country_code VARCHAR(5) NOT NULL,         -- e.g., 'US', 'DE'
    phone_country_code VARCHAR(10) NOT NULL,  -- e.g., '+1', '+49'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- LOOKUP TABLES - All use locale field for extensibility
-- =====================================================

-- Names lookup (first names, last names, middle names)
CREATE TABLE lookup_names (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    name_type VARCHAR(20) NOT NULL,  -- 'first', 'last', 'middle'
    gender VARCHAR(10),              -- 'male', 'female', 'neutral'
    value VARCHAR(100) NOT NULL,
    frequency INT DEFAULT 1,         -- For weighted random selection
    CONSTRAINT fk_names_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- Titles (Mr., Mrs., Dr., etc.)
CREATE TABLE lookup_titles (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    gender VARCHAR(10),
    value VARCHAR(50) NOT NULL,
    CONSTRAINT fk_titles_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- Street names
CREATE TABLE lookup_streets (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    street_type VARCHAR(50) NOT NULL,  -- 'Street', 'Avenue', 'Straße', etc.
    street_name VARCHAR(100) NOT NULL,
    CONSTRAINT fk_streets_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- Cities
CREATE TABLE lookup_cities (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    city_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(10),
    postal_code_format VARCHAR(20),  -- e.g., '#####' or '##### ###'
    CONSTRAINT fk_cities_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- States/Regions
CREATE TABLE lookup_states (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(10) NOT NULL,
    CONSTRAINT fk_states_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- Countries
CREATE TABLE lookup_countries (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(5) NOT NULL,
    CONSTRAINT fk_countries_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- Email domains
CREATE TABLE lookup_domains (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10),  -- NULL means universal
    domain_name VARCHAR(100) NOT NULL,
    domain_type VARCHAR(20) DEFAULT 'generic'  -- 'generic', 'corporate', 'educational'
);

-- Eye colors
CREATE TABLE lookup_eye_colors (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    color_name VARCHAR(50) NOT NULL,
    frequency INT DEFAULT 1,  -- For weighted selection based on population
    CONSTRAINT fk_eye_colors_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- Phone number formats (with placeholders)
CREATE TABLE lookup_phone_formats (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    format_pattern VARCHAR(50) NOT NULL,  -- e.g., '(###) ###-####'
    CONSTRAINT fk_phone_formats_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- Address format templates
CREATE TABLE lookup_address_formats (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    format_template VARCHAR(500) NOT NULL,
    -- Placeholders: {street_number}, {street}, {apt}, {city}, {state}, {postal}, {country}
    CONSTRAINT fk_address_formats_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- Markov chain data for text generation
CREATE TABLE lookup_markov_chains (
    id SERIAL PRIMARY KEY,
    locale_code VARCHAR(10) NOT NULL,
    chain_type VARCHAR(50) NOT NULL,  -- 'sentence', 'word'
    prefix VARCHAR(200) NOT NULL,      -- N-gram prefix
    suffix VARCHAR(100) NOT NULL,      -- Following element
    frequency INT DEFAULT 1,
    CONSTRAINT fk_markov_locale FOREIGN KEY (locale_code) 
        REFERENCES locales(code) ON DELETE CASCADE
);

-- =====================================================
-- INDEXES for performance
-- =====================================================
CREATE INDEX idx_names_locale_type ON lookup_names(locale_code, name_type);
CREATE INDEX idx_names_locale_type_gender ON lookup_names(locale_code, name_type, gender);
CREATE INDEX idx_streets_locale ON lookup_streets(locale_code);
CREATE INDEX idx_cities_locale ON lookup_cities(locale_code);
CREATE INDEX idx_states_locale ON lookup_states(locale_code);
CREATE INDEX idx_domains_locale ON lookup_domains(locale_code);
CREATE INDEX idx_eye_colors_locale ON lookup_eye_colors(locale_code);
CREATE INDEX idx_phone_formats_locale ON lookup_phone_formats(locale_code);
CREATE INDEX idx_address_formats_locale ON lookup_address_formats(locale_code);
CREATE INDEX idx_markov_locale_type ON lookup_markov_chains(locale_code, chain_type);
CREATE INDEX idx_markov_prefix ON lookup_markov_chains(locale_code, chain_type, prefix);
