{{ config(
    materialized='incremental',
    unique_key='certification_id'
) }}

WITH certifications AS (
    SELECT DISTINCT
        certification_name
    FROM {{ ref('int_jobs') }},
    UNNEST(certifications) AS certification_name
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'certification_name'
    ]) }} AS certification_id,
    certification_name

FROM certifications

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key([
    'certification_name'
]) }} NOT IN (
    SELECT certification_id
    FROM {{ this }}
)
{% endif %}