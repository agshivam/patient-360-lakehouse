# How to run Patient-360 Lakehouse

## A. Look at the report now (no Databricks)
```bash
git clone https://github.com/agshivam/patient-360-lakehouse && cd patient-360-lakehouse
pip install -r requirements.txt
streamlit run app/streamlit_app.py
```

## B. Run the lakehouse on Databricks Free Edition (week 5, about 45 minutes)
1. Sign up at databricks.com (Free Edition). No card needed.
2. Make Synthea data: follow `patient-360/HOW_TO_RUN.md` (it produces `patients.csv`, `encounters.csv`, `conditions.csv`, `payers.csv`).
3. In the Databricks SQL editor, run `setup/00_setup.sql`.
4. In Catalog, open `patient360` > `landing` > `synthea`, create folders `patients`, `encounters`, `conditions`, `payers`, and upload each CSV into its folder.
5. Deploy the pipeline. Either:
   - Install the CLI (`pip install databricks-cli` is old; use the Databricks CLI from the docs), run `databricks auth login`, then
     `databricks bundle deploy -t dev` and `databricks bundle run patient360_pipeline -t dev`; or
   - In the UI: Jobs and Pipelines > Create pipeline > add the three files in `pipeline/` > set `landing_path` to `/Volumes/patient360/landing/synthea` > Start.
6. Run `setup/04_governance.sql`, then check as a non-member of `clinicians` that SSN shows as `***-**-1234`.
7. Prove it matches: export each gold table as CSV into a local `exports/` folder (names: `gold_encounters_by_year_class.csv`, `gold_payer_cost.csv`, `gold_top_disorders.csv`), then `python scripts/reconcile.py`. Expect all `match`.

Send Claude the pipeline error text if anything fails, and it will fix the SQL.

## Troubleshooting
- `read_files` finds nothing: check the folder names and that `landing_path` has no trailing slash.
- Mask statement rejected on a materialized view: see the note in `setup/04_governance.sql`.
- Reconcile says `differs`: the Synthea sample differs from the one used for the reference; regenerate both from the same seed.
