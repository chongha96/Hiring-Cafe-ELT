{{ config(
    materialized='incremental',
    unique_key='field_id'
) }}

WITH fields AS (
    SELECT DISTINCT
        field_name
    FROM {{ ref('int_jobs') }},
    UNNEST(degree_field_of_study) AS field_name
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'field_name'
    ]) }} AS field_id,
    field_name
FROM fields

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key([
    'field_name'
]) }} NOT IN (
    SELECT field_id
    FROM {{ this }}
)
{% endif %}