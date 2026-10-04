# Hiring Cafe ELT Pipeline

An end-to-end pipeline for collecting, processing, transforming, and modeling job posting data from Hiring Cafe.

The pipeline uses SeleniumBase for web scraping, Apache Spark for data processing, Apache Airflow for orchestration, Google Cloud Storage and BigQuery for cloud storage and warehousing, and dbt for data transformation and testing.

## Architecture

The pipeline follows the general workflow:

```text
Hiring Cafe
    ↓
SeleniumBase Web Scraper
    ↓
Apache Spark Processing
    ↓
Local Parquet
    ↓
Google Cloud Storage
    ↓
BigQuery Bronze Layer
    ↓
dbt Silver Layer
    ↓
dbt Gold Layer
```

## Technology Stack

- **Python** — Core application and pipeline logic
- **SeleniumBase** — Dynamic web scraping
- **Apache Spark / PySpark** — Data processing
- **Apache Airflow** — Pipeline orchestration
- **Astronomer Cosmos** — dbt integration with Airflow
- **dbt** — SQL transformations and data testing
- **Google Cloud Storage** — Intermediate cloud storage
- **Google BigQuery** — Cloud data warehouse
- **Docker / Docker Compose** — Containerized development and execution

## Data Architecture

The BigQuery warehouse follows a medallion-style architecture.

### Bronze

The Bronze layer contains raw job posting data loaded from the ingestion pipeline with minimal transformation.

### Silver

The Silver layer cleans and standardizes the raw data into structures suitable for downstream modeling.

Transformations include data type handling, normalization, derived identifiers, and preparation of nested and repeated fields.

### Gold

The Gold layer provides analytics-ready dimensional models, including fact, dimension, and bridge tables.

See [Data Dictionary](datadictionary.md) for data definitions.

![HC ERD.png](https://github.com/chongha96/Hiring-Cafe-ELT/blob/main/HC%20ERD.png)

## Pipeline Orchestration

Apache Airflow manages the execution order of the pipeline.

The workflow follows:

```text
Crawler
   ↓
Upload to GCS
   ↓
Load BigQuery Bronze
   ↓
dbt Transformations
   ↓
Silver Models
   ↓
Gold Models
   ↓
dbt Tests
```

The crawler executes in its own Docker container, while Airflow manages orchestration and cloud operations.

Astronomer Cosmos converts the dbt dependency graph into Airflow tasks, allowing individual dbt models and tests to be monitored directly through the Airflow UI.

## dbt Testing

Data quality is validated using dbt tests throughout the transformation pipeline.

Current tests include:

- `unique` — validates uniqueness of primary/surrogate keys
- `not_null` — validates required fields
- `relationships` — validates referential integrity between fact, dimension, and bridge tables

For example, foreign keys in `fact_job_posting` are validated against their corresponding dimension tables.

Tests are organized alongside the Silver and Gold models in their respective YAML configuration files.

## Configuration

Create a local `.env` file based on:

```text
.env.example
```

The `.env` file contains environment-specific configuration and is intentionally excluded from version control.

Required configuration includes the relevant GCP project, dataset, bucket, and Airflow settings.

Google Cloud authentication for Airflow is managed through an **Airflow connection** rather than storing a service-account key file in the repository.

## Running the Project

### 1. Clone the repository

```bash
git clone <repository-url>
cd Hiring-Cafe-MLOps-Pipeline
```

### 2. Configure environment variables

Create `.env` from the provided example:

```bash
cp .env.example .env
```

Update the values for your environment.

### 3. Build the Docker images

```bash
docker compose build
```

### 4. Start Airflow

```bash
docker compose up
```

The Airflow web interface is available at:

```text
http://localhost:8080
```

### 5. Configure the Google Cloud connection

Create the Google Cloud connection required by the DAG in Airflow.

You must have a Google Service Account JSON Key. See this [guide](google_service_key.md) for how to get one.

The dbt/Cosmos configuration expects the Airflow connection:

```text
google_cloud_conn
```

This connection provides Google Cloud authentication to the Airflow-managed portions of the pipeline.

### 6. Run the DAG

From the Airflow UI, trigger:

```text
hiring_cafe_orchestration
```

Airflow will execute the pipeline according to the dependencies defined in the DAG.

## Docker Architecture

The project uses separate Docker images for pipeline processing and orchestration.

### Crawler Image

Built from the root `Dockerfile`.

Contains:

- Apache Spark
- Python
- SeleniumBase
- Google Chrome
- ChromeDriver
- Pipeline dependencies

### Airflow Image

Built from `airflow/Dockerfile`.

Contains:

- Apache Airflow
- Astronomer Cosmos
- dbt
- dbt-bigquery

dbt is installed in a dedicated Python virtual environment inside the Airflow image to isolate its dependencies from Airflow.

## Data Processing

The crawler retrieves Hiring Cafe job posting data using SeleniumBase and extracts the site's structured job data.

Spark processes the extracted records and writes the resulting dataset to Parquet before the orchestration pipeline moves the data into cloud storage and BigQuery.

The raw data is subsequently transformed through the dbt Silver and Gold layers.

## Incremental Processing

Where appropriate, dbt models use incremental materializations to avoid rebuilding complete datasets on every pipeline execution.

Surrogate keys generated with `dbt_utils.generate_surrogate_key` are used to identify dimensional records and relationships between fact, dimension, and bridge tables.

