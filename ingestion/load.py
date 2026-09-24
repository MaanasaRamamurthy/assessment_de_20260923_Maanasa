import os

import psycopg2
from psycopg2.extras import Json


def get_connection():
    return psycopg2.connect(
        host=os.environ["WAREHOUSE_HOST"],
        port=os.environ["WAREHOUSE_PORT"],
        dbname=os.environ["WAREHOUSE_DB"],
        user=os.environ["WAREHOUSE_USER"],
        password=os.environ["WAREHOUSE_PASSWORD"],
    )


def load_weather(results: list[dict], logical_date: str) -> int:
    upsert_sql = """
        INSERT INTO raw.weather_daily (
            city,
            logical_date,
            payload
        )
        VALUES (%s, %s, %s)
        ON CONFLICT (city, logical_date)
        DO UPDATE SET
            payload = EXCLUDED.payload,
            loaded_at = CURRENT_TIMESTAMP;
    """

    rows = [
        (
            result["city"],
            logical_date,
            Json(result["response"]),
        )
        for result in results
    ]

    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.executemany(upsert_sql, rows)

    return len(rows)