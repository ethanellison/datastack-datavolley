from typing import Any
from dagster_dbt import get_asset_key_for_model
import pandas as pd
from dagster import AssetIn, asset

from datavolley_dagster.assets import dbt


@asset(
    ins={
        "int_attacks": AssetIn(
            key=get_asset_key_for_model([dbt.dbt_datavolley_dbt_assets], "int_attacks"),
            input_manager_key="io_manager",
        )
    },
    compute_kind="pandas",
)
def attacks(int_attacks: pd.DataFrame) -> Any:
    df = int_attacks
    df.to_csv("/app/out/attacks.csv")
    return df


@asset(
    ins={
        "int_serves": AssetIn(
            key=get_asset_key_for_model([dbt.dbt_datavolley_dbt_assets], "int_serves"),
            input_manager_key="io_manager",
        )
    },
    compute_kind="pandas",
)
def serves(int_serves: pd.DataFrame) -> Any:
    int_serves.to_csv("/app/out/serves.csv")
    return int_serves.sort_values(by="N", ascending=False)


@asset(
    ins={
        "dim_players": AssetIn(
            key=get_asset_key_for_model([dbt.dbt_datavolley_dbt_assets], "dim_players"),
            input_manager_key="io_manager",
        )
    },
    compute_kind="pandas",
)
def players(dim_players: pd.DataFrame) -> Any:
    dim_players.to_csv("/app/out/players.csv")
    return dim_players


@asset(
    ins={
        "dim_teams": AssetIn(
            key=get_asset_key_for_model([dbt.dbt_datavolley_dbt_assets], "dim_teams"),
            input_manager_key="io_manager",
        )
    },
    compute_kind="pandas",
)
def teams(dim_teams: pd.DataFrame) -> Any:
    dim_teams.to_csv("/app/out/teams.csv")
    return dim_teams
