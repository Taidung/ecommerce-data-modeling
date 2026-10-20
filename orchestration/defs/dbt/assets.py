from dagster_dbt import DbtCliResource, dbt_assets
import dagster as dg
from .resources import dbt_project

@dbt_assets(manifest=dbt_project.manifest_path)
def dbt_models(context: dg.AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()

dbt_models = dbt_models.map_asset_specs(
        lambda spec: spec.replace_attributes(
        group_name=f"transformation/{spec.group_name}"
    )
)