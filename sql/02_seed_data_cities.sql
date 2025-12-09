-- =====================================================
-- Seed Data Part 3 - Cities, States, Domains, etc.
-- =====================================================

-- =====================================================
-- US STATES (50)
-- =====================================================
INSERT INTO lookup_states (locale_code, state_name, state_code) VALUES
('en_US', 'Alabama', 'AL'), ('en_US', 'Alaska', 'AK'), ('en_US', 'Arizona', 'AZ'),
('en_US', 'Arkansas', 'AR'), ('en_US', 'California', 'CA'), ('en_US', 'Colorado', 'CO'),
('en_US', 'Connecticut', 'CT'), ('en_US', 'Delaware', 'DE'), ('en_US', 'Florida', 'FL'),
('en_US', 'Georgia', 'GA'), ('en_US', 'Hawaii', 'HI'), ('en_US', 'Idaho', 'ID'),
('en_US', 'Illinois', 'IL'), ('en_US', 'Indiana', 'IN'), ('en_US', 'Iowa', 'IA'),
('en_US', 'Kansas', 'KS'), ('en_US', 'Kentucky', 'KY'), ('en_US', 'Louisiana', 'LA'),
('en_US', 'Maine', 'ME'), ('en_US', 'Maryland', 'MD'), ('en_US', 'Massachusetts', 'MA'),
('en_US', 'Michigan', 'MI'), ('en_US', 'Minnesota', 'MN'), ('en_US', 'Mississippi', 'MS'),
('en_US', 'Missouri', 'MO'), ('en_US', 'Montana', 'MT'), ('en_US', 'Nebraska', 'NE'),
('en_US', 'Nevada', 'NV'), ('en_US', 'New Hampshire', 'NH'), ('en_US', 'New Jersey', 'NJ'),
('en_US', 'New Mexico', 'NM'), ('en_US', 'New York', 'NY'), ('en_US', 'North Carolina', 'NC'),
('en_US', 'North Dakota', 'ND'), ('en_US', 'Ohio', 'OH'), ('en_US', 'Oklahoma', 'OK'),
('en_US', 'Oregon', 'OR'), ('en_US', 'Pennsylvania', 'PA'), ('en_US', 'Rhode Island', 'RI'),
('en_US', 'South Carolina', 'SC'), ('en_US', 'South Dakota', 'SD'), ('en_US', 'Tennessee', 'TN'),
('en_US', 'Texas', 'TX'), ('en_US', 'Utah', 'UT'), ('en_US', 'Vermont', 'VT'),
('en_US', 'Virginia', 'VA'), ('en_US', 'Washington', 'WA'), ('en_US', 'West Virginia', 'WV'),
('en_US', 'Wisconsin', 'WI'), ('en_US', 'Wyoming', 'WY');

-- =====================================================
-- GERMAN STATES (16)
-- =====================================================
INSERT INTO lookup_states (locale_code, state_name, state_code) VALUES
('de_DE', 'Baden-Württemberg', 'BW'), ('de_DE', 'Bayern', 'BY'), ('de_DE', 'Berlin', 'BE'),
('de_DE', 'Brandenburg', 'BB'), ('de_DE', 'Bremen', 'HB'), ('de_DE', 'Hamburg', 'HH'),
('de_DE', 'Hessen', 'HE'), ('de_DE', 'Mecklenburg-Vorpommern', 'MV'), ('de_DE', 'Niedersachsen', 'NI'),
('de_DE', 'Nordrhein-Westfalen', 'NW'), ('de_DE', 'Rheinland-Pfalz', 'RP'), ('de_DE', 'Saarland', 'SL'),
('de_DE', 'Sachsen', 'SN'), ('de_DE', 'Sachsen-Anhalt', 'ST'), ('de_DE', 'Schleswig-Holstein', 'SH'),
('de_DE', 'Thüringen', 'TH');

-- =====================================================
-- US CITIES (200)
-- =====================================================
INSERT INTO lookup_cities (locale_code, city_name, state_code) VALUES
('en_US', 'New York', 'NY'), ('en_US', 'Los Angeles', 'CA'), ('en_US', 'Chicago', 'IL'),
('en_US', 'Houston', 'TX'), ('en_US', 'Phoenix', 'AZ'), ('en_US', 'Philadelphia', 'PA'),
('en_US', 'San Antonio', 'TX'), ('en_US', 'San Diego', 'CA'), ('en_US', 'Dallas', 'TX'),
('en_US', 'San Jose', 'CA'), ('en_US', 'Austin', 'TX'), ('en_US', 'Jacksonville', 'FL'),
('en_US', 'Fort Worth', 'TX'), ('en_US', 'Columbus', 'OH'), ('en_US', 'Charlotte', 'NC'),
('en_US', 'San Francisco', 'CA'), ('en_US', 'Indianapolis', 'IN'), ('en_US', 'Seattle', 'WA'),
('en_US', 'Denver', 'CO'), ('en_US', 'Washington', 'DC'), ('en_US', 'Boston', 'MA'),
('en_US', 'El Paso', 'TX'), ('en_US', 'Nashville', 'TN'), ('en_US', 'Detroit', 'MI'),
('en_US', 'Oklahoma City', 'OK'), ('en_US', 'Portland', 'OR'), ('en_US', 'Las Vegas', 'NV'),
('en_US', 'Memphis', 'TN'), ('en_US', 'Louisville', 'KY'), ('en_US', 'Baltimore', 'MD'),
('en_US', 'Milwaukee', 'WI'), ('en_US', 'Albuquerque', 'NM'), ('en_US', 'Tucson', 'AZ'),
('en_US', 'Fresno', 'CA'), ('en_US', 'Sacramento', 'CA'), ('en_US', 'Kansas City', 'MO'),
('en_US', 'Mesa', 'AZ'), ('en_US', 'Atlanta', 'GA'), ('en_US', 'Omaha', 'NE'),
('en_US', 'Colorado Springs', 'CO'), ('en_US', 'Raleigh', 'NC'), ('en_US', 'Long Beach', 'CA'),
('en_US', 'Virginia Beach', 'VA'), ('en_US', 'Miami', 'FL'), ('en_US', 'Oakland', 'CA'),
('en_US', 'Minneapolis', 'MN'), ('en_US', 'Tulsa', 'OK'), ('en_US', 'Bakersfield', 'CA'),
('en_US', 'Wichita', 'KS'), ('en_US', 'Arlington', 'TX'), ('en_US', 'Aurora', 'CO'),
('en_US', 'Tampa', 'FL'), ('en_US', 'New Orleans', 'LA'), ('en_US', 'Cleveland', 'OH'),
('en_US', 'Anaheim', 'CA'), ('en_US', 'Honolulu', 'HI'), ('en_US', 'Henderson', 'NV'),
('en_US', 'Stockton', 'CA'), ('en_US', 'Lexington', 'KY'), ('en_US', 'Corpus Christi', 'TX'),
('en_US', 'Riverside', 'CA'), ('en_US', 'Santa Ana', 'CA'), ('en_US', 'Orlando', 'FL'),
('en_US', 'Irvine', 'CA'), ('en_US', 'Cincinnati', 'OH'), ('en_US', 'Newark', 'NJ'),
('en_US', 'Saint Paul', 'MN'), ('en_US', 'Pittsburgh', 'PA'), ('en_US', 'Greensboro', 'NC'),
('en_US', 'St. Louis', 'MO'), ('en_US', 'Lincoln', 'NE'), ('en_US', 'Plano', 'TX'),
('en_US', 'Anchorage', 'AK'), ('en_US', 'Durham', 'NC'), ('en_US', 'Jersey City', 'NJ'),
('en_US', 'Chandler', 'AZ'), ('en_US', 'Chula Vista', 'CA'), ('en_US', 'Buffalo', 'NY'),
('en_US', 'Gilbert', 'AZ'), ('en_US', 'Madison', 'WI'), ('en_US', 'Reno', 'NV'),
('en_US', 'Toledo', 'OH'), ('en_US', 'Fort Wayne', 'IN'), ('en_US', 'Lubbock', 'TX'),
('en_US', 'St. Petersburg', 'FL'), ('en_US', 'Laredo', 'TX'), ('en_US', 'Irving', 'TX'),
('en_US', 'Chesapeake', 'VA'), ('en_US', 'Glendale', 'AZ'), ('en_US', 'Winston-Salem', 'NC'),
('en_US', 'Scottsdale', 'AZ'), ('en_US', 'Garland', 'TX'), ('en_US', 'Boise', 'ID'),
('en_US', 'Norfolk', 'VA'), ('en_US', 'Spokane', 'WA'), ('en_US', 'Fremont', 'CA'),
('en_US', 'Richmond', 'VA'), ('en_US', 'Santa Clarita', 'CA'), ('en_US', 'San Bernardino', 'CA'),
('en_US', 'Baton Rouge', 'LA'), ('en_US', 'Hialeah', 'FL'), ('en_US', 'Tacoma', 'WA'),
('en_US', 'Modesto', 'CA'), ('en_US', 'Port St. Lucie', 'FL'), ('en_US', 'Huntsville', 'AL'),
('en_US', 'Des Moines', 'IA'), ('en_US', 'Moreno Valley', 'CA'), ('en_US', 'Fontana', 'CA'),
('en_US', 'Frisco', 'TX'), ('en_US', 'Rochester', 'NY'), ('en_US', 'Yonkers', 'NY'),
('en_US', 'Fayetteville', 'NC'), ('en_US', 'Worcester', 'MA'), ('en_US', 'Columbus', 'GA'),
('en_US', 'Cape Coral', 'FL'), ('en_US', 'McKinney', 'TX'), ('en_US', 'Little Rock', 'AR'),
('en_US', 'Oxnard', 'CA'), ('en_US', 'Amarillo', 'TX'), ('en_US', 'Augusta', 'GA'),
('en_US', 'Salt Lake City', 'UT'), ('en_US', 'Montgomery', 'AL'), ('en_US', 'Birmingham', 'AL'),
('en_US', 'Grand Rapids', 'MI'), ('en_US', 'Grand Prairie', 'TX'), ('en_US', 'Overland Park', 'KS'),
('en_US', 'Tallahassee', 'FL'), ('en_US', 'Huntington Beach', 'CA'), ('en_US', 'Sioux Falls', 'SD'),
('en_US', 'Peoria', 'AZ'), ('en_US', 'Knoxville', 'TN'), ('en_US', 'Glendale', 'CA'),
('en_US', 'Vancouver', 'WA'), ('en_US', 'Providence', 'RI'), ('en_US', 'Akron', 'OH'),
('en_US', 'Brownsville', 'TX'), ('en_US', 'Mobile', 'AL'), ('en_US', 'Newport News', 'VA'),
('en_US', 'Tempe', 'AZ'), ('en_US', 'Shreveport', 'LA'), ('en_US', 'Chattanooga', 'TN'),
('en_US', 'Fort Lauderdale', 'FL'), ('en_US', 'Aurora', 'IL'), ('en_US', 'Elk Grove', 'CA'),
('en_US', 'Ontario', 'CA'), ('en_US', 'Salem', 'OR'), ('en_US', 'Cary', 'NC'),
('en_US', 'Santa Rosa', 'CA'), ('en_US', 'Rancho Cucamonga', 'CA'), ('en_US', 'Eugene', 'OR'),
('en_US', 'Oceanside', 'CA'), ('en_US', 'Clarksville', 'TN'), ('en_US', 'Garden Grove', 'CA'),
('en_US', 'Lancaster', 'CA'), ('en_US', 'Springfield', 'MO'), ('en_US', 'Pembroke Pines', 'FL'),
('en_US', 'Fort Collins', 'CO'), ('en_US', 'Palmdale', 'CA'), ('en_US', 'Salinas', 'CA'),
('en_US', 'Hayward', 'CA'), ('en_US', 'Corona', 'CA'), ('en_US', 'Paterson', 'NJ'),
('en_US', 'Murfreesboro', 'TN'), ('en_US', 'Macon', 'GA'), ('en_US', 'Lakewood', 'CO'),
('en_US', 'Killeen', 'TX'), ('en_US', 'Springfield', 'MA'), ('en_US', 'Alexandria', 'VA'),
('en_US', 'Kansas City', 'KS'), ('en_US', 'Sunnyvale', 'CA'), ('en_US', 'Hollywood', 'FL'),
('en_US', 'Roseville', 'CA'), ('en_US', 'Charleston', 'SC'), ('en_US', 'Escondido', 'CA'),
('en_US', 'Joliet', 'IL'), ('en_US', 'Jackson', 'MS'), ('en_US', 'Bellevue', 'WA'),
('en_US', 'Surprise', 'AZ'), ('en_US', 'Naperville', 'IL'), ('en_US', 'Pasadena', 'TX'),
('en_US', 'Pomona', 'CA'), ('en_US', 'Bridgeport', 'CT'), ('en_US', 'Denton', 'TX'),
('en_US', 'Rockford', 'IL'), ('en_US', 'Mesquite', 'TX'), ('en_US', 'Savannah', 'GA'),
('en_US', 'Syracuse', 'NY'), ('en_US', 'McAllen', 'TX'), ('en_US', 'Torrance', 'CA'),
('en_US', 'Olathe', 'KS'), ('en_US', 'Visalia', 'CA'), ('en_US', 'Thornton', 'CO'),
('en_US', 'Fullerton', 'CA'), ('en_US', 'Gainesville', 'FL'), ('en_US', 'Waco', 'TX');

-- =====================================================
-- GERMAN CITIES (150)
-- =====================================================
INSERT INTO lookup_cities (locale_code, city_name, state_code) VALUES
('de_DE', 'Berlin', 'BE'), ('de_DE', 'Hamburg', 'HH'), ('de_DE', 'München', 'BY'),
('de_DE', 'Köln', 'NW'), ('de_DE', 'Frankfurt am Main', 'HE'), ('de_DE', 'Stuttgart', 'BW'),
('de_DE', 'Düsseldorf', 'NW'), ('de_DE', 'Leipzig', 'SN'), ('de_DE', 'Dortmund', 'NW'),
('de_DE', 'Essen', 'NW'), ('de_DE', 'Bremen', 'HB'), ('de_DE', 'Dresden', 'SN'),
('de_DE', 'Hannover', 'NI'), ('de_DE', 'Nürnberg', 'BY'), ('de_DE', 'Duisburg', 'NW'),
('de_DE', 'Bochum', 'NW'), ('de_DE', 'Wuppertal', 'NW'), ('de_DE', 'Bielefeld', 'NW'),
('de_DE', 'Bonn', 'NW'), ('de_DE', 'Münster', 'NW'), ('de_DE', 'Karlsruhe', 'BW'),
('de_DE', 'Mannheim', 'BW'), ('de_DE', 'Augsburg', 'BY'), ('de_DE', 'Wiesbaden', 'HE'),
('de_DE', 'Mönchengladbach', 'NW'), ('de_DE', 'Gelsenkirchen', 'NW'), ('de_DE', 'Braunschweig', 'NI'),
('de_DE', 'Aachen', 'NW'), ('de_DE', 'Kiel', 'SH'), ('de_DE', 'Chemnitz', 'SN'),
('de_DE', 'Halle', 'ST'), ('de_DE', 'Magdeburg', 'ST'), ('de_DE', 'Freiburg im Breisgau', 'BW'),
('de_DE', 'Krefeld', 'NW'), ('de_DE', 'Mainz', 'RP'), ('de_DE', 'Lübeck', 'SH'),
('de_DE', 'Erfurt', 'TH'), ('de_DE', 'Oberhausen', 'NW'), ('de_DE', 'Rostock', 'MV'),
('de_DE', 'Kassel', 'HE'), ('de_DE', 'Hagen', 'NW'), ('de_DE', 'Potsdam', 'BB'),
('de_DE', 'Saarbrücken', 'SL'), ('de_DE', 'Hamm', 'NW'), ('de_DE', 'Ludwigshafen', 'RP'),
('de_DE', 'Oldenburg', 'NI'), ('de_DE', 'Mülheim an der Ruhr', 'NW'), ('de_DE', 'Osnabrück', 'NI'),
('de_DE', 'Leverkusen', 'NW'), ('de_DE', 'Heidelberg', 'BW'), ('de_DE', 'Darmstadt', 'HE'),
('de_DE', 'Solingen', 'NW'), ('de_DE', 'Regensburg', 'BY'), ('de_DE', 'Herne', 'NW'),
('de_DE', 'Paderborn', 'NW'), ('de_DE', 'Neuss', 'NW'), ('de_DE', 'Ingolstadt', 'BY'),
('de_DE', 'Offenbach am Main', 'HE'), ('de_DE', 'Fürth', 'BY'), ('de_DE', 'Würzburg', 'BY'),
('de_DE', 'Ulm', 'BW'), ('de_DE', 'Heilbronn', 'BW'), ('de_DE', 'Pforzheim', 'BW'),
('de_DE', 'Wolfsburg', 'NI'), ('de_DE', 'Göttingen', 'NI'), ('de_DE', 'Bottrop', 'NW'),
('de_DE', 'Reutlingen', 'BW'), ('de_DE', 'Koblenz', 'RP'), ('de_DE', 'Bremerhaven', 'HB'),
('de_DE', 'Bergisch Gladbach', 'NW'), ('de_DE', 'Jena', 'TH'), ('de_DE', 'Erlangen', 'BY'),
('de_DE', 'Remscheid', 'NW'), ('de_DE', 'Trier', 'RP'), ('de_DE', 'Salzgitter', 'NI'),
('de_DE', 'Moers', 'NW'), ('de_DE', 'Siegen', 'NW'), ('de_DE', 'Hildesheim', 'NI'),
('de_DE', 'Cottbus', 'BB'), ('de_DE', 'Gütersloh', 'NW'), ('de_DE', 'Kaiserslautern', 'RP'),
('de_DE', 'Witten', 'NW'), ('de_DE', 'Schwerin', 'MV'), ('de_DE', 'Gera', 'TH'),
('de_DE', 'Iserlohn', 'NW'), ('de_DE', 'Hanau', 'HE'), ('de_DE', 'Esslingen', 'BW'),
('de_DE', 'Ludwigsburg', 'BW'), ('de_DE', 'Zwickau', 'SN'), ('de_DE', 'Tübingen', 'BW'),
('de_DE', 'Flensburg', 'SH'), ('de_DE', 'Ratingen', 'NW'), ('de_DE', 'Lünen', 'NW'),
('de_DE', 'Villingen-Schwenningen', 'BW'), ('de_DE', 'Konstanz', 'BW'), ('de_DE', 'Marl', 'NW'),
('de_DE', 'Worms', 'RP'), ('de_DE', 'Velbert', 'NW'), ('de_DE', 'Minden', 'NW'),
('de_DE', 'Neumünster', 'SH'), ('de_DE', 'Dessau-Roßlau', 'ST'), ('de_DE', 'Norderstedt', 'SH'),
('de_DE', 'Delmenhorst', 'NI'), ('de_DE', 'Bamberg', 'BY'), ('de_DE', 'Viersen', 'NW'),
('de_DE', 'Marburg', 'HE'), ('de_DE', 'Rheine', 'NW'), ('de_DE', 'Gladbeck', 'NW'),
('de_DE', 'Lüdenscheid', 'NW'), ('de_DE', 'Wilhelmshaven', 'NI'), ('de_DE', 'Dorsten', 'NW'),
('de_DE', 'Troisdorf', 'NW'), ('de_DE', 'Arnsberg', 'NW'), ('de_DE', 'Detmold', 'NW'),
('de_DE', 'Castrop-Rauxel', 'NW'), ('de_DE', 'Lüneburg', 'NI'), ('de_DE', 'Landshut', 'BY'),
('de_DE', 'Brandenburg an der Havel', 'BB'), ('de_DE', 'Bayreuth', 'BY'), ('de_DE', 'Bocholt', 'NW'),
('de_DE', 'Aschaffenburg', 'BY'), ('de_DE', 'Celle', 'NI'), ('de_DE', 'Kempten', 'BY'),
('de_DE', 'Fulda', 'HE'), ('de_DE', 'Aalen', 'BW'), ('de_DE', 'Lippstadt', 'NW'),
('de_DE', 'Dinslaken', 'NW'), ('de_DE', 'Herford', 'NW'), ('de_DE', 'Kerpen', 'NW'),
('de_DE', 'Plauen', 'SN'), ('de_DE', 'Weimar', 'TH'), ('de_DE', 'Neuwied', 'RP'),
('de_DE', 'Dormagen', 'NW'), ('de_DE', 'Grevenbroich', 'NW'), ('de_DE', 'Herten', 'NW'),
('de_DE', 'Bergheim', 'NW'), ('de_DE', 'Rosenheim', 'BY'), ('de_DE', 'Schwäbisch Gmünd', 'BW'),
('de_DE', 'Friedrichshafen', 'BW'), ('de_DE', 'Wesel', 'NW'), ('de_DE', 'Garbsen', 'NI'),
('de_DE', 'Hürth', 'NW'), ('de_DE', 'Unna', 'NW'), ('de_DE', 'Stralsund', 'MV'),
('de_DE', 'Langenfeld', 'NW'), ('de_DE', 'Sindelfingen', 'BW'), ('de_DE', 'Greifswald', 'MV'),
('de_DE', 'Offenburg', 'BW'), ('de_DE', 'Görlitz', 'SN'), ('de_DE', 'Böblingen', 'BW');

-- =====================================================
-- COUNTRIES
-- =====================================================
INSERT INTO lookup_countries (locale_code, country_name, country_code) VALUES
('en_US', 'United States', 'US'),
('de_DE', 'Deutschland', 'DE');

-- =====================================================
-- EMAIL DOMAINS
-- =====================================================
INSERT INTO lookup_domains (locale_code, domain_name, domain_type) VALUES
(NULL, 'gmail.com', 'generic'),
(NULL, 'yahoo.com', 'generic'),
(NULL, 'hotmail.com', 'generic'),
(NULL, 'outlook.com', 'generic'),
(NULL, 'icloud.com', 'generic'),
(NULL, 'protonmail.com', 'generic'),
(NULL, 'mail.com', 'generic'),
(NULL, 'aol.com', 'generic'),
('en_US', 'comcast.net', 'generic'),
('en_US', 'verizon.net', 'generic'),
('en_US', 'att.net', 'generic'),
('de_DE', 'gmx.de', 'generic'),
('de_DE', 'web.de', 'generic'),
('de_DE', 't-online.de', 'generic'),
('de_DE', 'freenet.de', 'generic'),
('de_DE', 'mail.de', 'generic'),
('de_DE', 'posteo.de', 'generic');

-- =====================================================
-- EYE COLORS (with realistic frequency)
-- =====================================================
INSERT INTO lookup_eye_colors (locale_code, color_name, frequency) VALUES
('en_US', 'Brown', 45),
('en_US', 'Blue', 27),
('en_US', 'Hazel', 18),
('en_US', 'Green', 9),
('en_US', 'Gray', 1),
('de_DE', 'Blau', 40),
('de_DE', 'Braun', 35),
('de_DE', 'Grün', 15),
('de_DE', 'Grau', 8),
('de_DE', 'Haselnuss', 2);

-- =====================================================
-- PHONE NUMBER FORMATS
-- =====================================================
INSERT INTO lookup_phone_formats (locale_code, format_pattern) VALUES
('en_US', '(###) ###-####'),
('en_US', '###-###-####'),
('en_US', '### ### ####'),
('de_DE', '0### #######'),
('de_DE', '0### ########'),
('de_DE', '+49 ### #######'),
('de_DE', '0###/#######');

-- =====================================================
-- MARKOV CHAIN DATA FOR ENGLISH
-- (Sample data for text generation)
-- =====================================================
INSERT INTO lookup_markov_chains (locale_code, chain_type, prefix, suffix, frequency) VALUES
-- English sentence starters
('en_US', 'word', 'START', 'The', 10),
('en_US', 'word', 'START', 'A', 8),
('en_US', 'word', 'START', 'This', 6),
('en_US', 'word', 'START', 'In', 5),
('en_US', 'word', 'START', 'When', 4),
('en_US', 'word', 'START', 'After', 3),
('en_US', 'word', 'START', 'Before', 3),
('en_US', 'word', 'START', 'Many', 3),
('en_US', 'word', 'START', 'Some', 3),
('en_US', 'word', 'START', 'People', 2),
-- English word transitions
('en_US', 'word', 'The', 'quick', 3),
('en_US', 'word', 'The', 'important', 3),
('en_US', 'word', 'The', 'main', 3),
('en_US', 'word', 'The', 'best', 2),
('en_US', 'word', 'The', 'first', 2),
('en_US', 'word', 'quick', 'brown', 2),
('en_US', 'word', 'quick', 'response', 2),
('en_US', 'word', 'brown', 'fox', 2),
('en_US', 'word', 'fox', 'jumps', 2),
('en_US', 'word', 'jumps', 'over', 2),
('en_US', 'word', 'over', 'the', 2),
('en_US', 'word', 'the', 'lazy', 2),
('en_US', 'word', 'lazy', 'dog', 2),
('en_US', 'word', 'important', 'thing', 2),
('en_US', 'word', 'thing', 'is', 2),
('en_US', 'word', 'is', 'to', 3),
('en_US', 'word', 'is', 'that', 3),
('en_US', 'word', 'is', 'a', 2),
('en_US', 'word', 'to', 'be', 2),
('en_US', 'word', 'to', 'do', 2),
('en_US', 'word', 'to', 'make', 2),
('en_US', 'word', 'that', 'we', 2),
('en_US', 'word', 'that', 'you', 2),
('en_US', 'word', 'we', 'should', 2),
('en_US', 'word', 'we', 'need', 2),
('en_US', 'word', 'you', 'can', 2),
('en_US', 'word', 'should', 'always', 2),
('en_US', 'word', 'need', 'to', 2),
('en_US', 'word', 'can', 'find', 2),
('en_US', 'word', 'always', 'remember', 2),
('en_US', 'word', 'find', 'new', 2),
('en_US', 'word', 'remember', 'that', 2),
('en_US', 'word', 'new', 'ways', 2),
('en_US', 'word', 'ways', 'to', 2),
('en_US', 'word', 'dog', 'END', 2),
('en_US', 'word', 'ways', 'END', 2),
('en_US', 'word', 'remember', 'END', 2);

-- German Markov chain data
INSERT INTO lookup_markov_chains (locale_code, chain_type, prefix, suffix, frequency) VALUES
('de_DE', 'word', 'START', 'Die', 10),
('de_DE', 'word', 'START', 'Der', 8),
('de_DE', 'word', 'START', 'Das', 6),
('de_DE', 'word', 'START', 'Ein', 5),
('de_DE', 'word', 'START', 'Eine', 5),
('de_DE', 'word', 'START', 'Es', 4),
('de_DE', 'word', 'START', 'Wenn', 3),
('de_DE', 'word', 'START', 'Nach', 3),
('de_DE', 'word', 'Die', 'wichtigste', 3),
('de_DE', 'word', 'Die', 'beste', 3),
('de_DE', 'word', 'Die', 'neue', 2),
('de_DE', 'word', 'Der', 'schnelle', 2),
('de_DE', 'word', 'Der', 'erste', 2),
('de_DE', 'word', 'Das', 'ist', 3),
('de_DE', 'word', 'wichtigste', 'Sache', 2),
('de_DE', 'word', 'Sache', 'ist', 2),
('de_DE', 'word', 'ist', 'dass', 3),
('de_DE', 'word', 'ist', 'es', 2),
('de_DE', 'word', 'dass', 'wir', 2),
('de_DE', 'word', 'dass', 'man', 2),
('de_DE', 'word', 'wir', 'immer', 2),
('de_DE', 'word', 'wir', 'sollten', 2),
('de_DE', 'word', 'man', 'kann', 2),
('de_DE', 'word', 'immer', 'daran', 2),
('de_DE', 'word', 'daran', 'denken', 2),
('de_DE', 'word', 'denken', 'sollte', 2),
('de_DE', 'word', 'sollte', 'END', 2),
('de_DE', 'word', 'kann', 'END', 2);
