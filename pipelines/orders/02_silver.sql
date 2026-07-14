CREATE OR REPLACE TABLE customer_analytics.silver.orders
USING DELTA
AS

SELECT
    TRY_CAST(id AS BIGINT) AS order_id,
    TRY_CAST(id_customers AS BIGINT) AS customer_id,
    TRY_CAST(own_id AS BIGINT) AS own_id,
    TRY_CAST(value AS DECIMAL(18, 2)) AS order_value,
    TRY_CAST(cashback_percentage AS DECIMAL(5, 2)) AS cashback_percentage,
    TRY_CAST(value_cashback AS DECIMAL(18, 2)) AS cashback_value,
    ROUND(
        TRY_CAST(value AS DECIMAL(18, 2))
        * TRY_CAST(cashback_percentage AS DECIMAL(5, 2))
        / 100,
        2
    ) AS expected_cashback,
    TRY_CAST(created_at AS TIMESTAMP) AS created_at,
    TRY_CAST(store_id AS BIGINT) AS store_id,
    TRIM(description) AS description,
    source_file,
    source_file_name,
    source_file_modification_time,
    ingestion_timestamp

FROM customer_analytics.bronze.orders;