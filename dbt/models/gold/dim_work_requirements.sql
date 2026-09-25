{{ config(
    materialized='incremental',
    unique_key='requirement_id'
) }}

SELECT DISTINCT
    requirement_id,
    work_morning,
    work_evening,
    work_overnight,
    work_weekends,
    work_holidays,
    on_call,
    overtime,
    CASE
        WHEN physical_labor_level = "Low" THEN 1
        WHEN physical_labor_level = "Medium" THEN 2
        WHEN physical_labor_level = "High" THEN 3
        ELSE -1
    END AS physical_labor_level,
    drivers_license,
    security_clearance,
    CASE
        WHEN travel_requirement = "None" THEN 0
        WHEN travel_requirement = "Minimal" THEN 1
        WHEN travel_requirement = "Moderate" THEN 2
        WHEN travel_requirement = "Extensive" THEN 3
        ELSE -1
    END AS travel_requirements
FROM {{ ref('int_jobs') }}

{% if is_incremental() %}
WHERE requirement_id NOT IN (
    SELECT requirement_id
    FROM {{ this }}
)
{% endif %}