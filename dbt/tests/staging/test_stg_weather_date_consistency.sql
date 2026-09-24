select *

from {{ ref('stg_weather') }}

where weather_date <> logical_date