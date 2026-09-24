select *

from {{ ref('city_weather_profile') }}

where
    days_observed < 1
    or days_observed > 30
    or window_start_date > window_end_date
    or window_end_date - window_start_date > 29
    or (
        days_observed >= 2
        and temperature_trend_c_per_day is null
    )
    or (
        days_observed >= 2
        and avg_day_to_day_temp_change_c is null
    )
    or avg_day_to_day_temp_change_c < 0
    or total_precipitation_mm < 0
    or longest_rain_streak_days < 0
    or longest_rain_streak_days > days_observed
    or sunshine_percentage < 0
    or sunshine_percentage > 100