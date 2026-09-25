{{ config(
    materialized='incremental',
    unique_key=['job_id', 'field_id']
) }}

WITH job_fields AS (
    SELECT DISTINCT
        job_id,
        field_name
    FROM {{ ref('int_jobs') }},
    UNNEST(degree_field_of_study) AS field_name
)

SELECT
    jf.job_id,
    dc.field_id

FROM job_fields jf

INNER JOIN {{ ref('dim_field_of_study') }} dc
    ON jf.field_name = dc.field_name

{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} existing
    WHERE existing.job_id = jf.job_id
      AND existing.field_id = dc.field_id
)
{% endif %}