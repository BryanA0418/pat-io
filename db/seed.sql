-- Switch to the correct database (PostgreSQL specific, use only if needed)
\c patio_dev;

-- Insert visa statuses
INSERT INTO visa_status (name, description, qualify_for_ssn, government_document_required)
VALUES 
('H-1B', 'a temporary non-immigrant visa that allows US employers to hire foreign workers for specialty occupations', true, true),
('L-1', 'a non-immigrant visa that allows multinational companies to transfer employees to their US offices', true, true),
('TN', 'a non-immigrant visa that allows citizens of Canada and Mexico to work in the US for up to three years', true, true),
('O-1', 'a non-immigrant visa that allows individuals with extraordinary ability in the sciences, arts, education, business, or athletics to work in the US', true, true),
('E-2', 'a non-immigrant visa that allows investors to start a business in the US', true, true),
('E-3', 'a non-immigrant visa that allows citizens of Australia to work in the US', true, true),
('F-1', 'a non-immigrant visa that allows students to study in the US', true, true);

-- Insert ID requirements
INSERT INTO id_requirements (name, form_number, description)
VALUES
('Passport', NULL, 'a travel document issued by a government that allows individuals to travel internationally'),
('Driver''s License', NULL, 'a document issued by a government that allows individuals to operate motor vehicles'),
('Green Card', 'I-551', 'a document issued by the US Citizenship and Immigration Services that allows individuals to live and work in the US permanently'),
('Birth Certificate', NULL, 'a document issued by a government that records the birth of an individual'),
('Passport Card', NULL, 'a document issued by the US Department of Homeland Security that allows individuals to travel internationally'),
('Employment Authorization Document', 'I-766', 'a document issued by the US Citizenship and Immigration Services that allows individuals to work in the US'),
('Arrival-Departure Record', 'I-94', 'a document issued by the US Customs and Border Protection that records an individual''s arrival and departure from the US'),
('Certificate of Eligibility for Non-immigrant Student Status', 'I-20', 'a document issued by a US educational institution that allows international students to study in the US'),
('Certificate of Eligibility for Non-immigrant Worker', 'I-129', 'a document issued by the US Citizenship and Immigration Services that allows individuals to work in the US'),
('Optional Practical Training Certificate', 'I-765', 'a document issued by the US Citizenship and Immigration Services that allows individuals to work in the US');

-- Insert visa requirements (many-to-many relationships)
-- H-1B Visa Requirements
INSERT INTO visa_requirements (visa_status_id, id_requirements_id)
VALUES 
(1, 1), -- H-1B requires Passport
(1, 7), -- H-1B requires Arrival-Departure Record (I-94)
(1, 6); -- H-1B requires Employment Authorization Document for Non-immigrant Worker (I-766)

-- L-1 Visa Requirements
INSERT INTO visa_requirements (visa_status_id, id_requirements_id)
VALUES 
(2, 1), -- L-1 requires Passport
(2, 7), -- L-1 requires Arrival-Departure Record (I-94)
(2, 9); -- L-1 requires Certificate of Eligibility for Non-immigrant Worker (I-129)

-- TN Visa Requirements
INSERT INTO visa_requirements (visa_status_id, id_requirements_id)
VALUES 
(3, 1), -- TN requires Passport
(3, 7); -- TN requires Arrival-Departure Record (I-94)

-- O-1 Visa Requirements
INSERT INTO visa_requirements (visa_status_id, id_requirements_id)
VALUES 
(4, 1), -- O-1 requires Passport
(4, 7), -- O-1 requires Arrival-Departure Record (I-94)
(4, 9); -- O-1 requires Certificate of Eligibility for Non-immigrant Worker (I-129)

-- E-2 Visa Requirements
INSERT INTO visa_requirements (visa_status_id, id_requirements_id)
VALUES 
(5, 1), -- E-2 requires Passport
(5, 7); -- E-2 requires Arrival-Departure Record (I-94)

-- E-3 Visa Requirements
INSERT INTO visa_requirements (visa_status_id, id_requirements_id)
VALUES 
(6, 1), -- E-3 requires Passport
(6, 7); -- E-3 requires Arrival-Departure Record (I-94)

-- F-1 Visa Requirements
INSERT INTO visa_requirements (visa_status_id, id_requirements_id)
VALUES 
(7, 1), -- F-1 requires Passport
(7, 8), -- F-1 requires Certificate of Eligibility for Non-immigrant Student Status (I-20)
(7, 10); -- F-1 requires Optional Practical Training Certificate (I-765)

-- NY SSA Office Open/Close Times
INSERT INTO office_open_close_times (
    office_code, office_name, address_line_1, address_line_2, address_line_3, city, state, zip_code, 
    phone, fax, monday_open_time, monday_close_time, tuesday_open_time, tuesday_close_time, 
    wednesday_open_time, wednesday_close_time, thursday_open_time, thursday_close_time, 
    friday_open_time, friday_close_time, latitude, longitude
) VALUES 
    ('NY01', 'NY MIDTOWN NY', 'SOCIAL SECURITY', '5TH FLOOR', '237 W 48TH STREET', 'NEW YORK', 'NY', '10036', 
     '(866) 964-0783', '(833) 950-3599', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7603, -73.9867), 

    ('NY02', 'SYRACUSE NY', 'SOCIAL SECURITY', 'FED BLDG 4TH FLOOR', '100 S CLINTON ST', 'SYRACUSE', 'NY', '13261', 
     '(866) 755-4884', '(833) 950-3601', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 43.045, -76.1498),

    ('NY03', 'ALBANY NY', 'SOCIAL SECURITY', 'RM 430 FEDERAL BLDG', '11 A CLINTON AVE', 'ALBANY', 'NY', '12207', 
     '(866) 253-9183', '(833) 950-3603', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.6512, -73.7534),

    ('NY04', 'BUFFALO NY', 'SOCIAL SECURITY', 'SUITE 200', '478 MAIN STREET', 'BUFFALO', 'NY', '14202', 
     '(855) 881-0213', '(833) 950-3605', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.8864, -78.8784),

    ('NY05', 'BINGHAMTON NY', 'SOCIAL SECURITY', 'SUITE 300', '2 COURT STREET', 'BINGHAMTON', 'NY', '13901', 
     '(866) 964-3971', '(833) 950-3607', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.0987, -75.9179),

    ('NY06', 'SCHENECTADY NY', 'SOCIAL SECURITY', '8TH FLOOR', 'ONE BROADWAY CENTER', 'SCHENECTADY', 'NY', '12305', 
     '(866) 964-1296', '(833) 950-3609', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.8142, -73.9396),

    ('NY07', 'BORO HALL NY', 'SOCIAL SECURITY', '7TH FLOOR', '195 MONTAGUE ST', 'BROOKLYN', 'NY', '11201', 
     '(877) 531-4725', '(833) 950-3611', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.6944, -73.9918),

    ('NY08', 'ROCHESTER NY', 'SOCIAL SECURITY', '2ND FLOOR', '200 E. MAIN ST', 'ROCHESTER', 'NY', '14604', 
     '(866) 964-2045', '(833) 515-0465', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 43.1566, -77.6088),

    ('NY09', 'NY DOWNTOWN NY', 'SOCIAL SECURITY', '4TH FLOOR', '123 WILLIAM ST', 'NEW YORK', 'NY', '10038', 
     '(866) 335-1089', '(833) 515-0467', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7103, -74.0074),

    ('NY10', 'UTICA NY', 'SOCIAL SECURITY', 'FEDERAL BUILDING', '10 BROAD STREET', 'UTICA', 'NY', '13501', 
     '(877) 405-6750', '(833) 515-0469', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 43.101, -75.2351),

    ('NY11', 'JAMESTOWN NY', 'SOCIAL SECURITY', '', '321 HAZELTINE AVE', 'JAMESTOWN', 'NY', '14701', 
     '(877) 319-3079', '(833) 515-0471', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.097, -79.2364),

    ('NY12', 'SOUTH BRONX NY', 'SOCIAL SECURITY', '3RD FLOOR', '820 CONCOURSE VILLAGE WEST', 'BRONX', 'NY', '10451', 
     '(855) 531-1684', '(833) 515-0473', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.8195, -73.9236),

    ('NY13', 'YONKERS NY', 'SOCIAL SECURITY', 'SUITE 500', '20 SOUTH BROADWAY', 'YONKERS', 'NY', '10701', 
     '(866) 331-6404', '(833) 515-0475', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.932, -73.8983),

    ('NY14', 'HORSEHEADS NY', 'SOCIAL SECURITY', 'SUITE 19', '3345 CHAMBERS RD S', 'HORSEHEADS', 'NY', '14845', 
     '(866) 964-1715', '(833) 515-0477', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.1651, -76.8274),

    ('NY15', 'NIAGARA FALLS NY', 'SOCIAL SECURITY', '', '6540 NIAGARA FALLS BVD', 'NIAGARA FALLS', 'NY', '14304', 
     '(877) 480-4992', '(833) 515-0479', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 43.0976, -79.0367),

    ('NY16', 'OGDENSBURG NY', 'SOCIAL SECURITY', '', '101 FORD STREET', 'OGDENSBURG', 'NY', '13669', 
     '(866) 572-8369', '(833) 515-0481', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 44.6949, -75.4863),

    ('NY17', 'NY UPTOWN NY', 'SOCIAL SECURITY', '4TH FLOOR', '302 W 126TH ST', 'NEW YORK', 'NY', '10027', 
     '(866) 964-1301', '(833) 515-0483', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.8104, -73.9524),

    ('NY18', 'NEWBURGH NY', 'SOCIAL SECURITY', 'SUITE 301', '3 WASHINGTON CENTER', 'NEWBURGH', 'NY', '12550', 
     '(866) 504-4801', '(833) 902-2528', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 41.5034, -74.0104),

    ('NY19', 'REGO PARK NY', 'SOCIAL SECURITY', '', '6344 AUSTIN STREET', 'REGO PARK', 'NY', '11374', 
     '(877) 255-1506', '(833) 902-2530', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7292, -73.8616),

    ('NY20', 'JAMAICA NY', 'SOCIAL SECURITY', '3RD FL DISTRICT OFFICE', '155-10 JAMAICA AVE', 'JAMAICA', 'NY', '11432', 
     '(866) 592-0802', '(833) 902-2532', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7027, -73.7957),

    ('NY21', 'STATEN ISLAND NY', 'SOCIAL SECURITY', '', '1441 SOUTH AVE', 'STATEN ISLAND', 'NY', '10314', 
     '(866) 331-5288', '(833) 902-2534', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.6205, -74.1621),

    ('NY22', 'GLOVERSVILLE NY', 'SOCIAL SECURITY', '', '13 N ARLINGTON AVE', 'GLOVERSVILLE', 'NY', '12078', 
     '(888) 528-9446', '(833) 902-2536', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 43.0522, -74.3437),

    ('NY23', 'OSWEGO NY', 'SOCIAL SECURITY', '', '17 FOURTH AVE', 'OSWEGO', 'NY', '13126', 
     '(866) 964-7593', '(833) 902-2538', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 43.4553, -76.5105),

    ('NY24', 'PLATTSBURGH NY', 'SOCIAL SECURITY', 'SUITE 230', '14 DURKEE ST', 'PLATTSBURGH', 'NY', '12901', 
     '(866) 964-7430', '(833) 902-2540', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 44.6995, -73.4529),

    ('NY25', 'GLENS FALLS NY', 'SOCIAL SECURITY', 'SUITE 1', '67 WARREN ST', 'GLENS FALLS', 'NY', '12801', 
     '(877) 405-4875', '(833) 902-2541', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 43.3112, -73.6448),

    ('NY26', 'BROOKLYN FLATBUSH NY', 'SOCIAL SECURITY', '', '672 PARKSIDE AVE', 'BROOKLYN', 'NY', '11226', 
     '(866) 563-9461', '(833) 902-2544', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.656, -73.9485),

    ('NY27', 'NEW ROCHELLE NY', 'SOCIAL SECURITY', 'STREET LEVEL', '85 HARRISON ST', 'NEW ROCHELLE', 'NY', '10801', 
     '(855) 210-1026', '(833) 902-2551', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.9115, -73.7831),

    ('NY28', 'WATERTOWN NY', 'SOCIAL SECURITY', '', '156 BELLEW AVE SOUTH', 'WATERTOWN', 'NY', '13601', 
     '(866) 627-6995', '(833) 926-1866', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 43.9748, -75.9119),

    ('NY29', 'TROY NY', 'SOCIAL SECURITY', 'SUITE 101', '500 FEDERAL ST', 'TROY', 'NY', '12180', 
     '(866) 770-2662', '(833) 926-1868', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.7314, -73.6905),

    ('NY30', 'NORTH BRONX NY', 'SOCIAL SECURITY', '2ND FLOOR', '2501 GRAND CONCOURSE', 'BRONX', 'NY', '10468', 
     '(877) 619-2852', '(833) 873-4347', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.8607, -73.8949),
     
    ('NY31', 'POUGHKEEPSIE NY', 'SOCIAL SECURITY', '', '332 MAIN ST', 'POUGHKEEPSIE', 'NY', '12601', 
     '(877) 405-6747', '(833) 926-2689', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 41.7004, -73.9275),

    ('NY32', 'INWOOD HILL NY', 'SOCIAL SECURITY', '2ND FLOOR', '4941 BROADWAY', 'NEW YORK', 'NY', '10034', 
     '(877) 445-0838', '(833) 926-2691', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.8678, -73.9215),

    ('NY33', 'BROOKLYN BUSHWICK NY', 'SOCIAL SECURITY', 'THIRD FLOOR', '785 FLUSHING AVE', 'BROOKLYN', 'NY', '11206', 
     '(888) 327-1276', '(833) 926-2693', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7006, -73.9391),

    ('NY34', 'PATCHOGUE NY', 'SOCIAL SECURITY', '', '75 OAK STREET', 'PATCHOGUE', 'NY', '11772', 
     '(866) 771-1991', '(833) 926-2695', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7644, -73.0153),

    ('NY35', 'BROOKLYN NEW UTRECHT', 'SOCIAL SECURITY', '', '7714 17 AVENUE', 'BROOKLYN', 'NY', '11214', 
     '(866) 585-9320', '(833) 926-2697', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.6111, -73.9967),

    ('NY36', 'MINEOLA NY', 'SOCIAL SECURITY', '2ND FLOOR', '163 MINEOLA BLVD', 'MINEOLA', 'NY', '11501', 
     '(866) 758-1318', '(833) 939-1982', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7467, -73.6396),

    ('NY37', 'CYPRESS HILLS NY', 'SOCIAL SECURITY', '', '3386 FULTON STREET', 'BROOKLYN', 'NY', '11208', 
     '(866) 613-2767', '(833) 939-1984', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.6789, -73.8712),

    ('NY38', 'CORNING NY', 'SOCIAL SECURITY', '', '200 NASSER CIVIC CTR', 'CORNING', 'NY', '14830', 
     '(866) 591-3665', '(833) 950-2362', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.1429, -77.0562),

    ('NY39', 'GENEVA NY', 'SOCIAL SECURITY', '', '15 LEWIS ST', 'GENEVA', 'NY', '14456', 
     '(866) 331-7759', '(833) 950-2364', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.8671, -76.9857),

    ('NY40', 'OLEAN NY', 'SOCIAL SECURITY', '', '1618 W STATE ST', 'OLEAN', 'NY', '14760', 
     '(877) 319-5773', '(833) 950-2366', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.084, -78.4293),

    ('NY41', 'BATAVIA NY', 'SOCIAL SECURITY', '', '571 EAST MAIN STREET', 'BATAVIA', 'NY', '14020', 
     '(866) 931-7103', '(833) 950-2368', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.9981, -78.1774),

    ('NY42', 'MELVILLE NY', 'SOCIAL SECURITY', 'STE 201', '1121 WALT WHITMAN RD', 'MELVILLE', 'NY', '11747', 
     '(866) 964-0165', '(833) 950-2370', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7941, -73.4129),

    ('NY43', 'ONEONTA NY', 'SOCIAL SECURITY', 'SUITE 1', '31 MAIN ST', 'ONEONTA', 'NY', '13820', 
     '(877) 628-6581', '(833) 950-2372', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.4529, -75.0625),

    ('NY44', 'EAST BRONX NY', 'SOCIAL SECURITY', '2ND FLOOR', '1380 PARKER STREET', 'BRONX', 'NY', '10462', 
     '(866) 931-2526', '(833) 950-2374', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.8401, -73.8546),

    ('NY45', 'WHITE PLAINS NY', 'SOCIAL SECURITY', 'SUITE 4A', '297 KNOLLWOOD RD', 'WHITE PLAINS', 'NY', '10607', 
     '(866) 331-8134', '(833) 950-2376', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 41.0444, -73.8012),

    ('NY46', 'WEST NYACK NY', 'SOCIAL SECURITY', '', '240 WEST NYACK ROAD', 'WEST NYACK', 'NY', '10994', 
     '(866) 755-4334', '(833) 950-2378', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 41.0921, -73.9705),

    ('NY47', 'FLUSHING NY', 'SOCIAL SECURITY', '', '138-50 BARCLAY AVE', 'FLUSHING', 'NY', '11355', 
     '(877) 457-1735', '(833) 950-2380', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7584, -73.8276),

    ('NY48', 'FREEPORT NY', 'SOCIAL SECURITY', '', '84 N. MAIN STREET', 'FREEPORT', 'NY', '11520', 
     '(866) 964-0028', '(833) 950-2672', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.6581, -73.5838),

    ('NY49', 'ITHACA NY', 'SOCIAL SECURITY', '2ND FLOOR', '127 W STATE STREET', 'ITHACA', 'NY', '14850', 
     '(866) 706-8289', '(833) 950-2674', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.4396, -76.4966),

    ('NY50', 'HUDSON NY', 'SOCIAL SECURITY', '', '747 WARREN STREET', 'HUDSON', 'NY', '12534', 
     '(877) 828-1691', '(833) 950-2676', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.2498, -73.7851),

     ('NY51', 'MONTICELLO NY', 'SOCIAL SECURITY', 'SUITE 4', '60 JEFFERSON ST', 'MONTICELLO', 'NY', '12701', 
     '(855) 794-4728', '(833) 950-2678', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 41.6536, -74.691),

    ('NY52', 'NY EAST HARLEM NY', 'SOCIAL SECURITY', 'FLOOR 4', '345 E 102ND ST', 'NEW YORK', 'NY', '10029', 
     '(877) 445-0836', '(833) 950-2680', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7870, -73.9442),

    ('NY53', 'BRONX HUNTS POINT NY', 'SOCIAL SECURITY', '3RD FLOOR', '1029 E 163RD STREET', 'BRONX', 'NY', '10459', 
     '(866) 220-7889', '(833) 950-2682', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.8213, -73.8903),

    ('NY54', 'BEDFORD HEIGHTS NY', 'SOCIAL SECURITY', '', '1540 FULTON STREET', 'BROOKLYN', 'NY', '11216', 
     '(866) 592-4845', '(833) 950-2684', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.6805, -73.9408),

    ('NY55', 'ROCKAWAY PARK NY', 'SOCIAL SECURITY', '', '11306 ROCKAWAY BCH BLVD', 'ROCKAWAY PARK', 'NY', '11694', 
     '(866) 331-2310', '(833) 950-2686', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.5785, -73.8437),

    ('NY56', 'RIVERHEAD NY', 'SOCIAL SECURITY', '', '526 EAST MAIN STREET', 'RIVERHEAD', 'NY', '11901', 
     '(888) 397-9819', '(833) 950-2688', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.9170, -72.6605),

    ('NY57', 'LACONIA AVENUE NY', 'SOCIAL SECURITY', '', '3247 LACONIA AVE', 'BRONX', 'NY', '10469', 
     '(866) 347-0054', '(833) 950-2988', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.8706, -73.8543),

    ('NY58', 'PEEKSKILL NY', 'SOCIAL SECURITY', '3RD FLOOR', 'ONE PARK PLACE', 'PEEKSKILL', 'NY', '10566', 
     '(877) 840-5778', '(833) 950-2964', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 41.2901, -73.9188),

    ('NY59', 'EAST VILLAGE NY', 'SOCIAL SECURITY', '', '650 EAST 12TH ST', 'NEW YORK', 'NY', '10009', 
     '(877) 405-1447', '(833) 950-2966', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7265, -73.9792),

    ('NY60', 'RIDGE ROAD NY', 'SOCIAL SECURITY', 'SUITE 120', '1900 RIDGE RD', 'WEST SENECA', 'NY', '14224', 
     '(800) 647-9195', '(833) 950-2968', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.8397, -78.7543),

    ('NY61', 'WEST BABYLON NY', 'SOCIAL SECURITY', '', '510 PARK AVENUE', 'WEST BABYLON', 'NY', '11704', 
     '(866) 964-7375', '(833) 950-2970', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7144, -73.3536),

    ('NY62', 'LONG ISLAND CITY NY', 'SOCIAL SECURITY', 'GROUND FLOOR', '31-08 37TH AVENUE', 'LONG ISLAND CITY', 'NY', '11101', 
     '(866) 837-1096', '(833) 950-3266', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.7523, -73.9291),

    ('NY63', 'DUNKIRK NY', 'SOCIAL SECURITY', 'SUITE 2', '437 MAIN ST', 'DUNKIRK', 'NY', '14048', 
     '(888) 862-2139', '(833) 950-3277', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 42.4872, -79.3319),

    ('NY64', 'WEST FARMS NY', 'SOCIAL SECURITY', '', '1829 SOUTHERN BLVD', 'BRONX', 'NY', '10460', 
     '(866) 964-2558', '(833) 950-3281', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.8418, -73.8882),

    ('NY65', 'CANARSIE NY', 'SOCIAL SECURITY', '', '1871 ROCKAWAY PARKWAY', 'BROOKLYN', 'NY', '11236', 
     '(866) 667-7342', '(833) 950-3285', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.6395, -73.8901),

    ('NY66', 'HYLAN BLVD NY', 'SOCIAL SECURITY', '2ND FLOOR', '1510 HYLAN BLVD', 'STATEN ISLAND', 'NY', '10305', 
     '(877) 457-1736', '(833) 950-3287', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 40.5928, -74.0827),

    ('NY67', 'GREECE NY', 'SOCIAL SECURITY', '2ND FLOOR', '4050 W RIDGE RD', 'ROCHESTER', 'NY', '14626', 
     '(866) 331-2204', '(833) 950-3597', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', 
     '4:00 PM', '9:00 AM', '4:00 PM', '9:00 AM', '4:00 PM', 43.2132, -77.7085);


