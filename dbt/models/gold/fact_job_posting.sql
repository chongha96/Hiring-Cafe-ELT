{{ config(
    materialized='incremental',
    unique_key='job_id'
) }}

SELECT
    job_id,
    date_posted,

    company_id,
    benefit_id,
    education_id,
    condition_id,
    requirement_id,
    job_title,
    job_level,
    job_type,
    job_yoe,
    management_yoe,
    comp_format as comp_format,
    comp_min,
    comp_max

FROM {{ ref('int_jobs') }}

{% if is_incremental() %}
WHERE job_id NOT IN (
    SELECT job_id
    FROM {{ this }}
)
{% endif %}