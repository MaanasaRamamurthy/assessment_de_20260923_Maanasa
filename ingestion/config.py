from pathlib import Path

import yaml


CONFIG_PATH = Path("/opt/airflow/config/cities.yml")


def load_cities() -> list[dict]:
    with CONFIG_PATH.open("r", encoding="utf-8") as file:
        config = yaml.safe_load(file)

    return config["cities"]