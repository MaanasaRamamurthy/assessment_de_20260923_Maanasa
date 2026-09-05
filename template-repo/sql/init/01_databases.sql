-- Runs once when the Postgres volume is created.
-- Airflow metadata lives in its own database; the warehouse keeps your data.
CREATE DATABASE airflow;

\connect warehouse

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;
