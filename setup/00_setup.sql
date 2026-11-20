-- Run once in a Databricks SQL editor or notebook. Creates the catalog, schemas and the landing volume.
CREATE CATALOG IF NOT EXISTS patient360;
CREATE SCHEMA IF NOT EXISTS patient360.landing;
CREATE SCHEMA IF NOT EXISTS patient360.bronze;
CREATE SCHEMA IF NOT EXISTS patient360.silver;
CREATE SCHEMA IF NOT EXISTS patient360.gold;
CREATE VOLUME IF NOT EXISTS patient360.landing.synthea;
-- Then upload the Synthea CSVs (patients.csv, encounters.csv, conditions.csv, payers.csv) into
-- /Volumes/patient360/landing/synthea/<name>/ , one folder per table, e.g. .../patients/patients.csv
