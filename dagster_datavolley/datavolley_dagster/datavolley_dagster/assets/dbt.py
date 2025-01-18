from typing import Any, Mapping
from dagster import AssetExecutionContext, AssetKey
from dagster_dbt import (
    DagsterDbtTranslator,
    DbtCliResource,
    dbt_assets,
    get_asset_key_for_model,
)
from ..project import dbt_datavolley_project

# duckdb_database_path = "/tmp/datavolley.duckdb"
duckdb_database_path = dbt_datavolley_project.project_dir.joinpath("datavolley.duckdb")


class CustomDagsterDbtTranslator(DagsterDbtTranslator):
    def get_asset_key(self, dbt_resource_props: Mapping[str, Any]) -> AssetKey:
        asset_key = super().get_asset_key(dbt_resource_props)

        if dbt_resource_props["resource_type"] == "model":
            asset_key = asset_key.with_prefix(["duckdb", "dbt_schema"])
        if dbt_resource_props["resource_type"] == "source":
            asset_key = asset_key.with_prefix("duckdb")
            # asset_key = AssetKey(dbt_resource_props["name"])

        return asset_key


@dbt_assets(
    manifest=dbt_datavolley_project.manifest_path,
    dagster_dbt_translator=CustomDagsterDbtTranslator(),
)
def dbt_datavolley_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(
        ["build", "--full-refresh"], context=context
    ).stream().fetch_row_counts().fetch_column_metadata()


int_attacks_asset_key = get_asset_key_for_model(
    [dbt_datavolley_dbt_assets], "int_attacks"
)
int_serves_asset_key = get_asset_key_for_model(
    [dbt_datavolley_dbt_assets], "int_serves"
)
