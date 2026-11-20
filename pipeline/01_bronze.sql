-- BRONZE: raw files, ingested incrementally with Auto Loader. Nothing is changed except a load timestamp and file name.
CREATE OR REFRESH STREAMING TABLE bronze_patients
COMMENT 'Raw Synthea patients'
AS SELECT *, current_timestamp() AS _ingested_at, _metadata.file_path AS _source_file
FROM STREAM read_files('${landing_path}/patients/', format => 'csv', header => true);

CREATE OR REFRESH STREAMING TABLE bronze_encounters
COMMENT 'Raw Synthea encounters'
AS SELECT *, current_timestamp() AS _ingested_at, _metadata.file_path AS _source_file
FROM STREAM read_files('${landing_path}/encounters/', format => 'csv', header => true);

CREATE OR REFRESH STREAMING TABLE bronze_conditions
COMMENT 'Raw Synthea conditions'
AS SELECT *, current_timestamp() AS _ingested_at, _metadata.file_path AS _source_file
FROM STREAM read_files('${landing_path}/conditions/', format => 'csv', header => true);

CREATE OR REFRESH STREAMING TABLE bronze_payers
COMMENT 'Raw Synthea payers'
AS SELECT *, current_timestamp() AS _ingested_at, _metadata.file_path AS _source_file
FROM STREAM read_files('${landing_path}/payers/', format => 'csv', header => true);
