select
    city,

    (payload -> 'daily' -> 'time' ->> 0)::date
        as weather_date,

    (payload ->> 'latitude')::numeric
        as latitude,

    (payload ->> 'longitude')::numeric
        as longitude,

    payload ->> 'timezone'
        as timezone,

    (payload -> 'daily' -> 'weather_code' ->> 0)::integer
        as weather_code,

    (payload -> 'daily' -> 'temperature_2m_max' ->> 0)::numeric
        as temperature_2m_max,

    (payload -> 'daily' -> 'temperature_2m_min' ->> 0)::numeric
        as temperature_2m_min,

    (payload -> 'daily' -> 'apparent_temperature_max' ->> 0)::numeric
        as apparent_temperature_max,

    (payload -> 'daily' -> 'precipitation_sum' ->> 0)::numeric
        as precipitation_sum,

    (payload -> 'daily' -> 'rain_sum' ->> 0)::numeric
        as rain_sum,

    (payload -> 'daily' -> 'precipitation_hours' ->> 0)::numeric
        as precipitation_hours,

    round(
        (payload -> 'daily' -> 'sunshine_duration' ->> 0)::numeric / 3600.0,
        2
    ) as sunshine_duration_hours,

    round(
        (payload -> 'daily' -> 'daylight_duration' ->> 0)::numeric / 3600.0,
        2
    ) as daylight_duration_hours,

    (payload -> 'daily' -> 'wind_speed_10m_max' ->> 0)::numeric
        as wind_speed_10m_max,

    (payload -> 'daily' -> 'wind_gusts_10m_max' ->> 0)::numeric
        as wind_gusts_10m_max,

    logical_date,
    loaded_at

from {{ source('raw', 'weather_daily') }}