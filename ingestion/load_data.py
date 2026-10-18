import os
from dotenv import load_dotenv
load_dotenv()

import dlt
from dlt.sources.sql_database import sql_database

DUCKDB_PATH = os.getenv("DUCKDB_PATH")

if not DUCKDB_PATH:
    raise ValueError("Please configure DUCKDB_PATH in .env")

def source():
    return sql_database(
        schema='e_commerce',
        table_names=['customer', 'ecom_sales', 'product', 'region'],
        reflection_level='full',
        defer_table_reflect=True
    ).parallelize()

def pipeline():
    database_directory = os.path.dirname(os.path.abspath(DUCKDB_PATH))
    os.makedirs(database_directory, exist_ok=True)

    return dlt.pipeline(
        pipeline_name='e_commerce_data_pipeline',
        destination=dlt.destinations.duckdb(DUCKDB_PATH),
        dataset_name='raw'
    )

def load_data():
    data_source = source()

    data_pipeline = pipeline()

    load_info = data_pipeline.run(
        data_source, 
        write_disposition='replace'
    )

    print(load_info)

if __name__ == "__main__":
    load_data()

    