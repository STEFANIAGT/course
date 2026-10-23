
{{
  config(
    materialized = 'table'
    )
}}
WITH rsc_hosts AS (
    SELECT
        *
    FROM
        {{ ref('rsc_hosts') }}
)
SELECT
    host_id,
    NVL(
        host_name,
        'N/A'
    ) AS host_name,
    is_superhost,
    created_at,
    updated_at
FROM
    rsc_hosts