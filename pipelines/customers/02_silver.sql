CREATE OR REPLACE TABLE customer_analytics.silver.customers
USING DELTA
AS

WITH normalized AS (
    SELECT
        TRY_CAST(customer_id AS BIGINT) AS customer_id,
        TRIM(name) AS customer_name,

        REGEXP_REPLACE(
            document,
            '[^0-9]',
            ''
        ) AS document,

        TRY_CAST(participant_id AS BIGINT) AS participant_id,

        state AS state_original,

        REGEXP_REPLACE(
            TRANSLATE(
                UPPER(TRIM(state)),
                'ÁÀÂÃÉÊÍÓÔÕÚÜÇ',
                'AAAAEEIOOOUUC'
            ),
            '[^A-Z]',
            ''
        ) AS state_clean,

        TRY_CAST(created_at AS TIMESTAMP) AS created_at,

        source_file,
        source_file_name,
        source_file_modification_time,
        ingestion_timestamp

    FROM customer_analytics.bronze.customers
)

SELECT
    customer_id,
    customer_name,
    document,
    participant_id,
    state_original,
    CASE
        WHEN state_clean IN ('SP', 'SAOPAULO', 'SPAULO')
            THEN 'São Paulo'
        WHEN state_clean IN ('RJ', 'RIODEJANEIRO')
            THEN 'Rio de Janeiro'
        WHEN state_clean IN ('MG', 'MINASGERAIS')
            THEN 'Minas Gerais'
        WHEN state_clean IN ('RS', 'RIOGRANDEDOSUL')
            THEN 'Rio Grande do Sul'
        WHEN state_clean IN ('PR', 'PARANA')
            THEN 'Paraná'
        WHEN state_clean IN ('SC', 'SANTACATARINA')
            THEN 'Santa Catarina'
        WHEN state_clean IN ('BA', 'BAHIA')
            THEN 'Bahia'
        WHEN state_clean IN ('PE', 'PERNAMBUCO')
            THEN 'Pernambuco'
        WHEN state_clean IN ('CE', 'CEARA')
            THEN 'Ceará'
        WHEN state_clean IN ('GO', 'GOIAS')
            THEN 'Goiás'
    END AS state_normalized,
    created_at,
    CASE
        WHEN customer_id IS NULL THEN FALSE
        ELSE TRUE
    END AS is_valid_customer,
    CASE
        WHEN customer_id IS NULL THEN 'customer_id não informado'
        ELSE NULL
    END AS quality_issue,
    source_file,
    source_file_name,
    source_file_modification_time,
    ingestion_timestamp

FROM normalized;