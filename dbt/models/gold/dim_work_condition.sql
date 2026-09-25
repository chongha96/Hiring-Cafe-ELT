{{ config(
    materialized='incremental',
    unique_key='condition_id'
) }}

SELECT DISTINCT
    condition_id,
    workplace as work_setting,
    work_environment
FROM {{ ref('int_jobs') }}

{% if is_incremental() %}
WHERE condition_id NOT IN (
    SELECT condition_id
    FROM {{ this }}
)
{% endif %}