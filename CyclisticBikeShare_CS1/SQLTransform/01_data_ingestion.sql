-- =============================================================================
-- Script: 01_data_ingestion.sql
-- Project: Cyclistic Bike-Share Case Study
-- Environment: Google Cloud Platform (Google Cloud Storage & BigQuery)
-- Description: Ingests 12 raw monthly trip CSV files from GCS into a unified
--              raw BigQuery staging table (trips_raw).
-- Total Expected Records: ~5.55M rows
-- =============================================================================

-- Ensure dataset exists
CREATE SCHEMA IF NOT EXISTS `casestudies-512405.cyclist_db`
OPTIONS (location = 'US');

-- Create or replace raw staging table with strict column typing matching Divvy schemas
CREATE OR REPLACE TABLE `casestudies-512405.cyclist_db.trips_raw` (
    ride_id STRING,
    rideable_type STRING,
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    start_station_name STRING,
    start_station_id STRING,
    end_station_name STRING,
    end_station_id STRING,
    start_lat FLOAT64,
    start_lng FLOAT64,
    end_lat FLOAT64,
    end_lng FLOAT64,
    member_casual STRING
);

-- Bulk load all 12 monthly CSV files staged in Google Cloud Storage
LOAD DATA OVERWRITE `casestudies-512405.cyclist_db.trips_raw`
FROM FILES (
    format = 'CSV',
    uris = ['gs://cyclistic-raw-data-cs1/*.csv'],
    skip_leading_rows = 1,
    ignore_unknown_values = true
);

-- Verification: Ensure all ~5.55M records were loaded
SELECT 
    COUNT(*) AS total_raw_records
FROM 
    `casestudies-512405.cyclist_db.trips_raw`;