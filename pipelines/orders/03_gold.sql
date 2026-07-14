CREATE OR REPLACE TABLE customer_analytics.gold.orders
USING DELTA
AS

SELECT
    order_id,
    customer_id,
    own_id,
    order_value,
    cashback_percentage,
    cashback_value,
    created_at AS transaction_timestamp,
    CAST(created_at AS DATE) AS transaction_date,
    DATE_TRUNC('MONTH', created_at) AS transaction_month,
    store_id,
    TRIM(description) AS transaction_category

FROM customer_analytics.silver.orders