-- SILVER: typed, cleaned, and checked. Expectations drop bad rows or fail the update, and the counts are logged
-- in the pipeline event log, which is how data quality is monitored.

CREATE OR REFRESH MATERIALIZED VIEW silver_patients (
  CONSTRAINT patient_id_present EXPECT (patient_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT birthdate_not_future EXPECT (birth_date <= current_date()) ON VIOLATION DROP ROW,
  CONSTRAINT valid_gender EXPECT (gender IN ('M', 'F'))
)
COMMENT 'One row per patient. Sensitive columns are protected by column masks in 04_governance.sql'
AS SELECT
  Id AS patient_id, to_date(BIRTHDATE) AS birth_date, to_date(DEATHDATE) AS death_date,
  SSN AS ssn, FIRST AS first_name, LAST AS last_name, GENDER AS gender,
  RACE AS race, CITY AS city, STATE AS state
FROM bronze_patients;

CREATE OR REFRESH MATERIALIZED VIEW silver_encounters (
  CONSTRAINT encounter_id_present EXPECT (encounter_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT ends_after_start EXPECT (stop_ts >= start_ts) ON VIOLATION DROP ROW,
  CONSTRAINT claim_not_negative EXPECT (total_claim_cost >= 0) ON VIOLATION DROP ROW
)
AS SELECT
  Id AS encounter_id, PATIENT AS patient_id, PAYER AS payer_id, ENCOUNTERCLASS AS encounter_class,
  to_timestamp(START) AS start_ts, to_timestamp(STOP) AS stop_ts,
  CAST(BASE_ENCOUNTER_COST AS DOUBLE) AS base_cost, CAST(TOTAL_CLAIM_COST AS DOUBLE) AS total_claim_cost, CAST(PAYER_COVERAGE AS DOUBLE) AS payer_coverage
FROM bronze_encounters;

CREATE OR REFRESH MATERIALIZED VIEW silver_conditions (
  CONSTRAINT patient_present EXPECT (patient_id IS NOT NULL) ON VIOLATION DROP ROW
)
AS SELECT PATIENT AS patient_id, ENCOUNTER AS encounter_id, CODE AS code, DESCRIPTION AS description,
  to_date(START) AS start_date, to_date(STOP) AS stop_date
FROM bronze_conditions;

CREATE OR REFRESH MATERIALIZED VIEW silver_payers
AS SELECT Id AS payer_id, NAME AS payer_name, OWNERSHIP AS ownership FROM bronze_payers;
