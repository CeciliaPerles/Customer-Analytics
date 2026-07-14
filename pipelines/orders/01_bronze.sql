CREATE OR REPLACE TABLE customer_analytics.bronze.orders
USING DELTA
AS
SELECT
    *,
    _metadata.file_path AS source_file,
    _metadata.file_name AS source_file_name,
    _metadata.file_modification_time AS source_file_modification_time,
    CURRENT_TIMESTAMP() AS ingestion_timestamp
FROM read_files(
    '/Volumes/customer_analytics/raw/source_files/orders/',
    format => 'csv',
    header => true,
    inferColumnTypes => false
);