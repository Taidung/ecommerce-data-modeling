import dagster as dg
from ..defs.dlt.assets import dlt_load
from ..defs.dbt.assets import dbt_models

ingestion_job = dg.define_asset_job(
    name="ingestion_job",
    selection=[dlt_load],
)

transformation_job = dg.define_asset_job(
    name="transformation_job",
    selection=[dbt_models],
)   