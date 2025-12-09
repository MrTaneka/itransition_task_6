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
