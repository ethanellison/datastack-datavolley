import os
import pandas as pd
import json
import duckdb
from dagster import (
    AssetExecutionContext,
    asset,
    MetadataValue,
    MaterializeResult,
    AssetIn,
)
from dagster_dbt import DbtCliResource, dbt_assets, get_asset_key_for_model
from dagster_duckdb import DuckDBResource

from .project import dbt_datavolley_project

# duckdb_database_path = "/tmp/datavolley.duckdb"
duckdb_database_path = dbt_datavolley_project.project_dir.joinpath("datavolley.duckdb")


# @asset
# def file_meta(duckdb: DuckDBResource):
#
#     with duckdb.get_connection() as conn:
#         df = conn.sql(
#             """
#             select
#                 meta->>'$.match_id[0]' as match_id,
#                 meta->>'$.match[0].date' as match_date,
#                 file_meta->>'$.preferred_date_format' as date_format,
#                 meta->'$.teams[0]' as home_team,
#                 meta->'$.teams[1]' as away_team
#             from '/app/out/output.json'
#         """
#         ).df()
#     yield MaterializeResult(metadata={"preview": MetadataValue.md(df.to_markdown())})


@asset
def raw_plays(duckdb: DuckDBResource):
    data = pd.read_csv("/app/out/plays.csv")
    with duckdb.get_connection() as connection:
        connection.execute("create or replace table plays as select * from data")

    # Log some metadata about the table we just wrote. It will show up in the UI.
    yield MaterializeResult(
        metadata={
            "preview": MetadataValue.md(data.head().to_markdown()),
            "num_rows": data.shape[0],
        },
    )


@asset
def raw_players(duckdb: DuckDBResource):
    # data = json.loads("/app/out/players.json")
    df = pd.read_csv("/app/out/players.csv")
    with duckdb.get_connection() as connection:
        connection.execute("create or replace table players as select * from df")

    # Log some metadata about the table we just wrote. It will show up in the UI.
    yield MaterializeResult(
        metadata={
            "preview": MetadataValue.md(df.head().to_markdown()),
            "rows": df.shape[0],
        }
    )


@asset(compute_kind="python")
def raw_augmented_plays(duckdb: DuckDBResource) -> None:
    data = pd.read_csv("/app/out/augmented_plays.csv")
    with duckdb.get_connection() as connection:
        connection.execute(
            "create or replace table augmented_plays as select * from data"
        )

    # Log some metadata about the table we just wrote. It will show up in the UI.
    yield MaterializeResult(
        metadata={
            "preview": MetadataValue.md(data.head().to_markdown()),
            "num_rows": data.shape[0],
        }
    )


@asset(compute_kind="python")
def summary(context: AssetExecutionContext) -> None:
    data = pd.read_csv("/app/out/summary.csv")
    connection = duckdb.connect(os.fspath(duckdb_database_path))
    connection.execute("create schema if not exists datavolley.raw")
    connection.execute("create or replace table raw.summary as select * from data")
    # Log some metadata about the table we just wrote. It will show up in the UI.
    context.add_output_metadata(
        {"num_rows": data.shape[0]},
        # {"num_columns": data.shape[1]}
    )
    yield MaterializeResult(
        metadata={
            "preview": MetadataValue.md(
                data.sort_values(
                    by=["win_rate", "set_win_rate", "points_ratio"],
                    ascending=[False, False, False],
                ).to_markdown()
            )
        },
    )


@dbt_assets(manifest=dbt_datavolley_project.manifest_path)
def dbt_datavolley_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream().fetch_row_counts()


@asset(
    compute_kind="pandas",
    deps=[get_asset_key_for_model([dbt_datavolley_dbt_assets], "int_players")],
)
def players(duckdb: DuckDBResource) -> pd.DataFrame:
    with duckdb.get_connection() as conn:
        data = conn.sql("SELECT * FROM int_players").df()
    yield MaterializeResult(
        metadata={
            "preview": MetadataValue.md(data.to_markdown()),
            "rows": data.shape[0],
        }
    )
    return data
