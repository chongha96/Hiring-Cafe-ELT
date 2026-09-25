{{ config(
    materialized='incremental',
    unique_key='tool_id'
) }}

WITH tools AS (
    SELECT DISTINCT
        tool_name
    FROM {{ ref('int_jobs') }},
    UNNEST(technical_tools) AS tool_name
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'tool_name'
    ]) }} AS tool_id,
    tool_name

FROM tools

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key([
    'tool_name'
]) }} NOT IN (
    SELECT tool_id
    FROM {{ this }}
)
{% endif %}