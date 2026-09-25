{{ config(
    materialized='incremental',
    unique_key='education_id'
) }}


SELECT DISTINCT
    education_id,
    CASE
        WHEN associates_degree = 'required' THEN 'Associate'
        WHEN bachelors_degree = 'required' THEN 'Bachelor'
        WHEN masters_degree = 'required' THEN 'Master'
        WHEN doctorate_degree = 'required' THEN 'Doctorate'
        ELSE 'None'
    END AS min_required_degree,

    CASE
        WHEN doctorate_degree = 'required' THEN 'Doctorate'
        WHEN masters_degree = 'required' THEN 'Master'
        WHEN bachelors_degree = 'required' THEN 'Bachelor'
        WHEN associates_degree = 'required' THEN 'Associate'
        ELSE 'None'
    END AS max_required_degree,

    CASE
        WHEN associates_degree = 'preferred' THEN 'Associate'
        WHEN bachelors_degree = 'preferred' THEN 'Bachelor'
        WHEN masters_degree = 'preferred' THEN 'Master'
        WHEN doctorate_degree = 'preferred' THEN 'Doctorate'
        ELSE 'None'
    END AS min_preferred_degree,

    CASE
        WHEN doctorate_degree = 'preferred' THEN 'Doctorate'
        WHEN masters_degree = 'preferred' THEN 'Master'
        WHEN bachelors_degree = 'preferred' THEN 'Bachelor'
        WHEN associates_degree = 'preferred' THEN 'Associate'
        ELSE 'None'
    END AS max_preferred_degree

FROM {{ ref('int_jobs') }}

{% if is_incremental() %}
WHERE education_id NOT IN (
    SELECT education_id
    FROM {{ this }}
)
{% endif %}