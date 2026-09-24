select
    city,
    weather_date,
    count(*) as row_count

from {{ ref('stg_weather') }}

group by
    city,
    weather_date

having count(*) > 1