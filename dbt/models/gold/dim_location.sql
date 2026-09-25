{{ config(
    materialized='incremental',
    unique_key='location_id'
) }}


WITH locations AS (
    SELECT DISTINCT
        city_location.element AS city_location
    FROM {{ ref('int_jobs') }},
    UNNEST(city.list) AS city_location
    WHERE city_location.element IS NOT NULL
      AND TRIM(city_location.element) != ''
),

parsed_locations AS (
    SELECT DISTINCT
        TRIM(SPLIT(city_location, ',')[SAFE_OFFSET(0)]) AS city_name,
        TRIM(SPLIT(city_location, ',')[SAFE_OFFSET(1)]) AS state_name,
        TRIM(SPLIT(city_location, ',')[SAFE_OFFSET(2)]) AS country_name
    FROM locations
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'city_name',
        'state_name',
        'country_name'
    ]) }} AS location_id,
    city_name,
    state_name,
    country_name

FROM parsed_locations