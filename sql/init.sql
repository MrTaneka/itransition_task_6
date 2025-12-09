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
-- =====================================================
-- Seed Data for Faker SQL - Complete Version
-- =====================================================

-- Insert locales
INSERT INTO locales (code, name, country_code, phone_country_code) VALUES
('en_US', 'English (USA)', 'US', '+1'),
('de_DE', 'German (Germany)', 'DE', '+49');

-- =====================================================
-- US NAMES
-- =====================================================

-- US Male First Names (200)
INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'en_US', 'first', 'male', unnest(ARRAY[
'James','Michael','Robert','John','David','William','Richard','Joseph','Thomas','Christopher',
'Charles','Daniel','Matthew','Anthony','Mark','Donald','Steven','Paul','Andrew','Joshua',
'Kenneth','Kevin','Brian','George','Timothy','Ronald','Edward','Jason','Jeffrey','Ryan',
'Jacob','Gary','Nicholas','Eric','Jonathan','Stephen','Larry','Justin','Scott','Brandon',
'Benjamin','Samuel','Raymond','Gregory','Frank','Alexander','Patrick','Jack','Dennis','Jerry',
'Tyler','Aaron','Jose','Adam','Nathan','Henry','Douglas','Zachary','Peter','Kyle',
'Noah','Ethan','Jeremy','Walter','Christian','Keith','Roger','Terry','Austin','Sean',
'Gerald','Carl','Harold','Dylan','Arthur','Lawrence','Jordan','Jesse','Bryan','Billy',
'Bruce','Gabriel','Joe','Logan','Alan','Juan','Wayne','Elijah','Randy','Roy',
'Vincent','Ralph','Eugene','Russell','Bobby','Mason','Philip','Louis','Harry','Liam',
'Oliver','Lucas','Aiden','Sebastian','Carter','Owen','Wyatt','Luke','Grayson','Isaac',
'Jayden','Theodore','Caleb','Asher','Leo','Lincoln','Jaxon','Miles','Ezra','Colton',
'Adrian','Eli','Nolan','Hunter','Connor','Landon','Cooper','Easton','Parker','Roman',
'Hudson','Maverick','Dominic','Bentley','Carson','Brooks','Axel','Sawyer','Bennett','Declan',
'Everett','Weston','Micah','Harrison','Greyson','Wesley','Ivan','Dean','Grant','Emmett',
'Max','Rowan','Preston','Marcus','Holden','Cole','Bryce','Tucker','Spencer','Gavin',
'Graham','Felix','Simon','Oscar','Jonah','Griffin','Elliott','Trevor','Derek','Victor',
'Martin','Shane','Omar','Craig','Chad','Dustin','Corey','Travis','Mitchell','Brad',
'Darren','Clayton','Edgar','Perry','Ross','Damian','Cody','Blake','Cameron','Lance',
'Xavier','Chase','Tristan','Seth','Nash','Reid','Beau','Maddox','Jace','Finn'
]);

-- US Female First Names (200)
INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'en_US', 'first', 'female', unnest(ARRAY[
'Mary','Patricia','Jennifer','Linda','Barbara','Elizabeth','Susan','Jessica','Sarah','Karen',
'Lisa','Nancy','Betty','Margaret','Sandra','Ashley','Kimberly','Emily','Donna','Michelle',
'Dorothy','Carol','Amanda','Melissa','Deborah','Stephanie','Rebecca','Sharon','Laura','Cynthia',
'Kathleen','Amy','Angela','Shirley','Anna','Brenda','Pamela','Emma','Nicole','Helen',
'Samantha','Katherine','Christine','Debra','Rachel','Carolyn','Janet','Catherine','Maria','Heather',
'Diane','Ruth','Julie','Olivia','Joyce','Virginia','Victoria','Kelly','Lauren','Christina',
'Joan','Evelyn','Judith','Megan','Andrea','Cheryl','Hannah','Jacqueline','Martha','Gloria',
'Teresa','Ann','Sara','Madison','Frances','Kathryn','Janice','Jean','Abigail','Alice',
'Judy','Sophia','Grace','Denise','Amber','Doris','Marilyn','Danielle','Beverly','Isabella',
'Theresa','Diana','Natalie','Brittany','Charlotte','Marie','Kayla','Alexis','Lori','Ava',
'Mia','Zoe','Lily','Chloe','Ella','Avery','Harper','Aria','Scarlett','Penelope',
'Layla','Riley','Zoey','Nora','Eleanor','Hazel','Aurora','Savannah','Audrey','Brooklyn',
'Bella','Claire','Skylar','Lucy','Paisley','Everly','Caroline','Nova','Genesis','Emilia',
'Kennedy','Maya','Willow','Kinsley','Naomi','Aaliyah','Elena','Ariana','Allison','Gabriella',
'Madelyn','Cora','Ruby','Eva','Serenity','Autumn','Adeline','Hailey','Gianna','Valentina',
'Isla','Eliana','Quinn','Ivy','Sadie','Piper','Lydia','Alexa','Josephine','Emery',
'Julia','Delilah','Arianna','Vivian','Kaylee','Sophie','Brielle','Madeline','Peyton','Rylee',
'Clara','Hadley','Melanie','Mackenzie','Reagan','Adalynn','Liliana','Aubrey','Rose','Adalyn',
'Leila','Jade','Khloe','Sydney','Morgan','Phoebe','Ellie','Lila','Addison','Molly',
'Brooke','Stella','Faith','Bailey','Harmony','Raven','Jasmine','Destiny','Selena','Luna'
]);

-- US Last Names (500)
INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'en_US', 'last', NULL, unnest(ARRAY[
'Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez',
'Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor','Moore','Jackson','Martin',
'Lee','Perez','Thompson','White','Harris','Sanchez','Clark','Ramirez','Lewis','Robinson',
'Walker','Young','Allen','King','Wright','Scott','Torres','Nguyen','Hill','Flores',
'Green','Adams','Nelson','Baker','Hall','Rivera','Campbell','Mitchell','Carter','Roberts',
'Gomez','Phillips','Evans','Turner','Diaz','Parker','Cruz','Edwards','Collins','Reyes',
'Stewart','Morris','Morales','Murphy','Cook','Rogers','Gutierrez','Ortiz','Morgan','Cooper',
'Peterson','Bailey','Reed','Kelly','Howard','Ramos','Kim','Cox','Ward','Richardson',
'Watson','Brooks','Chavez','Wood','James','Bennett','Gray','Mendoza','Ruiz','Hughes',
'Price','Alvarez','Castillo','Sanders','Patel','Myers','Long','Ross','Foster','Jimenez',
'Powell','Jenkins','Perry','Russell','Sullivan','Bell','Coleman','Butler','Henderson','Barnes',
'Gonzales','Fisher','Vasquez','Simmons','Stokes','Simpson','Crawford','Jimenez','Porter','Mason',
'Shaw','Gordon','Wagner','Hunter','Romero','Hicks','Dixon','Hunt','Palmer','Robertson',
'Black','Holmes','Stone','Meyer','Boyd','Mills','Warren','Fox','Rose','Rice',
'Moreno','Schmidt','Patel','Ferguson','Nichols','Herrera','Medina','Ryan','Fernandez','Weaver',
'Daniels','Stephens','Gardner','Payne','Kelley','Dunn','Pierce','Arnold','Tran','Spencer',
'Peters','Hawkins','Grant','Hansen','Castro','Hoffman','Hart','Elliott','Cunningham','Knight',
'Bradley','Carroll','Hudson','Duncan','Armstrong','Berry','Andrews','Johnston','Ray','Lane',
'Riley','Carpenter','Perkins','Aguilar','Silva','Richards','Willis','Matthews','Chapman','Lawrence',
'Garza','Vargas','Watkins','Wheeler','Chambers','Santos','Kerr','Klein','Salazar','Fuentes',
'Delgado','Morton','Burke','Welch','Summers','Barker','Powers','Love','Burns','May',
'Cobb','Park','Day','Patton','Good','McCoy','Pope','Francis','Lyons','Norton',
'Brock','Cross','Hayes','Owen','Freeman','Mcdonald','Harper','Griffin','Wolfe','Sims',
'Austin','Douglas','Sherman','Watts','Flynn','Frazier','Chandler','Sutton','Webster','Fields',
'Malone','Goodwin','Howell','Maloney','Hood','Franklin','Lloyd','Barton','Hale','Oconnor',
'Mckinney','Ingram','Caldwell','Higgins','Briggs','Meadows','Brady','Ball','Cummings','Dawson',
'Bolton','Greer','Fowler','English','Lowe','Sparks','Jefferson','Woodard','Mcbride','Hopkins',
'Hull','Frost','Baldwin','Osborne','Hardy','Vincent','Warner','Mueller','Roman','Ochoa',
'Nunez','Valencia','Maldonado','Conner','Yates','Hines','Stephenson','Hancock','Bates','Buck',
'Whitney','Lambert','Benson','Patrick','Cherry','Todd','Blair','Little','Walls','Banks',
'Savage','Koch','Frost','Decker','Rivers','Thornton','Barrera','Horne','Dalton','Page',
'Kaufman','Guzman','Melton','Glenn','Christensen','Hampton','Haynes','Byrd','Beard','Curry',
'Crane','Landry','Odom','Cowan','Wyatt','Winters','Schneider','Brennan','Bauer','Goodman',
'Acevedo','Walter','Miranda','Mathis','Rojas','Maxwell','Christian','Weeks','Olsen','Bryan',
'Cortez','Cervantes','Tate','Oneal','Pitts','Serrano','Mcfarland','Moses','Carlson','Walsh',
'Mcconnell','Lara','Ballard','Leonard','Holt','Leach','Pratt','Stanton','Wiley','Morse',
'Sampson','Beasley','Duffy','Barr','Chen','Knapp','Moody','Mcintosh','Short','Crosby',
'Blankenship','Finley','Rich','Foley','Browning','Golden','Lindsey','Reid','Valenzuela','Mora',
'Pollard','Beach','Church','Stokes','Lang','Shields','Jacobson','Benjamin','Shelton','Stafford',
'Rivers','Oneill','Pena','Riddle','Noble','Mcgee','Forbes','Manning','Cannon','Glass',
'Rush','Pruitt','Bush','Valencia','Woodward','Booth','Wu','Cash','Gill','Mullen',
'Harmon','Carey','Walton','Hess','French','Moon','Stuart','Gross','York','William',
'Ramsey','Soto','Calhoun','Norris','Berg','Clements','Hewitt','Schroeder','Baxter','Sherman',
'Suarez','Mercado','Holder','Moran','Solomon','Hinton','Keith','Potts','Maynard','David',
'Monroe','Gaines','Hubbard','Durham','Sharp','Escobar','Everett','Gates','Padilla','Callahan'
]);

-- US Middle Names (100)
INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'en_US', 'middle', 'male', unnest(ARRAY[
'James','Michael','Robert','William','David','Joseph','John','Thomas','Charles','Daniel',
'Christopher','Edward','Richard','George','Benjamin','Alexander','Samuel','Patrick','Andrew','Henry',
'Paul','Lee','Ray','Allen','Scott','Earl','Wayne','Dean','Louis','Eugene',
'Francis','Carl','Roy','Anthony','Alan','Frank','Peter','Dale','Jay','Glenn',
'Roger','Ronald','Bruce','Howard','Lawrence','Douglas','Martin','Ralph','Arthur','Jerome'
]);

INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'en_US', 'middle', 'female', unnest(ARRAY[
'Marie','Ann','Lynn','Elizabeth','Rose','Grace','Jean','May','Louise','Jane',
'Lee','Nicole','Anne','Mae','Jo','Renee','Kay','Sue','Faye','Rae',
'Belle','Faith','Hope','Joy','Dawn','Eve','Jade','Pearl','Ruby','Claire',
'Irene','June','Kate','Beth','Ruth','Gail','Fern','Nell','Dale','Leigh',
'Paige','Quinn','Sage','Skye','Wren','Blake','Brooke','Lane','Reese','Sloane'
]);

-- US Titles
INSERT INTO lookup_titles (locale_code, gender, value) VALUES
('en_US', 'male', 'Mr.'),
('en_US', 'male', 'Dr.'),
('en_US', 'female', 'Mrs.'),
('en_US', 'female', 'Ms.'),
('en_US', 'female', 'Miss'),
('en_US', 'female', 'Dr.'),
('en_US', NULL, 'Dr.'),
('en_US', NULL, 'Prof.');

-- =====================================================
-- GERMAN NAMES
-- =====================================================

-- German Male First Names (200)
INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'de_DE', 'first', 'male', unnest(ARRAY[
'Lukas','Leon','Luca','Finn','Noah','Elias','Paul','Felix','Jonas','Louis',
'Max','Ben','Philipp','Jakob','Tim','David','Niklas','Alexander','Moritz','Julian',
'Jan','Fabian','Simon','Tom','Florian','Sebastian','Tobias','Dominik','Kevin','Daniel',
'Michael','Andreas','Thomas','Stefan','Markus','Christian','Patrick','Marco','Dennis','Marcel',
'Matthias','Martin','Peter','Frank','Wolfgang','Klaus','Hans','Jürgen','Uwe','Bernd',
'Karl','Werner','Heinz','Dieter','Helmut','Horst','Rolf','Gerhard','Günther','Manfred',
'Otto','Friedrich','Wilhelm','Heinrich','Josef','Ernst','Alfred','Rudolf','Walter','Kurt',
'Emil','Anton','Oskar','Leopold','Siegfried','Hermann','Erich','Richard','Theodor','Gustav',
'Bruno','Hugo','Arnold','Ludwig','Albert','Johann','Franz','Adolf','Gottfried','Konrad',
'Maximilian','Benjamin','Samuel','Rafael','Vincent','Lennard','Mats','Liam','Emil','Theodor',
'Oscar','Henry','Anton','Carl','Fritz','Georg','Robert','Valentin','Adrian','Leo',
'Victor','Erik','Nils','Henrik','Lars','Sven','Ole','Kai','Malte','Hannes',
'Constantin','Benedikt','Leonard','Jonathan','Gabriel','Aaron','Julius','Kilian','Levin','Jannik',
'Frederik','Bastian','Sascha','René','Torsten','Jens','Björn','Thorsten','Steffen','Karsten',
'Rainer','Holger','Volker','Jochen','Achim','Norbert','Dirk','Armin','Roland','Joachim',
'Hartmut','Detlef','Wilfried','Gerd','Lothar','Reinhard','Siegbert','Friedhelm','Hubertus','Engelbert',
'Adalbert','Bernhard','Egon','Erwin','Harald','Herbert','Horst','Ingolf','Ingo','Joerg',
'Jörg','Lutz','Olaf','Ralph','Reiner','Till','Udo','Ulrich','Claus','Axel',
'Boris','Carsten','Christoph','Gerald','Gregor','Hendrik','Igor','Lennart','Magnus','Marvin',
'Niko','Pascal','Quentin','Raphael','Roman','Ruben','Sascha','Timo','Tristan','Xaver'
]);

-- German Female First Names (200)
INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'de_DE', 'first', 'female', unnest(ARRAY[
'Emma','Mia','Hannah','Sophia','Anna','Emilia','Marie','Lena','Lea','Laura',
'Lina','Sophie','Clara','Johanna','Paula','Luisa','Jana','Lisa','Sarah','Julia',
'Katharina','Christina','Melanie','Stefanie','Nicole','Sabrina','Jasmin','Sandra','Simone','Anja',
'Daniela','Claudia','Petra','Susanne','Birgit','Monika','Gabriele','Ursula','Renate','Helga',
'Ingrid','Erika','Gerda','Hildegard','Ilse','Irmgard','Edith','Elfriede','Brunhilde','Gisela',
'Marlene','Erna','Frieda','Martha','Rosa','Charlotte','Elisabeth','Maria','Barbara','Margarete',
'Ella','Maja','Emily','Amelie','Nele','Mila','Charlotte','Lilly','Mathilda','Greta',
'Frieda','Ida','Helena','Victoria','Antonia','Josephine','Eva','Theresa','Marlene','Martha',
'Annika','Franziska','Miriam','Nadine','Rebecca','Vanessa','Jennifer','Michelle','Denise','Tanja',
'Manuela','Martina','Andrea','Heike','Silke','Karin','Bettina','Ulrike','Jutta','Cornelia',
'Annette','Britta','Regina','Marion','Angelika','Doris','Christa','Inge','Waltraud','Hannelore',
'Lieselotte','Gertrude','Margarethe','Adelheid','Dorothea','Wilhelmina','Auguste','Ottilie','Elfriede','Hermine',
'Pauline','Rosemarie','Eleonore','Edeltraud','Sigrid','Dagmar','Ingeborg','Gudrun','Liesel','Anneliese',
'Mechthild','Kunigunde','Walpurga','Walburga','Notburga','Ludmilla','Crescentia','Hildegunde','Kriemhild','Brünhild',
'Leonie','Alina','Elena','Celina','Selina','Nina','Tina','Pia','Maren','Svenja',
'Birte','Meike','Wiebke','Frauke','Gesine','Imke','Inke','Maike','Heike','Silke',
'Ricarda','Karola','Ramona','Anita','Beate','Carmen','Diana','Yvonne','Sonja','Katja',
'Larissa','Tamara','Natalia','Olga','Irina','Vera','Ludmila','Tatjana','Jelena','Ekaterina',
'Paulina','Valentina','Alexandra','Anastasia','Nadja','Katarina','Marina','Galina','Nadia','Oxana',
'Kerstin','Kirsten','Astrid','Brigitte','Gerlinde','Karoline','Steffi','Uschi','Gaby','Conny'
]);

-- German Last Names (500)
INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'de_DE', 'last', NULL, unnest(ARRAY[
'Müller','Schmidt','Schneider','Fischer','Weber','Meyer','Wagner','Becker','Schulz','Hoffmann',
'Schäfer','Koch','Bauer','Richter','Klein','Wolf','Schröder','Neumann','Schwarz','Zimmermann',
'Braun','Krüger','Hofmann','Hartmann','Lange','Schmitt','Werner','Schmitz','Krause','Meier',
'Lehmann','Schmid','Schulze','Maier','Köhler','Herrmann','König','Walter','Mayer','Huber',
'Kaiser','Fuchs','Peters','Lang','Scholz','Möller','Weiß','Jung','Hahn','Schubert',
'Vogel','Friedrich','Keller','Günther','Frank','Berger','Winkler','Roth','Beck','Lorenz',
'Baumann','Franke','Albrecht','Schuster','Simon','Ludwig','Böhm','Winter','Kraus','Martin',
'Schumacher','Krämer','Vogt','Stein','Jäger','Otto','Sommer','Groß','Seidel','Heinrich',
'Brandt','Haas','Schreiber','Graf','Schulte','Dietrich','Ziegler','Kuhn','Kühn','Pohl',
'Engel','Horn','Busch','Bergmann','Thomas','Voigt','Sauer','Arnold','Wolff','Pfeiffer',
'Hanke','Friedrich','Lindner','Witt','Barth','Ullrich','Anders','Wenzel','Haase','Böhme',
'Kraft','Jansen','Schütz','Fiedler','Kunz','Krüger','Ernst','May','Fröhlich','Wetzel',
'Mann','Schröter','Lenz','Stark','Böttcher','Schenk','Ebert','Kopp','Rudolph','Heinz',
'Geiger','Reuter','Stahl','Noll','Hesse','Freitag','Lutz','Marx','Herzog','Urban',
'Naumann','Thiel','Schultz','Bender','Wolter','Witte','Gabriel','Marquardt','Beer','Rau',
'Völker','Beyer','Michel','Petersen','Rose','Maurer','Adam','Kern','Henkel','Götz',
'Hammer','Mohr','Bader','Hildebrandt','Michels','Janssen','Stock','Jacob','Grimm','Riedel',
'Steiner','Gerlach','Brenner','Wendt','Geyer','Rausch','Kurz','Krug','Benz','Reich',
'Jahn','Döring','Schiller','Zander','Reinhardt','Esser','Kohl','Freund','Eichler','Rademacher',
'Auer','Schweizer','Bartsch','Brand','Seifert','Wilke','Held','Klaus','Altmann','Otte',
'Beckmann','Zeller','Kress','Kühne','Brückner','Blum','Büttner','Mühlbauer','Neubert','Kunze',
'Hamann','Mertens','Lauer','Herbst','Greiner','Pfaff','Hoppe','Buck','Dreher','John',
'Funk','Ewald','Dorn','Frisch','May','Hinz','Bischoff','Hempel','Seitz','Moll',
'Nolte','Hein','Konrad','Neuhaus','Scherer','Pieper','Born','Münch','Rupp','Falk',
'Link','Baumgartner','Kluge','Strauß','Gerber','Bär','Kiefer','Christ','Fritsch','Wahl',
'Röder','Singer','Gärtner','Mai','Schlegel','Dittrich','Schrader','Henning','Popp','Eberhardt',
'Ritter','Finke','Harms','Köster','Raab','Großmann','Büchner','Hübner','Baum','Ahrens',
'Fritz','Eckert','Schön','Will','Reich','Moritz','Unger','Klose','Jakob','Wiegand',
'Haupt','Bach','Becher','Döhring','Stumpf','Kessler','Baumgärtner','Böhmer','Holz','Meister',
'Haug','Heim','Bachmann','Büchler','Höfer','Diehl','Heck','Zink','Heß','Groth',
'Voss','Klinger','Hauser','Hoff','Gärtner','Hölzl','Specht','Reichel','Hofer','Steffen',
'Janßen','Oswald','Pfeifer','Stadler','Bertram','Schmid','Schnell','Probst','Wiese','Imhof',
'Hager','Böck','Kirchner','Rost','Weiland','Rapp','Wunderlich','Opitz','Berndt','Thiele',
'Strauß','Wiesner','Herbig','Buchholz','Strack','Römer','Förster','Heinze','Hauser','Dietz',
'Ulrich','Huth','Schilling','Paul','Adler','Korn','Best','Lechner','Grund','Vogel',
'Henke','Rauch','Völkel','Strauch','Gröger','Krauss','Gebauer','Busse','Rust','Scharff',
'Kremer','Henke','Bohn','Breuer','Pape','Schön','Frei','Seeger','Geist','Gruber',
'Holzer','Schindler','Schüler','Schott','Neff','Frey','Pape','Döring','Wild','Heinemann',
'Wirth','Lohmann','Kranz','Metz','Böcker','Steffens','Blank','Kolb','Hartung','Bauer',
'Wendel','Borchers','Gehrke','Hauck','Haug','Böttger','Springer','Ammann','Eckhardt','Klemm',
'Lux','Seiler','Wulf','Hanisch','Lindemann','Reimer','Runge','Beier','Bohm','Hase',
'Brehm','Falke','Scheel','Struck','Thoma','Bock','Nagel','Dreyer','Zimmerman','Lehner',
'Bremer','Kirchhoff','Mader','Post','Dahl','Kasten','Merk','Damm','Patzelt','Ackermann',
'Tiedemann','Wieland','Kremer','Hornung','Lehnert','Riedl','Brinkmann','Ehlers','Rösch','Köhne',
'Knecht','Pfeffer','Heck','Rath','Stock','Scharf','Schuh','Boos','Köpke','Geisler',
'Hagedorn','Hesse','Klose','Schmidtke','Block','Cramer','Strunk','Rink','Teichmann','Hüber',
'Vetter','Sauter','Reimann','Winkels','Steinbach','Evers','Hager','Reger','Seeger','Scherer',
'Heinrichs','Schmidtchen','Beckert','Lindenberg','Claus','Krohn','Krebs','Rausch','Küppers','Hoff'
]);

-- German Middle Names (50)
INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'de_DE', 'middle', 'male', unnest(ARRAY[
'Johann','Friedrich','Wilhelm','Heinrich','Karl','Josef','Franz','Georg','Ludwig','Ernst',
'Otto','Hans','Max','Paul','Rudolf','Werner','Herbert','Richard','Heinz','Adolf',
'Alfred','Erich','Kurt','Walter','Gerhard','Helmut','Fritz','Dieter','Günter','Anton'
]);

INSERT INTO lookup_names (locale_code, name_type, gender, value)
SELECT 'de_DE', 'middle', 'female', unnest(ARRAY[
'Maria','Elisabeth','Anna','Sophie','Margarete','Katharina','Rosa','Luise','Frieda','Johanna',
'Gertrud','Helene','Paula','Hedwig','Martha','Else','Agnes','Berta','Ida','Emma'
]);

-- German Titles
INSERT INTO lookup_titles (locale_code, gender, value) VALUES
('de_DE', 'male', 'Herr'),
('de_DE', 'male', 'Dr.'),
('de_DE', 'male', 'Prof. Dr.'),
('de_DE', 'female', 'Frau'),
('de_DE', 'female', 'Dr.'),
('de_DE', 'female', 'Prof. Dr.'),
('de_DE', NULL, 'Dr.'),
('de_DE', NULL, 'Prof.');

-- =====================================================
-- STREETS
-- =====================================================

-- US Streets (300)
INSERT INTO lookup_streets (locale_code, street_type, street_name)
SELECT 'en_US', street_type, street_name FROM (
    SELECT unnest(ARRAY['Street','Avenue','Boulevard','Drive','Lane','Road','Way','Place','Court','Circle']) as street_type,
           unnest(ARRAY['Main','Oak','Maple','Cedar','Elm','Pine','Walnut','Cherry','Birch','Willow',
                        'Washington','Lincoln','Jefferson','Madison','Jackson','Roosevelt','Kennedy','Adams','Franklin','Hamilton',
                        'Park','Lake','River','Hill','Valley','Forest','Meadow','Spring','Creek','Highland',
                        'First','Second','Third','Fourth','Fifth','Sixth','Seventh','Eighth','Ninth','Tenth',
                        'Church','School','Market','Mill','Bridge','Station','Center','Union','Liberty','Commerce',
                        'Sunset','Sunrise','Mountain','Ocean','Bay','Harbor','Beach','Coast','Shore','Cliff',
                        'North','South','East','West','Central','College','University','Academy','Campus','Library']) as street_name
) t;

-- German Streets (300)
INSERT INTO lookup_streets (locale_code, street_type, street_name)
SELECT 'de_DE', 'straße', street_name FROM (
    SELECT unnest(ARRAY[
        'Haupt','Bahnhof','Markt','Kirch','Schul','Garten','Berg','Wald','See','Fluss',
        'Linden','Eichen','Buchen','Birken','Tannen','Ahorn','Ulmen','Eschen','Kastanien','Pappel',
        'Goethe','Schiller','Mozart','Beethoven','Bach','Brahms','Wagner','Händel','Schubert','Haydn',
        'Adenauer','Bismarck','Kaiser','König','Friedrich','Wilhelm','Heinrich','Ludwig','Karl','Otto',
        'Römer','Berliner','Hamburger','Münchner','Kölner','Frankfurter','Dresdner','Leipziger','Stuttgarter','Düsseldorfer',
        'Ring','Park','Hof','Platz','Anger','Damm','Graben','Mühlen','Brunnen','Brücken',
        'Sonnen','Mond','Stern','Regen','Wind','Nebel','Schnee','Frost','Sommer','Winter',
        'Blumen','Rosen','Lilien','Nelken','Tulpen','Veilchen','Jasmin','Lavendel','Maiglöckchen','Kornblumen',
        'Nord','Süd','Ost','West','Mittel','Ober','Unter','Alt','Neu','Klein',
        'Industrie','Gewerbe','Handels','Fabrik','Werk','Bau','Siedlungs','Wohn','Schloss','Burg'
    ]) as street_name
) t;

INSERT INTO lookup_streets (locale_code, street_type, street_name)
SELECT 'de_DE', 'weg', street_name FROM (
    SELECT unnest(ARRAY[
        'Feld','Wiesen','Wald','Berg','Tal','Bach','Teich','Anger','Mühlen','Grenz',
        'Hohen','Kreuz','Kapellen','Kloster','Friedhofs','Kirch','Pfarr','Schul','Rathaus','Amts'
    ]) as street_name
) t;

INSERT INTO lookup_streets (locale_code, street_type, street_name)
SELECT 'de_DE', 'allee', street_name FROM (
    SELECT unnest(ARRAY[
        'Linden','Kastanien','Pappel','Ahorn','Ulmen','Platanen','Kaiser','Königs','Fürsten','Herzogs'
    ]) as street_name
) t;
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
BEGIN
    -- Convert locale to numeric hash
    v_locale_hash := ('x' || substr(md5(p_locale_code), 1, 8))::bit(32)::BIGINT;
    
    -- Mix all parameters using prime numbers for better distribution
    -- This ensures different combinations produce different sequences
    v_combined := (
        p_seed * 2654435761 +           -- Golden ratio prime
        p_batch_index * 1597334677 +     -- Large prime
        p_record_index * 805306457 +     -- Another prime
        v_locale_hash
    ) & 9223372036854775807;             -- Keep positive (mask sign bit)
    
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
    -- LCG parameters (Numerical Recipes constants)
    c_multiplier CONSTANT BIGINT := 1103515245;
    c_increment CONSTANT BIGINT := 12345;
    c_modulus CONSTANT BIGINT := 2147483648;  -- 2^31
BEGIN
    -- Calculate next state
    next_state := ((p_state * c_multiplier + c_increment) % c_modulus);
    
    -- Normalize to [0, 1)
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
    v_city_record RECORD;
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
    
    SELECT c.city_name, c.state_code INTO city, state_code
    FROM lookup_cities c
    WHERE c.locale_code = p_locale_code
    ORDER BY c.id
    OFFSET v_offset LIMIT 1;
    
    -- Get state name
    SELECT s.state_name INTO state_name
    FROM lookup_states s
    WHERE s.locale_code = p_locale_code AND s.state_code = state_code
    LIMIT 1;
    
    state_name := COALESCE(state_name, state_code);
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
