{{ config(
    materialized='incremental',
    unique_key=['job_id', 'language_id']
) }}

WITH job_langs AS (
    SELECT DISTINCT
        job_id,
        lang.element as language_name
    FROM {{ ref('int_jobs') }},
    UNNEST(language.list) AS lang
)

SELECT
    jl.job_id,
    dl.language_id

FROM job_langs jl
INNER JOIN {{ ref('dim_language') }} dl
    ON jl.language_name = dl.language_name

{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} existing
    WHERE existing.job_id = jl.job_id
      AND existing.language_id = dl.language_id
)
{% endif %}