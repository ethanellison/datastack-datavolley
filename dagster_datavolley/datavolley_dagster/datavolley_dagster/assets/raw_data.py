import json
import os
import pandas as pd
from datavolley import read_dv
import requests
from dagster import (
    asset,
)


@asset
def oci_serve_speeds() -> pd.DataFrame:
    url = "https://g499c96d8bc280d-playground.adb.ca-montreal-1.oraclecloudapps.com/ords/admin/sdw/charts/serves_by_player/data/"
    response = requests.get(url)
    data = response.json().get("items", [])
    df = pd.json_normalize(data)
    return df


@asset
def raw_plays() -> pd.DataFrame:
    data = pd.read_csv("/app/out/plays.csv")
    return data


@asset
def raw_players() -> pd.DataFrame:
    df = pd.read_csv("/app/out/raw_players.csv")
    return df


@asset(compute_kind="python")
def raw_augmented_plays() -> pd.DataFrame:
    data = pd.read_csv("/app/out/augmented_plays.csv")
    return data


@asset(compute_kind="python")
def summary() -> pd.DataFrame:
    data = pd.read_csv("/app/out/summary.csv")
    return data


@asset(compute_kind="python")
def raw_output() -> pd.DataFrame:
    # Path to the JSON file
    file_path = "/app/out/output.json"

    # Load the JSON data from the file
    with open(file_path, "r", encoding="utf-8") as file:
        json_data = json.load(file)
        # print(json_data.keys())
        # raw_data = json_data["meta"]

    data = pd.json_normalize(json_data, max_level=0)
    data = data.drop(columns=["plays", "raw"])
    return data


@asset(compute_kind="python")
def pydatavolley_plays() -> pd.DataFrame:
    dvw_path_folder = "/app/dvw"

    combined_df = pd.DataFrame()
    # Get a list of all files with the specified extension in the directory
    for root, dirs, files in os.walk(dvw_path_folder):
        for file in files:
            file_path = os.path.join(root, file)
            print(file_path)
            combined_df = pd.concat(
                [combined_df, process_file(file_path)], ignore_index=True
            )

    return combined_df


def process_file(path):
    dv_instance = read_dv.DataVolley(path)
    df = dv_instance.get_plays()
    return df
