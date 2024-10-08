DROP DATABASE IF EXISTS patio_dev;
CREATE DATABASE patio_dev;

\c patio_dev;

-- Drop existing visa_status table if it exists
DROP TABLE IF EXISTS visa_status;

-- Create the visa_status table
CREATE TABLE visa_status (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    qualify_for_ssn BOOLEAN,
    government_document_required BOOLEAN
);

-- Drop existing id_requirements table if it exists
DROP TABLE IF EXISTS id_requirements;

-- Create the id_requirements table
CREATE TABLE id_requirements (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    form_number TEXT,
    description TEXT NOT NULL
);

-- Drop existing visa_requirements table if it exists
DROP TABLE IF EXISTS visa_requirements;

-- Create the visa_requirements table (junction table)
CREATE TABLE visa_requirements (
    visa_status_id INTEGER REFERENCES visa_status(id),
    id_requirements_id INTEGER REFERENCES id_requirements(id),
    PRIMARY KEY (visa_status_id, id_requirements_id) -- Composite primary key
);

-- Create the office_open_close_times table
CREATE TABLE office_open_close_times (
    id SERIAL PRIMARY KEY,
    office_code VARCHAR(10),
    office_name VARCHAR(100),
    address_line_1 VARCHAR(255),
    address_line_2 VARCHAR(255),
    address_line_3 VARCHAR(255),
    city VARCHAR(100),
    state CHAR(2),
    zip_code VARCHAR(10),
    phone VARCHAR(20),
    fax VARCHAR(20),
    monday_open_time VARCHAR(10),
    monday_close_time VARCHAR(10),
    tuesday_open_time VARCHAR(10),
    tuesday_close_time VARCHAR(10),
    wednesday_open_time VARCHAR(10),
    wednesday_close_time VARCHAR(10),
    thursday_open_time VARCHAR(10),
    thursday_close_time VARCHAR(10),
    friday_open_time VARCHAR(10),
    friday_close_time VARCHAR(10),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL
);