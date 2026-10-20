import dagster as dg

from ..jobs.jobs import ingestion_job, transformation_job

@dg.run_status_sensor(
    run_status=dg.DagsterRunStatus.SUCCESS,
    monitored_jobs=[ingestion_job],
    request_job=transformation_job,
)

def run_dbt_after_ingestion(context: dg.RunStatusSensorContext):
    return dg.RunRequest(
        run_key=context.dagster_run.run_id
    )