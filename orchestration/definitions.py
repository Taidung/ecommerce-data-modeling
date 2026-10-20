from dagster import Definitions, load_assets_from_modules

from .defs.dbt import assets as dbt_assets_module
from .defs.dlt import assets as dlt_assets_module
from .defs.dbt.resources import dbt_resource
from .defs.dlt.resources import dlt_resource

from .jobs.jobs import ingestion_job, transformation_job
from .schedules.schedules import monthly_ingestion_schedule
from .sensors.sensors import run_dbt_after_ingestion

dlt_assets = load_assets_from_modules(
    [dlt_assets_module], 
    group_name="ingestion"
)

dbt_assets = load_assets_from_modules(
    [dbt_assets_module],
)


defs = Definitions(
    assets=[*dlt_assets, *dbt_assets],
    jobs=[ingestion_job, transformation_job],
    schedules=[monthly_ingestion_schedule],
    sensors=[run_dbt_after_ingestion],
    resources={
        "dlt": dlt_resource,
        "dbt": dbt_resource,
    },
)