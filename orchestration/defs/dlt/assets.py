import dlt
from dagster import AssetExecutionContext
from dagster_dlt import DagsterDltResource, dlt_assets

from ingestion.load_data import source as data_source
from ingestion.load_data import pipeline as data_pipeline

@dlt_assets(
    dlt_source=data_source(),
    dlt_pipeline=data_pipeline()
)
def dlt_load(context: AssetExecutionContext, dlt: DagsterDltResource):
    yield from dlt.run(context=context, write_disposition='replace')