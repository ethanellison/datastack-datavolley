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
    int_attacks.to_csv("/app/out/attacks.csv")
    return int_attacks


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
