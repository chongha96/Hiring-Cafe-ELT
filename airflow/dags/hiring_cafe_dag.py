from datetime import timedelta
import os
import pendulum

from airflow import DAG
from airflow.exceptions import AirflowSkipException
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator

from docker.types import Mount

from cosmos import DbtTaskGroup,ProjectConfig,ProfileConfig,ExecutionConfig,RenderConfig
from cosmos.profiles import GoogleCloudServiceAccountDictProfileMapping


pst_tz = pendulum.timezone("America/Los_Angeles")

default_args = {
    "owner": "de",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

#Gets host path for usage in tasks
host_project_path = os.environ.get("HOST_PROJECT_PATH")
if not host_project_path or host_project_path == ".":
    host_project_path = os.path.abspath(os.path.dirname(__file__))

#Crawler skips from 12:00 - 8:00 AM
def skip_sleep_hours(**context):
    logical_date = context["logical_date"].in_timezone(pst_tz)
    if 0 <= logical_date.hour < 8:
        raise AirflowSkipException("Sleep hours window: 12:00 - 8:00 AM PST")


with DAG(
    dag_id="hiring_cafe_orchestration",
    description="Crawler + GCS + BigQuery + dbt pipeline",
    default_args=default_args,
    schedule="0 * * * *",
    start_date=pendulum.datetime(2026, 1, 1, tz=pst_tz),
    catchup=False,
    max_active_runs=1,
    tags=["crawler", "gcs", "bigquery", "dbt", "hiring-cafe"],
):

    #Skips task if between 12:00 - 8:00 AM
    check_hours = PythonOperator(
        task_id="check_sleep_hours",
        python_callable=skip_sleep_hours,
    )

    # Calls the crawler
    run_crawler = DockerOperator(
        task_id="run_crawler",
        image="hiring-cafe-crawler:latest",
        command="python3 -m crawler.main",
        auto_remove="success",
        mount_tmp_dir=False,
        tty=True,
        working_dir="/app",
        mounts=[
            Mount(
                source=str(host_project_path),
                target="/app",
                type="bind",
            ),
        ],
        environment={
            "PYTHONUNBUFFERED": "1",
        },
    )


    #Upload payload parquet to GCS bucket
    upload_to_gcs = LocalFilesystemToGCSOperator(
        task_id="upload_to_gcs",

        src="/opt/airflow/data/job_data/*.parquet",

        bucket=os.environ["GCP_TEMP_BUCKET"],

        dst="staging/job_data/",

        gcp_conn_id="google_cloud_conn",
    )


    #Load data from GCS bucket to BQ
    load_bigquery = GCSToBigQueryOperator(
        task_id="load_bigquery",

        bucket=os.environ["GCP_TEMP_BUCKET"],

        source_objects=[
            "staging/job_data/*.parquet"
        ],

        destination_project_dataset_table=(
            f"{os.environ['GCP_PROJECT_ID']}."
            f"{os.environ['GCP_BRONZE_DATASET_ID']}."
            "job_data"
        ),

        source_format="PARQUET",
        write_disposition="WRITE_TRUNCATE",
        autodetect=True,

        gcp_conn_id="google_cloud_conn",
    )


    #Run DBT transformations via Cosmos
    run_dbt = DbtTaskGroup(
        group_id="run_dbt",

        project_config=ProjectConfig(
            dbt_project_path="/opt/airflow/dbt",
        ),

        profile_config=ProfileConfig(
            profile_name="hiring_cafe_profile",
            target_name="dev",

            profile_mapping=GoogleCloudServiceAccountDictProfileMapping(
                conn_id="google_cloud_conn",
                profile_args={
                    "project": os.environ["GCP_PROJECT_ID"],
                    "dataset": os.environ["GCP_BRONZE_DATASET_ID"],
                },
            ),
        ),

        execution_config=ExecutionConfig(
            dbt_executable_path="/opt/airflow/dbt_venv/bin/dbt",
        ),
        #Ensures tasks are performed in the correct order, respective of testing
        render_config=RenderConfig(
            should_detach_multiple_parents_tests=True,
        ),

        operator_args={
            "install_deps": True,
        },
    )


    check_hours >> run_crawler >> upload_to_gcs >> load_bigquery >> run_dbt