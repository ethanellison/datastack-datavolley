import os
import pandas as pd
import json
import duckdb
import requests
from dagster import (
    AssetExecutionContext,
    asset,
    MetadataValue,
    MaterializeResult,
    AssetIn,
)
from dagster_duckdb import DuckDBResource
from dagster_dbt import get_asset_key_for_model

  
@asset
def oci_serve_speeds() -> pd.DataFrame:
    url = 'https://g499c96d8bc280d-playground.adb.ca-montreal-1.oraclecloudapps.com/ords/admin/sdw/charts/serves_by_player/data/'
    response = requests.get(url)
    data = response.json().get('items',[])
    df = pd.json_normalize(data)

    # with duckdb.get_connection() as conn:
    #     conn.execute(
    #         "create or replace table serve_speeds as select * from df"
    #     )
    #     conn.sql("describe serve_speeds").show()
    yield MaterializeResult(metadata={"preview": MetadataValue.md(df.head().to_markdown())})
    return df


@asset
def raw_plays() -> pd.DataFrame:
    data = pd.read_csv("/app/out/plays.csv")
    # with duckdb.get_connection() as connection:
        # connection.execute("create or replace table plays as select * from data")

    # Log some metadata about the table we just wrote. It will show up in the UI.
    yield MaterializeResult(
        metadata={
            "preview": MetadataValue.md(data.head().to_markdown()),
            "num_rows": data.shape[0],
        },
    )

    return data


@asset
def raw_players() -> pd.DataFrame:
    # data = json.loads("/app/out/players.json")
    df = pd.read_csv("/app/out/players.csv")
    # with duckdb.get_connection() as connection:
    #     connection.execute("create or replace table players as select * from df")

    # Log some metadata about the table we just wrote. It will show up in the UI.
    yield MaterializeResult(
        metadata={
            "preview": MetadataValue.md(df.head().to_markdown()),
            "rows": df.shape[0],
        }
    )
    return df


@asset(compute_kind="python")
def raw_augmented_plays() -> pd.DataFrame:
    data = pd.read_csv("/app/out/augmented_plays.csv")
    # with duckdb.get_connection() as connection:
    #     connection.execute(
    #         "create or replace table augmented_plays as select * from data"
    #     )

    # Log some metadata about the table we just wrote. It will show up in the UI.
    yield MaterializeResult(
        metadata={
            "preview": MetadataValue.md(data.head().to_markdown()),
            "num_rows": data.shape[0],
        }
    )
    return data


@asset(compute_kind="python")
def summary() -> pd.DataFrame:
    data = pd.read_csv("/app/out/summary.csv")
    # with duckdb.get_connection() as connection:
    #     connection.execute("create or replace table summary as select * from data")
    # # Log some metadata about the table we just wrote. It will show up in the UI.
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
    return data





