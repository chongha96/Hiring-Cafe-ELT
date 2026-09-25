{{ config(
    materialized='incremental',
    unique_key='company_id'
) }}

SELECT DISTINCT
    company_id,
    company AS company_name,
    company_sector,
    job_category
FROM {{ ref('int_jobs') }}

{% if is_incremental() %}
WHERE company_id NOT IN (
    SELECT company_id
    FROM {{ this }}
)
{% endif %}