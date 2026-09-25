{{ config(
    materialized='incremental',
    unique_key=['job_id', 'location_id']
) }}

WITH job_locations AS (
    SELECT DISTINCT
        job_id,
        city_location.element AS city_location
    FROM {{ ref('int_jobs') }},
    UNNEST(city.list) AS city_location
    WHERE city_location.element IS NOT NULL
      AND TRIM(city_location.element) != ''
),

parsed_locations AS (
    SELECT DISTINCT
        job_id,
        TRIM(SPLIT(city_location, ',')[SAFE_OFFSET(0)]) AS city_name,
        TRIM(SPLIT(city_location, ',')[SAFE_OFFSET(1)]) AS state_name,
        TRIM(SPLIT(city_location, ',')[SAFE_OFFSET(2)]) AS country_name
    FROM job_locations
)

SELECT
    pl.job_id,
    dl.location_id

FROM parsed_locations pl

INNER JOIN {{ ref('dim_location') }} dl
    ON pl.city_name = dl.city_name
    AND pl.state_name = dl.state_name
    AND pl.country_name = dl.country_name

{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} existing
    WHERE existing.job_id = pl.job_id
      AND existing.location_id = dl.location_id
)
{% endif %}