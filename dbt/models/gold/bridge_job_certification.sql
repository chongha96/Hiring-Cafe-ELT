{{ config(
    materialized='incremental',
    unique_key=['job_id', 'certification_id']
) }}

WITH job_certs AS (
    SELECT DISTINCT
        job_id,
        certification_name
    FROM {{ ref('int_jobs') }},
    UNNEST(certifications) AS certification_name
)

SELECT
    jc.job_id,
    dc.certification_id

FROM job_certs jc

INNER JOIN {{ ref('dim_certification') }} dc
    ON jc.certification_name = dc.certification_name

{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} existing
    WHERE existing.job_id = jc.job_id
      AND existing.certification_id = dc.certification_id
)
{% endif %}