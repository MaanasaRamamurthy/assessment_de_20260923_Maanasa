CREATE TABLE IF NOT EXISTS raw.weather_daily (
    city TEXT NOT NULL,
    logical_date DATE NOT NULL,
    payload JSONB NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_weather_daily
        PRIMARY KEY (city, logical_date)
);