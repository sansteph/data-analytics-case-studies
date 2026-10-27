-- =============================================================================
-- Script: 02_data_cleaning.sql
-- Project: Cyclistic Bike-Share Case Study
-- Description: Cleans raw trip logs and performs feature engineering.
-- Data Quality Rules:
--   1. Filter false starts, maintenance checks, or clock glitches:
--      Keep trips where ended_at > started_at and duration >= 60 seconds.
--   2. Filter extreme anomalies / stolen equipment:
--      Exclude rides exceeding 24 hours (1,440 minutes).
-- Feature Engineering:
--   - ride_length_minutes (FLOAT64)
--   - day_of_week (INT64: 1 = Sunday, 7 = Saturday)
--   - day_name (STRING)
--   - trip_month (STRING: 'YYYY-MM')
-- =============================================================================

CREATE OR REPLACE TABLE `casestudies-512405.cyclist_db.trips_cleaned` AS
SELECT 
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    -- Duration in decimal minutes rounded to 2 decimal places
    ROUND(TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60.0, 2) AS ride_length_minutes,
    -- Numeric day of week (1 = Sunday, 7 = Saturday)
    EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week,
    -- Day of week name for reporting and visualization
    FORMAT_TIMESTAMP('%A', started_at) AS day_name,
    -- Month indicator for seasonality tracking
    FORMAT_TIMESTAMP('%Y-%m', started_at) AS trip_month,
    start_station_name,
    end_station_name,
    member_casual
FROM 
    `casestudies-512405.cyclist_db.trips_raw`
WHERE 
    -- Ensure chronological validity and minimum threshold
    ended_at > started_at
    AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
    -- Cap maximum duration at 24 hours
    AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;

-- Verification & Cleaning Metrics Log
SELECT 
    (SELECT COUNT(*) FROM `casestudies-512405.cyclist_db.trips_raw`) AS raw_row_count,
    COUNT(*) AS cleaned_row_count,
    (SELECT COUNT(*) FROM `casestudies-512405.cyclist_db.trips_raw`) - COUNT(*) AS records_dropped,
    ROUND(
        ((SELECT COUNT(*) FROM `casestudies-512405.cyclist_db.trips_raw`) - COUNT(*)) * 100.0 / 
        (SELECT COUNT(*) FROM `casestudies-512405.cyclist_db.trips_raw`), 
        2
    ) AS attrition_percentage
FROM 
    `casestudies-512405.cyclist_db.trips_cleaned`;