from dagster import AssetSpec, Definitions
from dagster_dbt import DbtCliResource
from dagster_duckdb import DuckDBResource

from .assets import raw_players, dbt_datavolley_dbt_assets, raw_plays, raw_augmented_plays, summary, attacks_preview
from .project import dbt_datavolley_project
from .schedules import schedules

defs = Definitions(
    assets=[raw_players, summary,raw_augmented_plays,raw_plays,dbt_datavolley_dbt_assets, attacks_preview],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=dbt_datavolley_project),
    },
)