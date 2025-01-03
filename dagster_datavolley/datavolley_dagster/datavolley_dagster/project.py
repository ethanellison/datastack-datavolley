from pathlib import Path

from dagster_dbt import DbtProject

dbt_datavolley_project = DbtProject(
    project_dir=Path(__file__).joinpath("..", "..", "dbt_datavolley").resolve(),
    packaged_project_dir=Path(__file__)
    .joinpath("..", "..", "dbt-datavolley")
    .resolve(),
)
dbt_datavolley_project.prepare_if_dev()

