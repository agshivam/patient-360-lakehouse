# Patient-360 on Databricks

The Patient-360 platform rebuilt as a lakehouse on Databricks Free Edition, with a written comparison to the Snowflake version.

**Status:** planned, build starts in week 5. All data is public or synthetic. No employer data is used.

## Plan

1. Land synthetic patient files in a Unity Catalog volume.
2. Build bronze, silver and gold layers with Auto Loader and declarative pipelines.
3. Package as a Databricks Asset Bundle.
4. Write the Snowflake versus Databricks decision record.

## Part of a series

This is one of six portfolio projects. The first one, [patient-360](https://github.com/agshivam/patient-360), is already live with a [running report](https://patient-360.streamlit.app/). Portfolio: https://agshivam.github.io
