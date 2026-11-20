-- GOVERNANCE (Unity Catalog). Run after the first pipeline update has created the silver tables.
-- Column mask: only members of the group `clinicians` see a full SSN; everyone else sees ***-**-1234.
CREATE OR REPLACE FUNCTION patient360.silver.mask_ssn(ssn STRING)
RETURN CASE WHEN is_account_group_member('clinicians') THEN ssn ELSE concat('***-**-', right(ssn, 4)) END;

ALTER TABLE patient360.silver.silver_patients ALTER COLUMN ssn SET MASK patient360.silver.mask_ssn;
-- NOTE: materialized views inside a pipeline may not accept ALTER ... SET MASK on every workspace tier.
-- If that errors on Free Edition, apply the mask to a regular table copy instead and note it in docs/FINDINGS.md.

-- Row-level access example: analysts only see patients in their own state.
-- CREATE FUNCTION patient360.silver.state_filter(state STRING) RETURN is_account_group_member('admin') OR state = 'MA';
-- ALTER TABLE patient360.silver.silver_patients SET ROW FILTER patient360.silver.state_filter ON (state);
