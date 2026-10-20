from pathlib import Path
from dagster_dbt import DbtCliResource, DbtProject
import dagster as dg

dbt_project_directory = Path(__file__).resolve().parents[3] / "dbt_model"
dbt_project = DbtProject(
    project_dir=dbt_project_directory,
    profiles_dir=dbt_project_directory,    
)

dbt_resource = DbtCliResource(project_dir=dbt_project)


