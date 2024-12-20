from setuptools import find_packages, setup

setup(
    name="datavolley_dagster",
    version="0.0.1",
    packages=find_packages(),
    package_data={
        "datavolley_dagster": [
            "dbt-datavolley/**/*",
        ],
    },
    install_requires=[
        "duckdb",
        "dagster",
        "dagster-cloud",
        "dagster-dbt",
        "dbt-duckdb<1.9",
        "dagster-duckdb",
        "dagster-duckdb-pandas",
        "pydatavolley",
    ],
    extras_require={
        "dev": [
            "dagster-webserver",
        ]
    },
)
