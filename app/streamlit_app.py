from pathlib import Path

import altair as alt
import pandas as pd
import streamlit as st

st.set_page_config(page_title="Patient-360 Lakehouse", layout="wide")
D = Path(__file__).resolve().parent.parent / "app_data"
st.title("Patient-360 Lakehouse")
st.caption("The Patient-360 hospital data on Databricks: bronze, silver, gold, with Unity Catalog governance. "
           "Synthetic Synthea data only. Numbers below are the reference results the lakehouse gold tables are checked against.")

ref = D / "reference"
enc = pd.read_parquet(ref / "agg_encounters_by_year_class.parquet")
payer = pd.read_parquet(ref / "agg_payer_cost.parquet")
dis = pd.read_parquet(ref / "agg_top_disorders.parquet")

t1, t2, t3 = st.tabs(["Encounters", "Payers", "Reconciliation"])
with t1:
    classes = st.multiselect("Encounter class", sorted(enc["encounter_class"].unique()), default=sorted(enc["encounter_class"].unique()))
    v = enc[enc["encounter_class"].isin(classes)]
    st.altair_chart(alt.Chart(v).mark_bar().encode(x="year:O", y="encounters:Q", color="encounter_class:N",
                    tooltip=["year", "encounter_class", "encounters"]), width="stretch")
with t2:
    p = payer.copy()
    p["claim_cost"] = p["claim_cost"].astype(float)
    st.altair_chart(alt.Chart(p).mark_bar().encode(y=alt.Y("payer:N", sort="-x"), x="claim_cost:Q",
                    tooltip=["payer", "encounters", "claim_cost"]), width="stretch")
with t3:
    st.write("Each Databricks gold table is exported and compared with the Snowflake/DuckDB result, row by row.")
    f = D / "reconciliation.parquet"
    if f.exists():
        st.dataframe(pd.read_parquet(f), hide_index=True, width="stretch")
    else:
        st.info("Run `python scripts/reconcile.py` after exporting the gold tables.")
