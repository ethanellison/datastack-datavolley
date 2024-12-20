import os
from dagster import Definitions, load_assets_from_modules
from dagster_dbt import DbtCliResource
from dagster_duckdb_pandas import DuckDBPandasIOManager

from .assets import raw_data, analysis
from .assets.dbt import dbt_datavolley_dbt_assets

from .project import dbt_datavolley_project
from .schedules import schedules

# duckdb_database_path = dbt_datavolley_project.project_dir.joinpath("datavolley.duckdb")
duckdb_database_path = os.getenv("DUCKDB_DATABASE")
# players = AssetSpec(key=duckdb_database)
raw_data_assets = load_assets_from_modules(
    [raw_data],
    group_name="raw_data",
    key_prefix=["duckdb", "raw"],
)

analysis_assets = load_assets_from_modules(
    [analysis],
    group_name="analysis",
)


defs = Definitions(
    assets=[
        *raw_data_assets,
        *analysis_assets,
        dbt_datavolley_dbt_assets,
    ],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=dbt_datavolley_project),
        "io_manager": DuckDBPandasIOManager(database=duckdb_database_path),
    },
)
