CREATE OR REPLACE TABLE customer_analytics.gold.customers
USING DELTA
AS

SELECT DISTINCT
    customer_id,
    customer_name,
    participant_id,
    state_normalized AS state,
    CAST(created_at AS DATE) AS registration_date,
    YEAR(created_at) AS registration_year

FROM customer_analytics.silver.customers

WHERE customer_id IS NOT NULL;