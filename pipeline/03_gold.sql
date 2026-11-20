-- GOLD: business-ready tables. Names and numbers match the Snowflake/DuckDB version in the patient-360 repo,
-- so scripts/reconcile.py can prove both platforms give the same answers.

CREATE OR REFRESH MATERIALIZED VIEW gold_encounters_by_year_class
AS SELECT year(start_ts) AS year, encounter_class, count(*) AS encounters
FROM silver_encounters GROUP BY 1, 2;

CREATE OR REFRESH MATERIALIZED VIEW gold_payer_cost
AS SELECT p.payer_name AS payer, count(*) AS encounters, sum(e.total_claim_cost) AS claim_cost,
          sum(e.payer_coverage) AS payer_paid
FROM silver_encounters e JOIN silver_payers p USING (payer_id) GROUP BY 1;

CREATE OR REFRESH MATERIALIZED VIEW gold_top_disorders
AS SELECT description AS disorder, count(DISTINCT patient_id) AS patients
FROM silver_conditions WHERE lower(description) LIKE '%(disorder)%' GROUP BY 1;

CREATE OR REFRESH MATERIALIZED VIEW gold_age_gender
AS SELECT gender,
  CASE WHEN age < 18 THEN '0-17' WHEN age < 40 THEN '18-39' WHEN age < 65 THEN '40-64' ELSE '65+' END AS age_band,
  count(*) AS patients
FROM (SELECT gender, floor(months_between(coalesce(death_date, current_date()), birth_date) / 12) AS age FROM silver_patients)
GROUP BY 1, 2;
