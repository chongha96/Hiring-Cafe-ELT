FROM apache/airflow:3.3.2-python3.12

RUN pip install --no-cache-dir \
    "apache-airflow==3.3.2" \
    "astronomer-cosmos"

RUN python -m venv /opt/airflow/dbt_venv \
    && /opt/airflow/dbt_venv/bin/pip install --no-cache-dir \
       "dbt-bigquery==1.7.9"