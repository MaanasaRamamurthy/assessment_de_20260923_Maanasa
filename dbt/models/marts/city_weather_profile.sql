with bounds as (

    select
        max(weather_date) as window_end_date,
        max(weather_date) - 29 as cutoff_date

    from {{ ref('stg_weather') }}

),

windowed as (

    select
        s.*

    from {{ ref('stg_weather') }} s
    cross join bounds b

    where s.weather_date
        between b.cutoff_date and b.window_end_date

),

enriched as (

    select
        *,

        weather_date
        - min(weather_date) over (
            partition by city
        ) as day_index,

        abs(
            temperature_2m_max
            - lag(temperature_2m_max) over (
                partition by city
                order by weather_date
            )
        ) as day_to_day_temp_change_c

    from windowed

),

rainy_days as (

    select
        city,
        weather_date,

        weather_date
        - row_number() over (
            partition by city
            order by weather_date
        )::integer as streak_group

    from windowed

    where rain_sum > 0

),

rain_streaks as (

    select
        city,
        streak_group,
        count(*) as streak_days

    from rainy_days

    group by
        city,
        streak_group

),

rain_streak_summary as (

    select
        city,
        max(streak_days) as longest_rain_streak_days

    from rain_streaks

    group by city

),

profile as (

    select
        city,

        min(weather_date) as window_start_date,
        max(weather_date) as window_end_date,

        count(distinct weather_date) as days_observed,

        round(
            regr_slope(
                temperature_2m_max::double precision,
                day_index::double precision
            )::numeric,
            3
        ) as temperature_trend_c_per_day,

        round(
            avg(day_to_day_temp_change_c),
            2
        ) as avg_day_to_day_temp_change_c,

        round(
            sum(precipitation_sum),
            2
        ) as total_precipitation_mm,

        round(
            (
                sum(sunshine_duration_hours)
                /
                nullif(sum(daylight_duration_hours), 0)
            ) * 100,
            2
        ) as sunshine_percentage

    from enriched

    group by city

)

select
    p.city,
    p.window_start_date,
    p.window_end_date,
    p.days_observed,
    p.temperature_trend_c_per_day,
    p.avg_day_to_day_temp_change_c,
    p.total_precipitation_mm,
    coalesce(
        r.longest_rain_streak_days,
        0
    ) as longest_rain_streak_days,
    p.sunshine_percentage

from profile p

left join rain_streak_summary r
    on p.city = r.city