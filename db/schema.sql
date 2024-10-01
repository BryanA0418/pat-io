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
