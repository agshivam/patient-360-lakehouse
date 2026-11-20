# ADR-001: Snowflake or Databricks for the Patient-360 platform?

Status: accepted for this portfolio. Both versions are built so the choice is shown, not claimed.

## Context
The same hospital-style data (synthetic Synthea patients) is modeled twice: with dbt on Snowflake/DuckDB in [patient-360](https://github.com/agshivam/patient-360), and here as a lakehouse on Databricks.

## How they differ in this project
| Question | Snowflake + dbt | Databricks lakehouse |
| --- | --- | --- |
| Where transformations live | dbt SQL models, tested in CI | Declarative pipeline SQL with expectations |
| Ingestion | Fivetran / COPY / Snowpipe | Auto Loader (`read_files`) with incremental checkpoints |
| Data quality | dbt tests (fail the build) | Expectations (warn, drop row, or fail update), logged in the event log |
| Governance | Masking policies, roles, row access policies | Unity Catalog column masks, row filters, groups |
| Storage | Managed tables | Delta tables, open format files in a volume |
| Strong when | SQL-first teams, BI-heavy workloads, simple operations | Mixed SQL, Python and ML, streaming, large unstructured data |
| Cost lever | Warehouse size, auto-suspend, resource monitors | Serverless compute, cluster policies, job vs interactive |

## Decision guide
- Choose Snowflake when most consumers are analysts and BI tools, and the team wants low operations effort.
- Choose Databricks when the same data feeds ML, streaming or files that are not tables.
- Keep business logic in SQL either way, so a later move is a port, not a rewrite. The gold tables here use the same names and numbers as the Snowflake version; `scripts/reconcile.py` checks that.

## Consequences
Two platforms to maintain in this repo family. Accepted, because the comparison is the point.
