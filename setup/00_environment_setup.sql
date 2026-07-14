--------------------------- 1. Catálogo ---------------------------

CREATE CATALOG IF NOT EXISTS customer_analytics;

--------------------------- 2. Camadas ---------------------------

CREATE SCHEMA IF NOT EXISTS customer_analytics.raw;

CREATE SCHEMA IF NOT EXISTS customer_analytics.bronze
MANAGED LOCATION
's3://customer-analytics-lakehouse-577638374158-us-east-1-an/managed/bronze/';

CREATE SCHEMA IF NOT EXISTS customer_analytics.silver
MANAGED LOCATION
's3://customer-analytics-lakehouse-577638374158-us-east-1-an/managed/silver/';

CREATE SCHEMA IF NOT EXISTS customer_analytics.gold
MANAGED LOCATION
's3://customer-analytics-lakehouse-577638374158-us-east-1-an/managed/gold/';

--------------------------- 3. Volume ---------------------------

CREATE EXTERNAL VOLUME IF NOT EXISTS
customer_analytics.raw.source_files
LOCATION
's3://customer-analytics-lakehouse-577638374158-us-east-1-an/raw/';