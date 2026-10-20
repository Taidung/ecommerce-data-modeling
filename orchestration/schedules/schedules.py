import dagster as dg
from ..jobs.jobs import ingestion_job

monthly_ingestion_schedule = dg.ScheduleDefinition(
    name="monthly_ingestion_schedule",
    job=ingestion_job,
    cron_schedule="0 7 1 * *",
    execution_timezone="Asia/Ho_Chi_Minh",
)