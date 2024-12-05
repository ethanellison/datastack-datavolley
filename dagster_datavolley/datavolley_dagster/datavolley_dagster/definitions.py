import os
from dagster import Definitions
from dagster_dbt import DbtCliResource
from dagster_duckdb import DuckDBResource

from .assets import (
    raw_players,
    dbt_datavolley_dbt_assets,
    players,
    raw_plays,
    raw_augmented_plays,
    summary,
    # attacks_preview,
    # file_meta,
)
from .project import dbt_datavolley_project
from .schedules import schedules

duckdb_database_path = dbt_datavolley_project.project_dir.joinpath("datavolley.duckdb")

# players = AssetSpec(key="int_players")

defs = Definitions(
    assets=[
        raw_players,
        players,
        summary,
        raw_augmented_plays,
        raw_plays,
        dbt_datavolley_dbt_assets,
        # attacks_preview,
        # file_meta,
    ],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=dbt_datavolley_project),
        "duckdb": DuckDBResource(database=os.fspath(duckdb_database_path)),
    },
)

