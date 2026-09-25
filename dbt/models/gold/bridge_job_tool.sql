{{ config(
    materialized='incremental',
    unique_key=['job_id', 'tool_id']
) }}

WITH job_tools AS (
    SELECT DISTINCT
        job_id,
        tool_name
    FROM {{ ref('int_jobs') }},
    UNNEST(technical_tools) AS tool_name
)

SELECT DISTINCT
    jt.job_id,
    dt.tool_id

FROM job_tools jt

INNER JOIN {{ ref('dim_tool') }} dt
    ON jt.tool_name = dt.tool_name

{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} existing
    WHERE existing.job_id = jt.job_id
      AND existing.tool_id = dt.tool_id
)
{% endif %}