-- =====================================================
-- Random Number Generation Utilities
-- Deterministic PRNG based on seed
-- =====================================================

-- =====================================================
-- FUNCTION: generate_deterministic_seed
-- Purpose: Creates a unique seed for each user record
-- Algorithm: Combines locale, seed, batch, and index using prime mixing
-- =====================================================
CREATE OR REPLACE FUNCTION generate_deterministic_seed(
    p_locale_code VARCHAR(10),
    p_seed BIGINT,
    p_batch_index INT,
    p_record_index INT
) RETURNS BIGINT
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_locale_hash BIGINT;
    v_combined BIGINT;
    v_safe_seed BIGINT;
BEGIN
    v_locale_hash := ('x' || substr(md5(p_locale_code), 1, 8))::bit(32)::BIGINT;
    v_safe_seed := p_seed & 2147483647;
    v_combined := (
        (v_safe_seed * 31337) +
        (p_batch_index * 65537) +
        (p_record_index * 257) +
        v_locale_hash
    ) & 2147483647;
    
    RETURN v_combined;
END;
$$;

-- =====================================================
-- FUNCTION: lcg_next
-- Purpose: Linear Congruential Generator - core PRNG
-- Algorithm: LCG with parameters from Numerical Recipes
-- Returns: Next state and normalized value [0, 1)
-- =====================================================
CREATE OR REPLACE FUNCTION lcg_next(
    p_state BIGINT,
    OUT next_state BIGINT,
    OUT random_value DOUBLE PRECISION
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    c_multiplier CONSTANT BIGINT := 1103515245;
    c_increment CONSTANT BIGINT := 12345;
    c_modulus CONSTANT BIGINT := 2147483648;
    v_safe_state BIGINT;
BEGIN
    v_safe_state := p_state & 2147483647;
    next_state := ((v_safe_state * c_multiplier + c_increment) % c_modulus);
    random_value := next_state::DOUBLE PRECISION / c_modulus::DOUBLE PRECISION;
END;
$$;

-- =====================================================
-- FUNCTION: random_int_range
-- Purpose: Generate random integer in range [min, max]
-- Uses current state and returns new state
-- =====================================================
CREATE OR REPLACE FUNCTION random_int_range(
    p_state BIGINT,
    p_min INT,
    p_max INT,
    OUT next_state BIGINT,
    OUT result INT
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_random DOUBLE PRECISION;
BEGIN
    SELECT lcg.next_state, lcg.random_value 
    INTO next_state, v_random
    FROM lcg_next(p_state) lcg;
    
    result := p_min + FLOOR(v_random * (p_max - p_min + 1))::INT;
END;
$$;

-- =====================================================
-- FUNCTION: random_double_range
-- Purpose: Generate random double in range [min, max)
-- =====================================================
CREATE OR REPLACE FUNCTION random_double_range(
    p_state BIGINT,
    p_min DOUBLE PRECISION,
    p_max DOUBLE PRECISION,
    OUT next_state BIGINT,
    OUT result DOUBLE PRECISION
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_random DOUBLE PRECISION;
BEGIN
    SELECT lcg.next_state, lcg.random_value 
    INTO next_state, v_random
    FROM lcg_next(p_state) lcg;
    
    result := p_min + v_random * (p_max - p_min);
END;
$$;

-- =====================================================
-- FUNCTION: random_normal
-- Purpose: Generate normally distributed random value
-- Algorithm: Box-Muller transform
-- =====================================================
CREATE OR REPLACE FUNCTION random_normal(
    p_state BIGINT,
    p_mean DOUBLE PRECISION,
    p_stddev DOUBLE PRECISION,
    OUT next_state BIGINT,
    OUT result DOUBLE PRECISION
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_u1 DOUBLE PRECISION;
    v_u2 DOUBLE PRECISION;
    v_z DOUBLE PRECISION;
    v_state BIGINT;
BEGIN
    -- First uniform random
    SELECT lcg.next_state, lcg.random_value 
    INTO v_state, v_u1
    FROM lcg_next(p_state) lcg;
    
    -- Avoid log(0)
    IF v_u1 < 0.0001 THEN v_u1 := 0.0001; END IF;
    
    -- Second uniform random
    SELECT lcg.next_state, lcg.random_value 
    INTO next_state, v_u2
    FROM lcg_next(v_state) lcg;
    
    -- Box-Muller transform (using only one of the two generated values)
    v_z := SQRT(-2.0 * LN(v_u1)) * COS(2.0 * PI() * v_u2);
    
    -- Transform to desired mean and stddev
    result := p_mean + v_z * p_stddev;
END;
$$;

-- =====================================================
-- FUNCTION: random_normal_bounded
-- Purpose: Normal distribution with bounds (truncated normal)
-- =====================================================
CREATE OR REPLACE FUNCTION random_normal_bounded(
    p_state BIGINT,
    p_mean DOUBLE PRECISION,
    p_stddev DOUBLE PRECISION,
    p_min DOUBLE PRECISION,
    p_max DOUBLE PRECISION,
    OUT next_state BIGINT,
    OUT result DOUBLE PRECISION
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_attempts INT := 0;
    v_state BIGINT := p_state;
BEGIN
    -- Generate values until within bounds (rejection sampling)
    LOOP
        SELECT rn.next_state, rn.result 
        INTO v_state, result
        FROM random_normal(v_state, p_mean, p_stddev) rn;
        
        v_attempts := v_attempts + 1;
        
        -- Exit if within bounds or max attempts reached
        EXIT WHEN (result >= p_min AND result <= p_max) OR v_attempts > 100;
    END LOOP;
    
    -- Clamp if still out of bounds
    result := GREATEST(p_min, LEAST(p_max, result));
    next_state := v_state;
END;
$$;

-- =====================================================
-- FUNCTION: random_boolean
-- Purpose: Generate random boolean with given probability
-- =====================================================
CREATE OR REPLACE FUNCTION random_boolean(
    p_state BIGINT,
    p_probability DOUBLE PRECISION DEFAULT 0.5,
    OUT next_state BIGINT,
    OUT result BOOLEAN
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_random DOUBLE PRECISION;
BEGIN
    SELECT lcg.next_state, lcg.random_value 
    INTO next_state, v_random
    FROM lcg_next(p_state) lcg;
    
    result := v_random < p_probability;
END;
$$;

-- =====================================================
-- FUNCTION: random_element_index
-- Purpose: Pick random index from array (0-based)
-- =====================================================
CREATE OR REPLACE FUNCTION random_element_index(
    p_state BIGINT,
    p_array_length INT,
    OUT next_state BIGINT,
    OUT result INT
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    SELECT ri.next_state, ri.result 
    INTO next_state, result
    FROM random_int_range(p_state, 0, p_array_length - 1) ri;
END;
$$;

-- =====================================================
-- FUNCTION: random_latitude
-- Purpose: Generate uniformly distributed latitude on sphere
-- Algorithm: arcsin distribution (not uniform in degrees!)
-- For uniform distribution on sphere: lat = asin(2*u - 1)
-- =====================================================
CREATE OR REPLACE FUNCTION random_latitude(
    p_state BIGINT,
    OUT next_state BIGINT,
    OUT result DOUBLE PRECISION
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_u DOUBLE PRECISION;
BEGIN
    SELECT lcg.next_state, lcg.random_value 
    INTO next_state, v_u
    FROM lcg_next(p_state) lcg;
    
    -- arcsin distribution for uniform points on sphere
    result := DEGREES(ASIN(2.0 * v_u - 1.0));
END;
$$;

-- =====================================================
-- FUNCTION: random_longitude
-- Purpose: Generate uniformly distributed longitude
-- Simple uniform distribution [-180, 180)
-- =====================================================
CREATE OR REPLACE FUNCTION random_longitude(
    p_state BIGINT,
    OUT next_state BIGINT,
    OUT result DOUBLE PRECISION
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    SELECT rd.next_state, rd.result 
    INTO next_state, result
    FROM random_double_range(p_state, -180.0, 180.0) rd;
END;
$$;

-- =====================================================
-- FUNCTION: random_geo_coordinates
-- Purpose: Generate uniformly distributed point on sphere
-- Returns: latitude, longitude pair
-- =====================================================
CREATE OR REPLACE FUNCTION random_geo_coordinates(
    p_state BIGINT,
    OUT next_state BIGINT,
    OUT latitude DOUBLE PRECISION,
    OUT longitude DOUBLE PRECISION
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_state BIGINT;
BEGIN
    -- Generate latitude with proper spherical distribution
    SELECT rl.next_state, rl.result 
    INTO v_state, latitude
    FROM random_latitude(p_state) rl;
    
    -- Generate longitude uniformly
    SELECT rlo.next_state, rlo.result 
    INTO next_state, longitude
    FROM random_longitude(v_state) rlo;
END;
$$;

-- =====================================================
-- FUNCTION: random_digit
-- Purpose: Generate single random digit [0-9]
-- =====================================================
CREATE OR REPLACE FUNCTION random_digit(
    p_state BIGINT,
    OUT next_state BIGINT,
    OUT result CHAR(1)
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_digit INT;
BEGIN
    SELECT ri.next_state, ri.result 
    INTO next_state, v_digit
    FROM random_int_range(p_state, 0, 9) ri;
    
    result := v_digit::TEXT;
END;
$$;

-- =====================================================
-- FUNCTION: random_letter_lower
-- Purpose: Generate single random lowercase letter
-- =====================================================
CREATE OR REPLACE FUNCTION random_letter_lower(
    p_state BIGINT,
    OUT next_state BIGINT,
    OUT result CHAR(1)
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_index INT;
BEGIN
    SELECT ri.next_state, ri.result 
    INTO next_state, v_index
    FROM random_int_range(p_state, 0, 25) ri;
    
    result := CHR(97 + v_index);  -- 'a' = 97
END;
$$;

-- =====================================================
-- FUNCTION: random_alphanumeric
-- Purpose: Generate random alphanumeric string of given length
-- =====================================================
CREATE OR REPLACE FUNCTION random_alphanumeric(
    p_state BIGINT,
    p_length INT,
    OUT next_state BIGINT,
    OUT result VARCHAR
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_chars TEXT := 'abcdefghijklmnopqrstuvwxyz0123456789';
    v_chars_len INT := 36;
    v_result TEXT := '';
    v_index INT;
    i INT;
BEGIN
    FOR i IN 1..p_length LOOP
        SELECT ri.next_state, ri.result 
        INTO v_state, v_index
        FROM random_int_range(v_state, 1, v_chars_len) ri;
        
        v_result := v_result || SUBSTR(v_chars, v_index, 1);
    END LOOP;
    
    next_state := v_state;
    result := v_result;
END;
$$;
