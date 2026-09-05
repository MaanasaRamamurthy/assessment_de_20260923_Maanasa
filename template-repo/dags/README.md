# dags/

Put your Airflow DAG(s) here. Airflow mounts this directory at `/opt/airflow/dags`.

`ingestion/`, `dbt/`, `config/` and `notebooks/` are mounted alongside under `/opt/airflow/`,
so a DAG can `import ingestion.weather_api` (add `/opt/airflow` to `sys.path`, or package it
however you prefer). The notebook imports the same modules the same way.
