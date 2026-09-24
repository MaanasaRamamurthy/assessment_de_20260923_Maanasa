# Notes

## Time spent

Approximately **5 hours** in total.

- Environment and Docker setup: ~1 hour
- API extraction and PostgreSQL loading: ~1 hour
- dbt models and data-quality tests: ~1.5 hours
- Airflow orchestration and backfill testing: ~1 hour
- Notebook walkthrough and final validation: ~0.5 hour

## Repository setup note

The initially provided template repository was incomplete and was missing parts of the expected scaffold.

I raised this with the assessment team, and they subsequently corrected the template repository. I then cloned the corrected version and continued the implementation from that scaffold.

## What I would do with more time

- Add a lightweight completeness gate before transformation so a logical date proceeds only when all configured cities have been successfully ingested. This would prevent a technically successful but partially populated day from reaching the mart.

- Separate historical ingestion from transformation during larger backfills. Multiple dates could be extracted and loaded concurrently, followed by a single transformation step once the required raw range is available. This would improve backfill speed without creating concurrent dbt writes to the same relations.

- Add run-level observability such as expected vs. loaded city counts, API retry/failure counts, row counts at each layer, and pipeline duration. This would make operational issues easier to identify without inspecting task logs manually.

- Make the rolling-window mart explicitly aware of data completeness. For example, downstream consumers could distinguish between a complete 30-day profile and one calculated from missing observation dates rather than relying only on `days_observed`.

## Known gaps

- Airflow runs are intentionally serialized with `max_active_runs=1`. This keeps writes to the shared dbt relations deterministic, but limits the speed of large historical backfills.

- The extract payload is passed between Airflow tasks through XCom. This is appropriate for five small API responses, but for significantly larger payloads I would persist the extracted data externally and pass only a reference between tasks.

- Data-quality tests validate the loaded and transformed data, but there is currently no explicit pre-dbt completeness gate for expected cities. A partial API response could therefore be loaded successfully and only be identified through downstream validation or coverage checks.

- The mart uses the latest available date as the end of its rolling 30-calendar-day window. This makes the result deterministic for the data present in the warehouse, but consumers should be aware that missing dates reduce `days_observed` rather than extending the window backwards.

## AI-usage declaration

I used **ChatGPT only** as a development assistant for clarifying framework behaviour, reviewing implementation decisions, and troubleshooting Docker, dbt, Airflow, Git, and Jupyter issues. The pipeline design, implementation, integration, testing, and final validation were performed and verified by me.

## AI-usage declaration

| Where (file / area) | What the tool did | What I changed afterwards |
| --- | --- | --- |
| Docker / Jupyter permissions | Helped diagnose why `walkthrough.ipynb` was read-only inside the container by comparing the host file ownership with the Jupyter container user. | I updated the Jupyter service configuration, rebuilt the container, and verified that notebook outputs could be saved correctly. |
| dbt schema configuration | Helped identify why dbt was creating target-prefixed schemas instead of the required `staging` and `marts` schemas, and explained the role of `generate_schema_name`. | I added the project macro, reran dbt, and verified that the models were created in the intended schemas. |
| Repository structure / maintainability | Reviewed the repository layout and discussed where ingestion code, dbt models, tests, DAGs, SQL initialization files, and notebook logic should live for clarity. | I kept the supplied scaffold and organized new files within the existing structure so responsibilities remained separated and easy to follow. |
| Airflow / Docker debugging | Helped interpret runtime behaviour and suggested ways to inspect the containers when `make reproduce` appeared idle, such as checking Docker processes and Airflow activity. | I used those diagnostics to confirm the notebook was actively executing the Airflow backfill and dbt tasks rather than being stuck. |
| `notebooks/walkthrough.ipynb` | Reviewed what evidence would be useful after each pipeline stage, such as raw rows, staging output, backfill coverage, idempotency, and final mart results. | I selected the queries and outputs, ran the notebook end to end, and saved the final execution evidence. |
| Documentation | Helped draft and review explanatory text for the walkthrough and project notes. | I reviewed and edited the wording so it matched the final implementation, observed behaviour, and trade-offs in the submitted solution. |