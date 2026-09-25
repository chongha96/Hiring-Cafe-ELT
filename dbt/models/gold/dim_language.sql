{{ config(
    materialized='incremental',
    unique_key='language_id'
) }}

WITH languages AS (
    SELECT DISTINCT
        lang.element as language_name
    FROM {{ ref('int_jobs') }},
    UNNEST(language.list) AS lang
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'language_name'
    ]) }} AS language_id,
    language_name

FROM languages

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key([
    'language_name'
]) }} NOT IN (
    SELECT language_id
    FROM {{ this }}
)
{% endif %}