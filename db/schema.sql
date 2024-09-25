-- db/schema.sql
DROP DATABASE IF EXISTS patio_dev;
CREATE DATABASE patio_dev;

\c patio_dev;

DROP TABLE IF EXISTS responses;

CREATE TABLE responses (
 id SERIAL PRIMARY KEY,
 message TEXT
);