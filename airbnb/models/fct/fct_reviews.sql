{{
  config(
    materialized = 'incremental',
    on_schema_change='fail',
    incremental_strategy='microbatch',
    begin='2009-06-20',
    batch_size='year',
    event_time='review_date'
    )
}}
WITH rsc_reviews AS (
  SELECT * FROM {{ ref('rsc_reviews') }}
)
SELECT
  {{ dbt_utils.generate_surrogate_key(['listing_id', 'review_date', 'reviewer_name', 'review_text']) }}
    AS review_id,
  *
  FROM rsc_reviews
  WHERE review_text is not null
{% if is_incremental() %}
  {% if var("start_date", False) and var("end_date", False) %}
    {{ log('Loading ' ~ this ~ ' incrementally (start_date: ' ~ var("start_date") ~ ', end_date: ' ~ var("end_date") ~ ')', info=True) }}
    AND review_date >= '{{ var("start_date") }}'
    AND review_date < '{{ var("end_date") }}'
  {% else %}
    AND review_date > (select max(review_date) from {{ this }})
    {{ log('Loading ' ~ this ~ ' incrementally (all missing dates)', info=True)}}
  {% endif %}
{% endif %}