{{ config(materialized='incremental') }}

SELECT
    date_posted,
    job_title,
    job_level,
    job_type,
    COALESCE(job_yoe, -1) AS job_yoe,
    language,
    COALESCE(management_yoe, -1) AS management_yoe,
    job_activities,
    job_category,
    company,
    company_sector,
    security_clearance,

    CASE
        WHEN doctorate_degree = 'Required' THEN ARRAY(
            SELECT x.element
            FROM UNNEST(doctorate_field.list) AS x
        )
        WHEN masters_degree = 'Required' THEN ARRAY(
            SELECT x.element
            FROM UNNEST(masters_field.list) AS x
        )
        WHEN bachelors_degree = 'Required' THEN ARRAY(
            SELECT x.element
            FROM UNNEST(bachelors_field.list) AS x
        )
        WHEN associates_degree = 'Required' THEN ARRAY(
            SELECT x.element
            FROM UNNEST(associates_field.list) AS x
        )
        ELSE ['none specified']
    END AS degree_field_of_study,

    doctorate_degree,
    masters_degree,
    bachelors_degree,
    associates_degree,
    compensation_format as comp_format,

    COALESCE(
        hourly_comp_min,
        daily_comp_min,
        weekly_comp_min,
        biweekly_comp_min,
        monthly_comp_min,
        -1
    ) AS comp_min,

    COALESCE(
        hourly_comp_max,
        daily_comp_max,
        weekly_comp_max,
        biweekly_comp_max,
        monthly_comp_max,
        -1
    ) AS comp_max,

    ARRAY(
        SELECT certification.element
        FROM UNNEST(certifications.list) AS certification
    ) AS certifications,

    continent,
    country,
    state,
    city,
    drivers_license,
    has_401k,
    retirement,
    on_call,
    overtime,
    physical_labor_level,
    sponsorship,

    ARRAY(
        SELECT tool.element
        FROM UNNEST(technical_tools.list) AS tool
    ) AS technical_tools,

    travel_requirement,
    tuition_reimbursement,
    work_environment,
    work_evening,
    work_holidays,
    work_morning,
    work_overnight,
    work_weekends,
    workplace,
    relocation_assistance

FROM {{ source('bronze_data', 'job_data') }}

WHERE job_title IS NOT NULL

{% if is_incremental() %}
    AND date_posted >= (
        SELECT MAX(date_posted)
        FROM {{ this }}
    )
{% endif %}