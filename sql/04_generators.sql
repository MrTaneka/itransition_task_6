-- =====================================================
-- Data Generators
-- Individual functions for generating each data type
-- =====================================================

-- =====================================================
-- FUNCTION: get_lookup_count
-- Purpose: Get count of records in lookup table for locale
-- =====================================================
CREATE OR REPLACE FUNCTION get_lookup_count(
    p_table_name TEXT,
    p_locale_code VARCHAR(10),
    p_additional_filter TEXT DEFAULT NULL
) RETURNS INT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_count INT;
    v_query TEXT;
BEGIN
    v_query := format('SELECT COUNT(*)::INT FROM %I WHERE locale_code = $1', p_table_name);
    
    IF p_additional_filter IS NOT NULL THEN
        v_query := v_query || ' AND ' || p_additional_filter;
    END IF;
    
    EXECUTE v_query INTO v_count USING p_locale_code;
    RETURN COALESCE(v_count, 0);
END;
$$;

-- =====================================================
-- FUNCTION: generate_name_part
-- Purpose: Get a name from lookup table by type
-- =====================================================
CREATE OR REPLACE FUNCTION generate_name_part(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    p_name_type VARCHAR(20),
    p_gender VARCHAR(10) DEFAULT NULL,
    OUT next_state BIGINT,
    OUT result VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_count INT;
    v_index INT;
    v_offset INT;
BEGIN
    -- Get count of matching names
    IF p_gender IS NOT NULL THEN
        SELECT COUNT(*)::INT INTO v_count
        FROM lookup_names 
        WHERE locale_code = p_locale_code 
          AND name_type = p_name_type 
          AND (gender = p_gender OR gender = 'neutral');
    ELSE
        SELECT COUNT(*)::INT INTO v_count
        FROM lookup_names 
        WHERE locale_code = p_locale_code 
          AND name_type = p_name_type;
    END IF;
    
    IF v_count = 0 THEN
        next_state := p_state;
        result := 'Unknown';
        RETURN;
    END IF;
    
    -- Get random index
    SELECT ri.next_state, ri.result 
    INTO next_state, v_offset
    FROM random_int_range(p_state, 0, v_count - 1) ri;
    
    -- Fetch the name at that offset
    IF p_gender IS NOT NULL THEN
        SELECT n.value INTO result
        FROM lookup_names n
        WHERE n.locale_code = p_locale_code 
          AND n.name_type = p_name_type 
          AND (n.gender = p_gender OR n.gender = 'neutral')
        ORDER BY n.id
        OFFSET v_offset LIMIT 1;
    ELSE
        SELECT n.value INTO result
        FROM lookup_names n
        WHERE n.locale_code = p_locale_code 
          AND n.name_type = p_name_type
        ORDER BY n.id
        OFFSET v_offset LIMIT 1;
    END IF;
    
    result := COALESCE(result, 'Unknown');
END;
$$;

-- =====================================================
-- FUNCTION: generate_title
-- Purpose: Get a title (Mr., Mrs., Dr., etc.)
-- =====================================================
CREATE OR REPLACE FUNCTION generate_title(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    p_gender VARCHAR(10) DEFAULT NULL,
    OUT next_state BIGINT,
    OUT result VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_count INT;
    v_offset INT;
BEGIN
    -- Get count
    IF p_gender IS NOT NULL THEN
        SELECT COUNT(*)::INT INTO v_count
        FROM lookup_titles 
        WHERE locale_code = p_locale_code 
          AND (gender = p_gender OR gender IS NULL);
    ELSE
        SELECT COUNT(*)::INT INTO v_count
        FROM lookup_titles 
        WHERE locale_code = p_locale_code;
    END IF;
    
    IF v_count = 0 THEN
        next_state := p_state;
        result := '';
        RETURN;
    END IF;
    
    SELECT ri.next_state, ri.result 
    INTO next_state, v_offset
    FROM random_int_range(p_state, 0, v_count - 1) ri;
    
    IF p_gender IS NOT NULL THEN
        SELECT t.value INTO result
        FROM lookup_titles t
        WHERE t.locale_code = p_locale_code 
          AND (t.gender = p_gender OR t.gender IS NULL)
        ORDER BY t.id
        OFFSET v_offset LIMIT 1;
    ELSE
        SELECT t.value INTO result
        FROM lookup_titles t
        WHERE t.locale_code = p_locale_code
        ORDER BY t.id
        OFFSET v_offset LIMIT 1;
    END IF;
    
    result := COALESCE(result, '');
END;
$$;

-- =====================================================
-- FUNCTION: generate_full_name
-- Purpose: Generate full name with variations
-- Variations: with/without title, with/without middle name
-- =====================================================
CREATE OR REPLACE FUNCTION generate_full_name(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    OUT next_state BIGINT,
    OUT result VARCHAR,
    OUT gender VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_use_title BOOLEAN;
    v_use_middle BOOLEAN;
    v_title VARCHAR;
    v_first_name VARCHAR;
    v_middle_name VARCHAR;
    v_last_name VARCHAR;
    v_name_parts TEXT[];
    v_gender_choice INT;
BEGIN
    -- Decide gender (0=male, 1=female)
    SELECT ri.next_state, ri.result 
    INTO v_state, v_gender_choice
    FROM random_int_range(v_state, 0, 1) ri;
    
    gender := CASE WHEN v_gender_choice = 0 THEN 'male' ELSE 'female' END;
    
    -- Decide variations
    SELECT rb.next_state, rb.result 
    INTO v_state, v_use_title
    FROM random_boolean(v_state, 0.3) rb;  -- 30% chance of title
    
    SELECT rb.next_state, rb.result 
    INTO v_state, v_use_middle
    FROM random_boolean(v_state, 0.4) rb;  -- 40% chance of middle name
    
    -- Generate name parts
    IF v_use_title THEN
        SELECT gt.next_state, gt.result 
        INTO v_state, v_title
        FROM generate_title(v_state, p_locale_code, gender) gt;
    ELSE
        v_title := '';
    END IF;
    
    SELECT gnp.next_state, gnp.result 
    INTO v_state, v_first_name
    FROM generate_name_part(v_state, p_locale_code, 'first', gender) gnp;
    
    IF v_use_middle THEN
        SELECT gnp.next_state, gnp.result 
        INTO v_state, v_middle_name
        FROM generate_name_part(v_state, p_locale_code, 'middle', gender) gnp;
    ELSE
        v_middle_name := '';
    END IF;
    
    SELECT gnp.next_state, gnp.result 
    INTO v_state, v_last_name
    FROM generate_name_part(v_state, p_locale_code, 'last', NULL) gnp;
    
    -- Build full name
    v_name_parts := ARRAY[]::TEXT[];
    
    IF v_title != '' THEN
        v_name_parts := array_append(v_name_parts, v_title);
    END IF;
    
    v_name_parts := array_append(v_name_parts, v_first_name);
    
    IF v_middle_name != '' THEN
        v_name_parts := array_append(v_name_parts, v_middle_name);
    END IF;
    
    v_name_parts := array_append(v_name_parts, v_last_name);
    
    result := array_to_string(v_name_parts, ' ');
    next_state := v_state;
END;
$$;

-- =====================================================
-- FUNCTION: generate_street_address
-- Purpose: Generate street address
-- =====================================================
CREATE OR REPLACE FUNCTION generate_street_address(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    OUT next_state BIGINT,
    OUT result VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_count INT;
    v_offset INT;
    v_street_name VARCHAR;
    v_street_type VARCHAR;
    v_street_number INT;
    v_use_apt BOOLEAN;
    v_apt_number INT;
BEGIN
    -- Get random street
    SELECT COUNT(*)::INT INTO v_count FROM lookup_streets WHERE locale_code = p_locale_code;
    
    IF v_count = 0 THEN
        next_state := p_state;
        result := '123 Main Street';
        RETURN;
    END IF;
    
    SELECT ri.next_state, ri.result 
    INTO v_state, v_offset
    FROM random_int_range(v_state, 0, v_count - 1) ri;
    
    SELECT s.street_name, s.street_type INTO v_street_name, v_street_type
    FROM lookup_streets s
    WHERE s.locale_code = p_locale_code
    ORDER BY s.id
    OFFSET v_offset LIMIT 1;
    
    -- Generate street number
    SELECT ri.next_state, ri.result 
    INTO v_state, v_street_number
    FROM random_int_range(v_state, 1, 9999) ri;
    
    -- Maybe add apartment
    SELECT rb.next_state, rb.result 
    INTO v_state, v_use_apt
    FROM random_boolean(v_state, 0.25) rb;
    
    IF p_locale_code LIKE 'de_%' THEN
        -- German format: Straßenname Hausnummer
        result := v_street_name || v_street_type || ' ' || v_street_number;
        IF v_use_apt THEN
            SELECT ri.next_state, ri.result 
            INTO v_state, v_apt_number
            FROM random_int_range(v_state, 1, 50) ri;
            result := result || ', Wohnung ' || v_apt_number;
        END IF;
    ELSE
        -- US format: Number Street Type
        result := v_street_number || ' ' || v_street_name || ' ' || v_street_type;
        IF v_use_apt THEN
            SELECT ri.next_state, ri.result 
            INTO v_state, v_apt_number
            FROM random_int_range(v_state, 1, 500) ri;
            result := result || ', Apt ' || v_apt_number;
        END IF;
    END IF;
    
    next_state := v_state;
END;
$$;

-- =====================================================
-- FUNCTION: generate_postal_code
-- Purpose: Generate postal/ZIP code based on locale format
-- =====================================================
CREATE OR REPLACE FUNCTION generate_postal_code(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    OUT next_state BIGINT,
    OUT result VARCHAR
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_digit CHAR(1);
    v_result TEXT := '';
    v_format TEXT;
    v_char CHAR(1);
    i INT;
BEGIN
    -- Define format by locale
    IF p_locale_code LIKE 'de_%' THEN
        v_format := '#####';  -- German: 5 digits
    ELSE
        v_format := '#####';  -- US: 5 digits (could extend to ##### -####)
    END IF;
    
    -- Generate code based on format
    FOR i IN 1..LENGTH(v_format) LOOP
        v_char := SUBSTR(v_format, i, 1);
        IF v_char = '#' THEN
            SELECT rd.next_state, rd.result 
            INTO v_state, v_digit
            FROM random_digit(v_state) rd;
            v_result := v_result || v_digit;
        ELSE
            v_result := v_result || v_char;
        END IF;
    END LOOP;
    
    -- Avoid leading zero for some formats
    IF LEFT(v_result, 1) = '0' THEN
        v_result := '1' || SUBSTR(v_result, 2);
    END IF;
    
    next_state := v_state;
    result := v_result;
END;
$$;

-- =====================================================
-- FUNCTION: generate_city_state
-- Purpose: Generate city and state combination
-- =====================================================
CREATE OR REPLACE FUNCTION generate_city_state(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    OUT next_state BIGINT,
    OUT city VARCHAR,
    OUT state_name VARCHAR,
    OUT state_code VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_count INT;
    v_offset INT;
    v_state_code VARCHAR;
BEGIN
    -- Get random city
    SELECT COUNT(*)::INT INTO v_count FROM lookup_cities WHERE locale_code = p_locale_code;
    
    IF v_count = 0 THEN
        next_state := p_state;
        city := 'Unknown City';
        state_name := 'Unknown State';
        state_code := 'XX';
        RETURN;
    END IF;
    
    SELECT ri.next_state, ri.result 
    INTO v_state, v_offset
    FROM random_int_range(v_state, 0, v_count - 1) ri;
    
    SELECT c.city_name, c.state_code INTO city, v_state_code
    FROM lookup_cities c
    WHERE c.locale_code = p_locale_code
    ORDER BY c.id
    OFFSET v_offset LIMIT 1;
    
    state_code := v_state_code;
    
    -- Get state name
    SELECT s.state_name INTO state_name
    FROM lookup_states s
    WHERE s.locale_code = p_locale_code AND s.state_code = v_state_code
    LIMIT 1;
    
    state_name := COALESCE(state_name, v_state_code);
    next_state := v_state;
END;
$$;

-- =====================================================
-- FUNCTION: generate_full_address
-- Purpose: Generate complete address with all components
-- =====================================================
CREATE OR REPLACE FUNCTION generate_full_address(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    OUT next_state BIGINT,
    OUT result TEXT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_street VARCHAR;
    v_city VARCHAR;
    v_state_name VARCHAR;
    v_state_code VARCHAR;
    v_postal VARCHAR;
    v_country VARCHAR;
BEGIN
    -- Generate street address
    SELECT gsa.next_state, gsa.result 
    INTO v_state, v_street
    FROM generate_street_address(v_state, p_locale_code) gsa;
    
    -- Generate city and state
    SELECT gcs.next_state, gcs.city, gcs.state_name, gcs.state_code 
    INTO v_state, v_city, v_state_name, v_state_code
    FROM generate_city_state(v_state, p_locale_code) gcs;
    
    -- Generate postal code
    SELECT gpc.next_state, gpc.result 
    INTO v_state, v_postal
    FROM generate_postal_code(v_state, p_locale_code) gpc;
    
    -- Get country
    SELECT c.country_name INTO v_country
    FROM lookup_countries c
    WHERE c.locale_code = p_locale_code
    LIMIT 1;
    
    v_country := COALESCE(v_country, 'Unknown');
    
    -- Format address based on locale
    IF p_locale_code LIKE 'de_%' THEN
        -- German format
        result := v_street || E'\n' || 
                  v_postal || ' ' || v_city || E'\n' || 
                  v_country;
    ELSE
        -- US format
        result := v_street || E'\n' || 
                  v_city || ', ' || v_state_code || ' ' || v_postal || E'\n' || 
                  v_country;
    END IF;
    
    next_state := v_state;
END;
$$;

-- =====================================================
-- FUNCTION: generate_phone_number
-- Purpose: Generate phone number with locale format
-- =====================================================
CREATE OR REPLACE FUNCTION generate_phone_number(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    OUT next_state BIGINT,
    OUT result VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_count INT;
    v_offset INT;
    v_format VARCHAR;
    v_result TEXT := '';
    v_digit CHAR(1);
    v_char CHAR(1);
    v_country_code VARCHAR;
    i INT;
BEGIN
    -- Get phone format
    SELECT COUNT(*)::INT INTO v_count FROM lookup_phone_formats WHERE locale_code = p_locale_code;
    
    IF v_count > 0 THEN
        SELECT ri.next_state, ri.result 
        INTO v_state, v_offset
        FROM random_int_range(v_state, 0, v_count - 1) ri;
        
        SELECT f.format_pattern INTO v_format
        FROM lookup_phone_formats f
        WHERE f.locale_code = p_locale_code
        ORDER BY f.id
        OFFSET v_offset LIMIT 1;
    ELSE
        v_format := '(###) ###-####';
    END IF;
    
    -- Get country code
    SELECT l.phone_country_code INTO v_country_code
    FROM locales l
    WHERE l.code = p_locale_code
    LIMIT 1;
    
    v_country_code := COALESCE(v_country_code, '+1');
    
    -- Generate number based on format
    FOR i IN 1..LENGTH(v_format) LOOP
        v_char := SUBSTR(v_format, i, 1);
        IF v_char = '#' THEN
            SELECT rd.next_state, rd.result 
            INTO v_state, v_digit
            FROM random_digit(v_state) rd;
            v_result := v_result || v_digit;
        ELSE
            v_result := v_result || v_char;
        END IF;
    END LOOP;
    
    -- Sometimes include country code
    DECLARE v_include_country BOOLEAN;
    BEGIN
        SELECT rb.next_state, rb.result 
        INTO v_state, v_include_country
        FROM random_boolean(v_state, 0.3) rb;
        
        IF v_include_country THEN
            result := v_country_code || ' ' || v_result;
        ELSE
            result := v_result;
        END IF;
    END;
    
    next_state := v_state;
END;
$$;

-- =====================================================
-- FUNCTION: generate_email
-- Purpose: Generate email address from name
-- =====================================================
CREATE OR REPLACE FUNCTION generate_email(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    p_full_name VARCHAR,
    OUT next_state BIGINT,
    OUT result VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_format_choice INT;
    v_domain VARCHAR;
    v_count INT;
    v_offset INT;
    v_local_part VARCHAR;
    v_name_parts TEXT[];
    v_random_num INT;
    v_random_str VARCHAR;
BEGIN
    -- Parse name
    v_name_parts := string_to_array(LOWER(TRIM(p_full_name)), ' ');
    -- Remove title if present
    IF v_name_parts[1] IN ('mr.', 'mrs.', 'ms.', 'dr.', 'herr', 'frau') THEN
        v_name_parts := v_name_parts[2:array_length(v_name_parts, 1)];
    END IF;
    
    -- Choose email format
    SELECT ri.next_state, ri.result 
    INTO v_state, v_format_choice
    FROM random_int_range(v_state, 1, 6) ri;
    
    -- Get random number for uniqueness
    SELECT ri.next_state, ri.result 
    INTO v_state, v_random_num
    FROM random_int_range(v_state, 1, 999) ri;
    
    -- Generate local part based on format
    CASE v_format_choice
        WHEN 1 THEN  -- firstname.lastname
            v_local_part := v_name_parts[1] || '.' || v_name_parts[array_length(v_name_parts, 1)];
        WHEN 2 THEN  -- firstnamelastname
            v_local_part := v_name_parts[1] || v_name_parts[array_length(v_name_parts, 1)];
        WHEN 3 THEN  -- f.lastname
            v_local_part := LEFT(v_name_parts[1], 1) || '.' || v_name_parts[array_length(v_name_parts, 1)];
        WHEN 4 THEN  -- firstname.lastname123
            v_local_part := v_name_parts[1] || '.' || v_name_parts[array_length(v_name_parts, 1)] || v_random_num;
        WHEN 5 THEN  -- firstname123
            v_local_part := v_name_parts[1] || v_random_num;
        ELSE  -- lastname.firstname
            v_local_part := v_name_parts[array_length(v_name_parts, 1)] || '.' || v_name_parts[1];
    END CASE;
    
    -- Clean up special characters
    v_local_part := REGEXP_REPLACE(v_local_part, '[^a-z0-9._]', '', 'g');
    
    -- Get domain
    SELECT COUNT(*)::INT INTO v_count 
    FROM lookup_domains 
    WHERE locale_code = p_locale_code OR locale_code IS NULL;
    
    IF v_count > 0 THEN
        SELECT ri.next_state, ri.result 
        INTO v_state, v_offset
        FROM random_int_range(v_state, 0, v_count - 1) ri;
        
        SELECT d.domain_name INTO v_domain
        FROM lookup_domains d
        WHERE d.locale_code = p_locale_code OR d.locale_code IS NULL
        ORDER BY d.id
        OFFSET v_offset LIMIT 1;
    ELSE
        v_domain := 'example.com';
    END IF;
    
    result := v_local_part || '@' || v_domain;
    next_state := v_state;
END;
$$;

-- =====================================================
-- FUNCTION: generate_eye_color
-- Purpose: Generate eye color with locale-specific distribution
-- =====================================================
CREATE OR REPLACE FUNCTION generate_eye_color(
    p_state BIGINT,
    p_locale_code VARCHAR(10),
    OUT next_state BIGINT,
    OUT result VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_count INT;
    v_offset INT;
BEGIN
    SELECT COUNT(*)::INT INTO v_count FROM lookup_eye_colors WHERE locale_code = p_locale_code;
    
    IF v_count = 0 THEN
        next_state := p_state;
        result := 'Brown';
        RETURN;
    END IF;
    
    SELECT ri.next_state, ri.result 
    INTO next_state, v_offset
    FROM random_int_range(p_state, 0, v_count - 1) ri;
    
    SELECT e.color_name INTO result
    FROM lookup_eye_colors e
    WHERE e.locale_code = p_locale_code
    ORDER BY e.id
    OFFSET v_offset LIMIT 1;
    
    result := COALESCE(result, 'Brown');
END;
$$;

-- =====================================================
-- FUNCTION: generate_physical_attributes
-- Purpose: Generate height, weight with normal distribution
-- =====================================================
CREATE OR REPLACE FUNCTION generate_physical_attributes(
    p_state BIGINT,
    p_gender VARCHAR(10),
    OUT next_state BIGINT,
    OUT height_cm DOUBLE PRECISION,
    OUT weight_kg DOUBLE PRECISION
)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_state BIGINT := p_state;
    v_height_mean DOUBLE PRECISION;
    v_height_stddev DOUBLE PRECISION;
    v_weight_mean DOUBLE PRECISION;
    v_weight_stddev DOUBLE PRECISION;
BEGIN
    -- Set parameters based on gender (approximate real-world distributions)
    IF p_gender = 'male' THEN
        v_height_mean := 175.0;    -- cm
        v_height_stddev := 7.0;
        v_weight_mean := 80.0;     -- kg
        v_weight_stddev := 15.0;
    ELSE
        v_height_mean := 162.0;    -- cm
        v_height_stddev := 6.5;
        v_weight_mean := 65.0;     -- kg
        v_weight_stddev := 13.0;
    END IF;
    
    -- Generate height (bounded)
    SELECT rnb.next_state, rnb.result 
    INTO v_state, height_cm
    FROM random_normal_bounded(v_state, v_height_mean, v_height_stddev, 140.0, 220.0) rnb;
    
    -- Generate weight (bounded, and correlated somewhat with height)
    -- Adjust mean based on height deviation
    v_weight_mean := v_weight_mean + (height_cm - v_height_mean) * 0.5;
    
    SELECT rnb.next_state, rnb.result 
    INTO next_state, weight_kg
    FROM random_normal_bounded(v_state, v_weight_mean, v_weight_stddev, 40.0, 200.0) rnb;
END;
$$;
