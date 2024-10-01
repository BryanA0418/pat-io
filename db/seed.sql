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
