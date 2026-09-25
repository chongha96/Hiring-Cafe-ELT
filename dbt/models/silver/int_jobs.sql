{{ config(materialized='view') }}

WITH jobs AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'date_posted',
            'job_title',
            'job_level',
            'job_type',
            'job_yoe',
            'company'
        ]) }} AS job_id,

        {{ dbt_utils.generate_surrogate_key([
            'has_401k',
            'tuition_reimbursement',
            'relocation_assistance',
            'sponsorship',
            'retirement'
        ]) }} AS benefit_id,

        {{ dbt_utils.generate_surrogate_key([
            'company',
            'company_sector',
            'job_category'
        ]) }} AS company_id,

        {{ dbt_utils.generate_surrogate_key([
            'associates_degree',
            'bachelors_degree',
            'masters_degree',
            'doctorate_degree'
        ]) }} AS education_id,

        {{ dbt_utils.generate_surrogate_key([
            'workplace',
            'work_environment'
        ]) }} AS condition_id,

        {{ dbt_utils.generate_surrogate_key([
            'work_morning',
            'work_evening',
            'work_overnight',
            'work_weekends',
            'work_holidays',
            'on_call',
            'overtime',
            'physical_labor_level',
            'drivers_license',
            'security_clearance',
            'travel_requirement'
        ]) }} AS requirement_id,

        date_posted,
        job_title,

        CASE
            WHEN job_level = 'No Prior Experience Required' THEN 1
            WHEN job_level = 'Entry Level' THEN 2
            WHEN job_level = 'Early Level' THEN 3
            WHEN job_level = 'Mid Level' THEN 4
            WHEN job_level = 'Senior Level' THEN 5
            ELSE -1
        END AS job_level,

        job_type,
        job_yoe,
        management_yoe,
        comp_format,
        comp_min,
        comp_max,

        language,
        job_activities,
        job_category,
        company,
        company_sector,
        security_clearance,
        degree_field_of_study,
        doctorate_degree,
        masters_degree,
        bachelors_degree,
        associates_degree,
        certifications,

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
        technical_tools,
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

    FROM {{ ref('silver_transformations') }}
)

SELECT *
FROM jobs

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY job_id
    ORDER BY date_posted DESC
) = 1