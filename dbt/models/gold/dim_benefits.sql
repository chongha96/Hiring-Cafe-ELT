{{ config(
    materialized='incremental',
    unique_key='benefit_id'
) }}

SELECT DISTINCT
    benefit_id,
    has_401k,
    tuition_reimbursement as has_tuition_reimbursement,
    relocation_assistance as has_relocation,
    sponsorship as has_visa_sponsorship,
    retirement as has_retirement

FROM {{ ref('int_jobs') }}

{% if is_incremental() %}
WHERE benefit_id NOT IN (
    SELECT benefit_id
    FROM {{ this }}
)
{% endif %}