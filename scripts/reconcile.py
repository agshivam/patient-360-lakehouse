"""Compare the Databricks gold tables with the Snowflake/DuckDB reference from the patient-360 repo.
Export each gold table from Databricks as CSV into  exports/<table>.csv  (SQL editor, Download), then:
    python scripts/reconcile.py
Writes app_data/reconciliation.parquet, which the Streamlit report shows."""
import sys
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
REF = ROOT / "app_data" / "reference"
EXP = ROOT / "exports"
PAIRS = {  # gold table -> (reference file, key columns, measure columns)
    "gold_encounters_by_year_class": ("agg_encounters_by_year_class", ["year", "encounter_class"], ["encounters"]),
    "gold_payer_cost": ("agg_payer_cost", ["payer"], ["encounters", "claim_cost"]),
    "gold_top_disorders": ("agg_top_disorders", ["disorder"], ["patients"]),
}


def compare(name, ref_file, keys, measures):
    f = EXP / f"{name}.csv"
    if not f.exists():
        return {"table": name, "status": "not exported yet", "rows_reference": None, "rows_lakehouse": None, "mismatches": None}
    ref = pd.read_parquet(REF / f"{ref_file}.parquet")
    lake = pd.read_csv(f)
    ref.columns = [c.lower() for c in ref.columns]
    lake.columns = [c.lower() for c in lake.columns]
    m = ref.merge(lake, on=keys, how="outer", suffixes=("_ref", "_lake"), indicator=True)
    differs = m["_merge"] != "both"
    for c in measures:   # numbers match when they agree to one cent
        differs |= (m[f"{c}_ref"] - m[f"{c}_lake"]).abs() > 0.01
    bad = m[differs]
    return {"table": name, "status": "match" if bad.empty else "differs", "rows_reference": len(ref),
            "rows_lakehouse": len(lake), "mismatches": len(bad)}


if __name__ == "__main__":
    rows = [compare(n, *v) for n, v in PAIRS.items()]
    out = pd.DataFrame(rows)
    out.to_parquet(ROOT / "app_data" / "reconciliation.parquet", index=False)
    print(out.to_string(index=False))
    sys.exit(1 if (out["status"] == "differs").any() else 0)
