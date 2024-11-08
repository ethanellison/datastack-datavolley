import os
import pandas as pd
import json
import duckdb 
from dagster import AssetExecutionContext, asset, MetadataValue, MaterializeResult
from dagster_dbt import DbtCliResource, dbt_assets, get_asset_key_for_model
from dagster_duckdb import DuckDBResource

from .project import dbt_datavolley_project

# duckdb_database_path = "/tmp/datavolley.duckdb"
duckdb_database_path = dbt_datavolley_project.project_dir.joinpath("datavolley.duckdb")


@asset(compute_kind="python")
def raw_plays(context: AssetExecutionContext) -> None:
    data = pd.read_csv("/app/out/plays.csv")
    connection = duckdb.connect(os.fspath(duckdb_database_path))
    connection.execute("create schema if not exists datavolley.raw")
    connection.execute(
        "create or replace table raw.plays as select * from data"
    )

    # Log some metadata about the table we just wrote. It will show up in the UI.
    context.add_output_metadata(
        {"num_rows": data.shape[0]},
        # {"num_columns": data.shape[1]}
    )

@asset(compute_kind="python")
def raw_players(context: AssetExecutionContext) -> None:
    # data = json.loads("/app/out/players.json")
    df = pd.read_csv("/app/out/players.csv")
    connection = duckdb.connect(os.fspath(duckdb_database_path))
    connection.execute("create schema if not exists datavolley.raw")
    connection.execute(
        "create or replace table raw.players as select * from df"
    )

    # Log some metadata about the table we just wrote. It will show up in the UI.
    context.add_output_metadata(
        {"num_rows": df.shape[0]},
        # {"num_columns": data.shape[1]}
    )

    yield MaterializeResult(
        metadata={"preview": MetadataValue.md(df.head().to_markdown())}
    )

@asset(compute_kind="python")
def raw_augmented_plays(context: AssetExecutionContext) -> None:
    data = pd.read_csv("/app/out/augmented_plays.csv")
    connection = duckdb.connect(os.fspath(duckdb_database_path))
    connection.execute("create schema if not exists datavolley.raw")
    connection.execute(
        "create or replace table raw.augmented_plays as select * from data"
    )

    # Log some metadata about the table we just wrote. It will show up in the UI.
    context.add_output_metadata(
        {"num_rows": data.shape[0]},
        # {"num_columns": data.shape[1]}
    )
    yield MaterializeResult(
        metadata={"tables": MetadataValue.md(connection.execute('SHOW ALL TABLES;').df().to_markdown())}
    )

@asset(compute_kind="python")
def summary(context: AssetExecutionContext) -> None:
    data = pd.read_csv("/app/out/summary.csv")
    connection = duckdb.connect(os.fspath(duckdb_database_path))
    connection.execute("create schema if not exists datavolley.raw")
    connection.execute(
        "create or replace table raw.summary as select * from data"
    )

    # Log some metadata about the table we just wrote. It will show up in the UI.
    context.add_output_metadata(
        {"num_rows": data.shape[0]},
        # {"num_columns": data.shape[1]}
    )
    yield MaterializeResult(
        metadata={"preview": MetadataValue.md(data.to_markdown())},
    )

@dbt_assets(manifest=dbt_datavolley_project.manifest_path)
def dbt_datavolley_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()


@asset(
    compute_kind="python",
    deps=[get_asset_key_for_model([dbt_datavolley_dbt_assets], "raw_attacks")],
)
def attacks_preview(context: AssetExecutionContext) -> None:
    # read the contents of the customers table into a Pandas DataFrame
    connection = duckdb.connect(os.fspath(duckdb_database_path))
    attacks = connection.sql("select * from datavolley.datavolley.raw_attacks").df()

    # # create a plot of number of orders by customer and write it out to an HTML file
    # fig = px.histogram(customers, x="number_of_orders")
    # fig.update_layout(bargap=0.2)
    # save_chart_path = duckdb_database_path.parent.joinpath("order_count_chart.html")
    # fig.write_html(save_chart_path, auto_open=True)

    # # tell Dagster about the location of the HTML file,
    # # so it's easy to access from the Dagster UI
    context.add_output_metadata(
        { "preview": MetadataValue.md(attacks.head().to_markdown())}
        # {"plot_url": MetadataValue.url("file://" + os.fspath(save_chart_path))}
    )