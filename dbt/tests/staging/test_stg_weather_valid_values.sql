select *

from {{ ref('stg_weather') }}

where
    latitude < -90
    or latitude > 90
    or longitude < -180
    or longitude > 180
    or temperature_2m_max < temperature_2m_min
    or precipitation_sum < 0
    or rain_sum < 0
    or precipitation_hours < 0
    or precipitation_hours > 24
    or sunshine_duration_hours < 0
    or daylight_duration_hours < 0
    or sunshine_duration_hours > daylight_duration_hours
    or wind_speed_10m_max < 0
    or wind_gusts_10m_max < 0