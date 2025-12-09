-- =====================================================
-- Main Procedure and Markov Chain Text Generator
-- =====================================================

-- =====================================================
-- FUNCTION: generate_markov_text
-- Purpose: Generate text using Markov chain
-- Algorithm: N-gram based text generation
-- =====================================================
CREATE OR REPLACE FUNCTION generate_markov_text(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    p_max_words INT DEFAULT 50,
    OUT next_state BIGINT,
    OUT result TEXT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_current_prefix VARCHAR(200);
    v_next_word VARCHAR(100);
    v_words TEXT[];
    v_count INT;
    v_offset INT;
    v_word_count INT := 0;
    v_attempts INT := 0;
BEGIN
    -- Check if we have Markov data
    SELECT COUNT(*) INTO v_count 
    FROM lookup_markov_chains 
    WHERE locale_code = p_locale_code AND chain_type = 'word';
    
    IF v_count = 0 THEN
        -- Fallback to Lorem Ipsum style
        result := 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
        next_state := p_state;
        RETURN;
    END IF;
    
    -- Start with a random prefix that begins a sentence
    SELECT ri.next_state, ri.result 
    INTO v_state, v_offset
    FROM random_int_range(v_state, 0, LEAST(v_count - 1, 100)) ri;
    
    SELECT mc.prefix INTO v_current_prefix
    FROM lookup_markov_chains mc
    WHERE mc.locale_code = p_locale_code 
      AND mc.chain_type = 'word'
      AND (mc.prefix LIKE 'START %' OR mc.prefix = 'START')
    ORDER BY mc.id
    OFFSET v_offset LIMIT 1;
    
    IF v_current_prefix IS NULL THEN
        SELECT mc.prefix INTO v_current_prefix
        FROM lookup_markov_chains mc
        WHERE mc.locale_code = p_locale_code AND mc.chain_type = 'word'
        ORDER BY mc.id LIMIT 1;
    END IF;
    
    v_words := ARRAY[]::TEXT[];
    
    -- Generate words
    WHILE v_word_count < p_max_words AND v_attempts < p_max_words * 2 LOOP
        v_attempts := v_attempts + 1;
        
        -- Get count of possible next words
        SELECT COUNT(*) INTO v_count
        FROM lookup_markov_chains
        WHERE locale_code = p_locale_code 
          AND chain_type = 'word'
          AND prefix = v_current_prefix;
        
        EXIT WHEN v_count = 0;
        
        -- Pick random next word
        SELECT ri.next_state, ri.result 
        INTO v_state, v_offset
        FROM random_int_range(v_state, 0, v_count - 1) ri;
        
        SELECT mc.suffix INTO v_next_word
        FROM lookup_markov_chains mc
        WHERE mc.locale_code = p_locale_code 
          AND mc.chain_type = 'word'
          AND mc.prefix = v_current_prefix
        ORDER BY mc.id
        OFFSET v_offset LIMIT 1;
        
        IF v_next_word IS NOT NULL AND v_next_word != 'END' THEN
            v_words := array_append(v_words, v_next_word);
            v_word_count := v_word_count + 1;
            
            -- Update prefix (sliding window)
            v_current_prefix := SPLIT_PART(v_current_prefix, ' ', 2) || ' ' || v_next_word;
        ELSE
            -- End of sentence reached, try to continue
            SELECT mc.prefix INTO v_current_prefix
            FROM lookup_markov_chains mc
            WHERE mc.locale_code = p_locale_code 
              AND mc.chain_type = 'word'
              AND mc.prefix LIKE 'START %'
            ORDER BY RANDOM() LIMIT 1;
        END IF;
    END LOOP;
    
    -- Build result
    IF array_length(v_words, 1) > 0 THEN
        result := INITCAP(array_to_string(v_words, ' ')) || '.';
    ELSE
        result := 'Text generation unavailable.';
    END IF;
    
    next_state := v_state;
END;
$$;

-- =====================================================
-- TYPE: fake_user
-- Purpose: Structure for generated user data
-- =====================================================
DROP TYPE IF EXISTS fake_user CASCADE;
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

-- =====================================================
-- FUNCTION: generate_single_user
-- Purpose: Generate one complete fake user record
-- =====================================================
CREATE OR REPLACE FUNCTION generate_single_user(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    p_record_index INT,
    p_include_bio BOOLEAN DEFAULT FALSE
) RETURNS fake_user
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_user fake_user;
    v_full_name VARCHAR;
    v_gender VARCHAR;
    v_address TEXT;
    v_lat DOUBLE PRECISION;
    v_lon DOUBLE PRECISION;
    v_height DOUBLE PRECISION;
    v_weight DOUBLE PRECISION;
    v_eye_color VARCHAR;
    v_phone VARCHAR;
    v_email VARCHAR;
    v_bio TEXT;
BEGIN
    v_user.record_index := p_record_index;
    
    -- Generate full name
    SELECT gfn.next_state, gfn.result, gfn.gender 
    INTO v_state, v_full_name, v_gender
    FROM generate_full_name(v_state, p_locale_code) gfn;
    
    v_user.full_name := v_full_name;
    v_user.gender := v_gender;
    
    -- Generate address
    SELECT gfa.next_state, gfa.result 
    INTO v_state, v_address
    FROM generate_full_address(v_state, p_locale_code) gfa;
    
    v_user.address := v_address;
    
    -- Generate geo coordinates (uniformly on sphere)
    SELECT rgc.next_state, rgc.latitude, rgc.longitude 
    INTO v_state, v_lat, v_lon
    FROM random_geo_coordinates(v_state) rgc;
    
    v_user.latitude := ROUND(v_lat::NUMERIC, 6);
    v_user.longitude := ROUND(v_lon::NUMERIC, 6);
    
    -- Generate physical attributes (normal distribution)
    SELECT gpa.next_state, gpa.height_cm, gpa.weight_kg 
    INTO v_state, v_height, v_weight
    FROM generate_physical_attributes(v_state, v_gender) gpa;
    
    v_user.height_cm := ROUND(v_height::NUMERIC, 1);
    v_user.weight_kg := ROUND(v_weight::NUMERIC, 1);
    
    -- Generate eye color
    SELECT gec.next_state, gec.result 
    INTO v_state, v_eye_color
    FROM generate_eye_color(v_state, p_locale_code) gec;
    
    v_user.eye_color := v_eye_color;
    
    -- Generate phone
    SELECT gpn.next_state, gpn.result 
    INTO v_state, v_phone
    FROM generate_phone_number(v_state, p_locale_code) gpn;
    
    v_user.phone := v_phone;
    
    -- Generate email
    SELECT ge.next_state, ge.result 
    INTO v_state, v_email
    FROM generate_email(v_state, p_locale_code, v_full_name) ge;
    
    v_user.email := v_email;
    
    -- Generate bio if requested
    IF p_include_bio THEN
        SELECT gmt.next_state, gmt.result 
        INTO v_state, v_bio
        FROM generate_markov_text(v_state, p_locale_code, 30) gmt;
        
        v_user.bio := v_bio;
    ELSE
        v_user.bio := NULL;
    END IF;
    
    RETURN v_user;
END;
$$;

-- =====================================================
-- FUNCTION: generate_fake_users
-- Purpose: Main entry point - generate batch of users
-- Parameters:
--   p_locale_code: Locale (e.g., 'en_US', 'de_DE')
--   p_seed: Seed value for reproducibility
--   p_batch_index: Batch number (0-based)
--   p_batch_size: Number of users per batch
--   p_include_bio: Include generated text bio
-- =====================================================
CREATE OR REPLACE FUNCTION generate_fake_users(
    p_locale_code VARCHAR(10),
    p_seed BIGINT,
    p_batch_index INT DEFAULT 0,
    p_batch_size INT DEFAULT 10,
    p_include_bio BOOLEAN DEFAULT FALSE
) RETURNS SETOF fake_user
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_record_start INT;
    v_record_index INT;
    v_user_seed BIGINT;
    v_user fake_user;
    i INT;
BEGIN
    -- Calculate starting record index for this batch
    v_record_start := p_batch_index * p_batch_size;
    
    -- Generate each user in the batch
    FOR i IN 0..(p_batch_size - 1) LOOP
        v_record_index := v_record_start + i;
        
        -- Generate unique seed for this user
        v_user_seed := generate_deterministic_seed(
            p_locale_code,
            p_seed,
            p_batch_index,
            i
        );
        
        -- Generate the user
        v_user := generate_single_user(
            v_user_seed,
            p_locale_code,
            v_record_index,
            p_include_bio
        );
        
        RETURN NEXT v_user;
    END LOOP;
    
    RETURN;
END;
$$;

-- =====================================================
-- FUNCTION: benchmark_generation
-- Purpose: Measure generation speed
-- Returns: Users per second
-- =====================================================
CREATE OR REPLACE FUNCTION benchmark_generation(
    p_locale_code VARCHAR(10) DEFAULT 'en_US',
    p_iterations INT DEFAULT 100
) RETURNS TABLE (
    users_generated INT,
    duration_ms DOUBLE PRECISION,
    users_per_second DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_duration DOUBLE PRECISION;
    v_dummy_count INT;
BEGIN
    v_start_time := clock_timestamp();
    
    -- Generate users
    SELECT COUNT(*) INTO v_dummy_count
    FROM generate_fake_users(p_locale_code, 12345, 0, p_iterations, FALSE);
    
    v_end_time := clock_timestamp();
    v_duration := EXTRACT(EPOCH FROM (v_end_time - v_start_time)) * 1000;
    
    users_generated := p_iterations;
    duration_ms := ROUND(v_duration::NUMERIC, 2);
    users_per_second := ROUND((p_iterations * 1000.0 / v_duration)::NUMERIC, 2);
    
    RETURN NEXT;
END;
$$;

-- =====================================================
-- FUNCTION: get_available_locales
-- Purpose: List available locales
-- =====================================================
CREATE OR REPLACE FUNCTION get_available_locales()
RETURNS TABLE (
    code VARCHAR(10),
    name VARCHAR(100)
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT l.code, l.name
    FROM locales l
    ORDER BY l.name;
END;
$$;
