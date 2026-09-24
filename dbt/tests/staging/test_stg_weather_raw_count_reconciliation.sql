with raw_counts as (

    select
        logical_date,
        count(*) as raw_count

    from {{ source('raw', 'weather_daily') }}

    group by logical_date

),

staging_counts as (

    select
        logical_date,
        count(*) as staging_count

    from {{ ref('stg_weather') }}

    group by logical_date

)

select
    coalesce(r.logical_date, s.logical_date) as logical_date,
    r.raw_count,
    s.staging_count

from raw_counts r

full outer join staging_counts s
    on r.logical_date = s.logical_date

where
    r.raw_count is distinct from s.staging_count