import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

from ingestion.config import load_cities
from concurrent.futures import ThreadPoolExecutor

BASE_URL = "https://archive-api.open-meteo.com/v1/archive"

DAILY_FIELDS = [
    "weather_code",
    "temperature_2m_max",
    "temperature_2m_min",
    "apparent_temperature_max",
    "precipitation_sum",
    "rain_sum",
    "precipitation_hours",
    "sunshine_duration",
    "daylight_duration",
    "wind_speed_10m_max",
    "wind_gusts_10m_max",
]


def create_session() -> requests.Session:
    retry = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["GET"],
    )

    session = requests.Session()
    session.mount(
        "https://",
        HTTPAdapter(max_retries=retry),
    )

    return session


def extract_weather(city: dict, logical_date: str) -> dict:
    params = {
        "latitude": city["latitude"],
        "longitude": city["longitude"],
        "start_date": logical_date,
        "end_date": logical_date,
        "daily": ",".join(DAILY_FIELDS),
        "timezone": city["timezone"],
    }

    session = create_session()

    response = session.get(
        BASE_URL,
        params=params,
        timeout=(5, 30),
    )

    response.raise_for_status()

    return response.json()


def extract_all_cities(logical_date: str) -> list[dict]:
    cities = load_cities()

    def fetch_city(city: dict) -> dict:
        return {
            "city": city["name"],
            "response": extract_weather(city, logical_date),
        }

    with ThreadPoolExecutor(max_workers=5) as executor:
        results = list(executor.map(fetch_city, cities))

    return results