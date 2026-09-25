# Google Cloud Service Account Setup

This project uses a Google Cloud service account to allow Airflow to authenticate with Google Cloud services such as BigQuery and Google Cloud Storage.

> **Security Warning:** A service account JSON key contains private credentials. Never commit the JSON key to GitHub or include it in the Docker image.

## 1. Select Your Google Cloud Project

Open the Google Cloud Console and select the project that will be used for the pipeline.

Make note of the **Project ID**, as it will also be required in the project's `.env` configuration.

## 2. Create a Service Account

In the Google Cloud Console, navigate to:

**IAM & Admin → Service Accounts**

Select **Create service account**.

Enter a name for the service account, for example:

```text
hiring-cafe-pipeline