# ingestion/

Batch extraction and loading code. Suggested shape (not required):

- `weather_api.py` – Open-Meteo client with timeouts and retries.
- `load.py` – writes one logical date into `raw.weather_daily` idempotently.
