"""Create a small, isolated raw dataset for the CI dbt build."""

import os

import duckdb


with duckdb.connect(os.environ["DUCKDB_PATH"]) as connection:
    connection.execute("CREATE SCHEMA raw")
    connection.execute("""
        CREATE TABLE raw.customer AS
        SELECT 1 AS customer_id, 'Alex' AS first_name, 'Lee' AS last_name,
               DATE '1990-01-01' AS birth_date, 'Single' AS marital_status,
               'M' AS gender, 'alex@example.test' AS email_address,
               50000 AS annual_income, 'College' AS education_level,
               'Analyst' AS occupation, true AS home_owner
    """)
    connection.execute("""
        CREATE TABLE raw.product AS
        SELECT * FROM (VALUES
            ('P1', 'Product 1', 'Office', 'Supplies'),
            ('P2', 'Product 2', 'Office', 'Supplies')
        ) AS products(product_code, product, category, subcategory)
    """)
    connection.execute("""
        CREATE TABLE raw.region AS
        SELECT * FROM (VALUES
            ('R1', 'Bangkok', 'Bangkok', 'Thailand', 13.7563, 100.5018, 'Central', 'APAC'),
            ('R2', 'Chiang Mai', 'Chiang Mai', 'Thailand', 18.7883, 98.9853, 'North', 'APAC')
        ) AS regions(region_code, city, state, country, country_latitude,
                     country_longitude, region, market)
    """)
    connection.execute("""
        CREATE TABLE raw.ecom_sales AS
        SELECT * FROM (VALUES
            (1, 'O1', DATE '2023-06-01', 1, 'Consumer', 'R1', 'P1', 1, 100.0, 0.1, 20.0),
            (2, 'O1', DATE '2023-06-01', 1, 'Consumer', 'R1', 'P2', 2, 80.0, 0.0, 10.0),
            (3, 'O2', DATE '2023-07-01', 1, 'Consumer', 'R2', 'P1', 1, 50.0, 0.0, -5.0)
        ) AS sales(row_id, order_id, order_date, customer_id, segment,
                   region_code, product_code, quantity, sales, discount, profit)
    """)
