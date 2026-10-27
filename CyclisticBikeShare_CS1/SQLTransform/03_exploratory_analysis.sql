-- =============================================================================
-- Script 03_exploratory_analysis.sql
-- Project Cyclistic Bike-Share Case Study
-- Description Aggregates clean records across cadence, time, fleet, and location
--              to generate the 4 summary tables exported for Tableau Public.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Query 0 Baseline Descriptive Statistics
-- -----------------------------------------------------------------------------
SELECT 
    member_casual,
    COUNT(ride_id) AS total_trips,
    ROUND(COUNT(ride_id)  100.0  SUM(COUNT(ride_id)) OVER(), 2) AS percentage_of_total_rides,
    ROUND(AVG(ride_length_minutes), 2) AS avg_duration_mins,
    ROUND(APPROX_QUANTILES(ride_length_minutes, 100)[OFFSET(50)], 2) AS median_duration_mins,
    MIN(ride_length_minutes) AS min_duration_mins,
    MAX(ride_length_minutes) AS max_duration_mins
FROM 
    `casestudies-512405.cyclist_db.trips_cleaned`
GROUP BY 
    member_casual;

-- -----------------------------------------------------------------------------
-- Summary 1 Day of Week Behavior (Volume & Duration)
-- Target CSV SummarizedDatacyclistic_weekly_patterns.csv
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `casestudies-512405.cyclist_db.summary_day_of_week` AS
SELECT 
    member_casual,
    day_of_week,
    day_name,
    COUNT(ride_id) AS total_trips,
    ROUND(AVG(ride_length_minutes), 2) AS avg_duration_mins
FROM 
    `casestudies-512405.cyclist_db.trips_cleaned`
GROUP BY 
    member_casual, 
    day_of_week, 
    day_name
ORDER BY 
    day_of_week, 
    member_casual;

-- -----------------------------------------------------------------------------
-- Summary 2 Hourly Demand Patterns (Commuter vs. Leisure Curves)
-- Target CSV SummarizedDatacyclistic_hourly_traffic.csv
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `casestudies-512405.cyclist_db.summary_hourly_traffic` AS
SELECT 
    member_casual,
    EXTRACT(HOUR FROM started_at) AS hour_of_day,
    COUNT(ride_id) AS trip_volume
FROM 
    `casestudies-512405.cyclist_db.trips_cleaned`
GROUP BY 
    member_casual, 
    hour_of_day
ORDER BY 
    hour_of_day, 
    member_casual;

-- -----------------------------------------------------------------------------
-- Summary 3 Fleet Breakdown & Preference
-- Target CSV SummarizedDatacyclistic_bike_types.csv
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `casestudies-512405.cyclist_db.summary_bike_types` AS
SELECT 
    member_casual,
    rideable_type,
    COUNT(ride_id) AS total_trips,
    ROUND(COUNT(ride_id)  100.0  SUM(COUNT(ride_id)) OVER(PARTITION BY member_casual), 2) AS type_percentage,
    ROUND(AVG(ride_length_minutes), 2) AS avg_duration_mins
FROM 
    `casestudies-512405.cyclist_db.trips_cleaned`
GROUP BY 
    member_casual, 
    rideable_type
ORDER BY 
    member_casual, 
    total_trips DESC;

-- -----------------------------------------------------------------------------
-- Summary 4 Top 10 Pickup Stations for Casual Riders
-- Target CSV SummarizedDatacyclistic_top_stations.csv
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE `casestudies-512405.cyclist_db.summary_top_stations` AS
SELECT 
    start_station_name,
    COUNT(ride_id) AS casual_rides
FROM 
    `casestudies-512405.cyclist_db.trips_cleaned`
WHERE 
    member_casual = 'casual' 
    AND start_station_name IS NOT NULL
GROUP BY 
    start_station_name
ORDER BY 
    casual_rides DESC
LIMIT 10;