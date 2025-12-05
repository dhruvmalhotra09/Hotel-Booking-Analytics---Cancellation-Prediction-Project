CREATE DATABASE IF NOT EXISTS hotel_analysis;
USE hotel_analysis;

CREATE TABLE IF NOT EXISTS hotel_bookings (
    hotel VARCHAR(50),
    is_canceled INT,
    lead_time INT,
    arrival_date_year INT,
    arrival_date_month VARCHAR(15),
    arrival_date_week_number INT,
    arrival_date_day_of_month INT,
    stays_in_weekend_nights INT,
    stays_in_week_nights INT,
    adults INT,
    children FLOAT,
    babies INT,
    meal VARCHAR(10),
    country VARCHAR(10),
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(50),
    is_repeated_guest INT,
    previous_cancellations INT,
    previous_bookings_not_canceled INT,
    reserved_room_type VARCHAR(10),
    assigned_room_type VARCHAR(10),
    booking_changes INT,
    deposit_type VARCHAR(50),
    agent VARCHAR(50),
    company VARCHAR(50),
    days_in_waiting_list INT,
    customer_type VARCHAR(50),
    adr FLOAT,
    required_car_parking_spaces INT,
    total_of_special_requests INT,
    reservation_status VARCHAR(50),
    reservation_status_date VARCHAR(20)   -- import as VARCHAR, convert later if needed
);

SELECT COUNT(*) AS total_rows FROM hotel_bookings;

SELECT * FROM hotel_bookings LIMIT 5;

CREATE TABLE IF NOT EXISTS market_segment_lookup (
    market_segment VARCHAR(50),
    segment_desc VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS distribution_channel_lookup (
    distribution_channel VARCHAR(50),
    channel_desc VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS country_continent_lookup (
    country VARCHAR(10),
    continent VARCHAR(50)
);

SELECT COUNT(*) AS total_market_segments FROM market_segment_lookup;
SELECT COUNT(*) AS total_channels FROM distribution_channel_lookup;
SELECT COUNT(*) AS total_countries FROM country_continent_lookup;

SELECT*FROM market_segment_lookup;
SELECT*FROM distribution_channel_lookup;
SELECT*FROM country_continent_lookup;

CREATE TABLE IF NOT EXISTS hotel_bookings_backup AS
SELECT * FROM hotel_bookings;

-- 1) Check NULLs for all guest columns
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN adults IS NULL THEN 1 ELSE 0 END) AS null_adults,
  SUM(CASE WHEN children IS NULL THEN 1 ELSE 0 END) AS null_children,
  SUM(CASE WHEN babies IS NULL THEN 1 ELSE 0 END) AS null_babies
FROM hotel_bookings;
-- 2)
SELECT
  SUM(CASE WHEN agent IS NOT NULL AND TRIM(agent) <> '' AND (company IS NULL OR TRIM(company)='') THEN 1 ELSE 0 END) AS via_agent,
  SUM(CASE WHEN company IS NOT NULL AND TRIM(company) <> '' AND (agent IS NULL OR TRIM(agent)='') THEN 1 ELSE 0 END) AS via_company,
  SUM(CASE WHEN (agent IS NULL OR TRIM(agent)='') AND (company IS NULL OR TRIM(company)='') THEN 1 ELSE 0 END) AS direct_bookings,
  SUM(CASE WHEN agent IS NOT NULL AND TRIM(agent) <> '' AND company IS NOT NULL AND TRIM(company) <> '' THEN 1 ELSE 0 END) AS both_present
FROM hotel_bookings;

ALTER TABLE hotel_bookings
  ADD COLUMN booking_source VARCHAR(10),
  ADD COLUMN source_id VARCHAR(100),
  ADD COLUMN agent_flag TINYINT DEFAULT 0,
  ADD COLUMN company_flag TINYINT DEFAULT 0;

-- turn off safe-update protection for this session
SET SQL_SAFE_UPDATES = 0;

-- re-run your UPDATE (the one that failed)
UPDATE hotel_bookings
SET
  booking_source = CASE
    WHEN agent IS NOT NULL AND TRIM(agent) <> '' THEN 'Agent'
    WHEN (agent IS NULL OR TRIM(agent) = '') 
         AND company IS NOT NULL AND TRIM(company) <> '' THEN 'Company'
    ELSE 'Direct'
  END,
  source_id = CASE
    WHEN agent IS NOT NULL AND TRIM(agent) <> '' THEN agent
    WHEN (agent IS NULL OR TRIM(agent) = '') 
         AND company IS NOT NULL AND TRIM(company) <> '' THEN company
    ELSE 'Direct'
  END,
  agent_flag = CASE WHEN agent IS NOT NULL AND TRIM(agent) <> '' THEN 1 ELSE 0 END,
  company_flag = CASE WHEN company IS NOT NULL AND TRIM(company) <> '' THEN 1 ELSE 0 END;

-- (recommended) re-enable safe-updates for safety afterwards
SET SQL_SAFE_UPDATES = 1;

SELECT booking_source, COUNT(*) AS cnt
FROM hotel_bookings
GROUP BY booking_source
ORDER BY cnt DESC;

SELECT COUNT(*) AS both_present
FROM hotel_bookings
WHERE agent IS NOT NULL AND TRIM(agent) <> ''
  AND company IS NOT NULL AND TRIM(company) <> '';

-- 3)

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country,
  SUM(CASE WHEN TRIM(country) = '' THEN 1 ELSE 0 END) AS blank_country,
  SUM(CASE WHEN country = 'Unknown' THEN 1 ELSE 0 END) AS unknown_country
FROM hotel_bookings;

UPDATE hotel_bookings
SET country = 'Unknown'
WHERE country IS NULL OR TRIM(country) = '';

SELECT 
  SUM(CASE WHEN country = 'Unknown' THEN 1 ELSE 0 END) AS updated_to_unknown
FROM hotel_bookings;

-- Distinct country codes in main table
SELECT DISTINCT country
FROM hotel_bookings
ORDER BY country;

-- Check which countries in main data are not in lookup
SELECT DISTINCT hb.country
FROM hotel_bookings hb
LEFT JOIN country_continent_lookup cc
  ON hb.country = cc.country
WHERE cc.country IS NULL;
--
ALTER TABLE hotel_bookings
ADD COLUMN continent VARCHAR(50);

UPDATE hotel_bookings hb
LEFT JOIN country_continent_lookup cc
  ON hb.country = cc.country
SET hb.continent = cc.continent;

UPDATE hotel_bookings
SET continent = 'Unknown'
WHERE continent IS NULL OR TRIM(continent) = '';

SELECT continent, COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY continent
ORDER BY total_bookings DESC;

-- 4 ) Adr fix 

SELECT MIN(adr) AS min_adr, MAX(adr) AS max_adr
FROM hotel_bookings;

SELECT COUNT(*) AS negative_adr_count
FROM hotel_bookings
WHERE adr < 0;

UPDATE hotel_bookings
SET adr = 0
WHERE adr < 0;

-- 5 ) Negative stay duration 
  
SELECT COUNT(*) AS invalid_stay
FROM hotel_bookings
WHERE stays_in_weekend_nights < 0 OR stays_in_week_nights < 0;

-- 6 ) Check for NULLs in any leftover columns

SELECT 
    SUM(CASE WHEN adr IS NULL THEN 1 ELSE 0 END) AS null_adr,
    SUM(CASE WHEN deposit_type IS NULL THEN 1 ELSE 0 END) AS null_deposit,
    SUM(CASE WHEN reservation_status IS NULL THEN 1 ELSE 0 END) AS null_status
FROM hotel_bookings;

-- 7 ) just sanity checks 

SELECT DISTINCT hotel
FROM hotel_bookings;

SELECT DISTINCT is_canceled
FROM hotel_bookings;

SELECT DISTINCT deposit_type
FROM hotel_bookings;

SELECT DISTINCT reservation_status
FROM hotel_bookings;

SELECT DISTINCT meal
FROM hotel_bookings;

SELECT DISTINCT market_segment
FROM hotel_bookings;

SELECT DISTINCT distribution_channel
FROM hotel_bookings;

SELECT reservation_status_date
FROM hotel_bookings
LIMIT 10;

SELECT
    SUM(hotel IS NULL) AS null_hotel,
    SUM(is_canceled IS NULL) AS null_is_canceled,
    SUM(deposit_type IS NULL) AS null_deposit_type,
    SUM(reservation_status IS NULL) AS null_res_status
FROM hotel_bookings;

SELECT 
  MIN(lead_time) AS min_lead, 
  MAX(lead_time) AS max_lead,
  SUM(lead_time < 0) AS neg_lead_count,
  SUM(lead_time > 1095) AS over_3yrs_count  -- flag super-extremes (>3 years)
FROM hotel_bookings;

-- 8) handling previous_cancellations & previous_bookings_not_canceled
-- binary check
SELECT DISTINCT is_repeated_guest FROM hotel_bookings;

-- negatives or weird values in histories
SELECT 
  MIN(previous_cancellations) AS min_prev_cancel,
  MIN(previous_bookings_not_canceled) AS min_prev_noncancel,
  SUM(previous_cancellations < 0) AS neg_prev_cancel_count,
  SUM(previous_bookings_not_canceled < 0) AS neg_prev_noncancel_count
FROM hotel_bookings;

-- logical consistency (optional check)
SELECT
  SUM(is_repeated_guest = 0 AND (previous_cancellations > 0 OR previous_bookings_not_canceled > 0)) AS flag_should_be_repeat,
  SUM(is_repeated_guest = 1 AND (previous_cancellations = 0 AND previous_bookings_not_canceled = 0)) AS flag_marked_repeat_but_no_history
FROM hotel_bookings;

-- Add derived consistency flags and a clean repeat flag
ALTER TABLE hotel_bookings
  ADD COLUMN prior_activity_flag TINYINT DEFAULT 0,        -- history exists?
  ADD COLUMN should_be_repeat_flag TINYINT DEFAULT 0,      -- history>0 but is_repeated_guest=0
  ADD COLUMN marked_repeat_but_no_history_flag TINYINT DEFAULT 0, -- opposite inconsistency
  ADD COLUMN repeat_status_clean TINYINT DEFAULT 0;        -- our final "repeat" flag for analysis

UPDATE hotel_bookings
SET prior_activity_flag = CASE 
        WHEN previous_cancellations > 0 OR previous_bookings_not_canceled > 0 THEN 1 ELSE 0 END,
    should_be_repeat_flag = CASE 
        WHEN is_repeated_guest = 0 AND (previous_cancellations > 0 OR previous_bookings_not_canceled > 0) THEN 1 ELSE 0 END,
    marked_repeat_but_no_history_flag = CASE 
        WHEN is_repeated_guest = 1 AND previous_cancellations = 0 AND previous_bookings_not_canceled = 0 THEN 1 ELSE 0 END,
    repeat_status_clean = CASE 
        WHEN (previous_cancellations > 0 OR previous_bookings_not_canceled > 0) OR is_repeated_guest = 1 THEN 1 ELSE 0 END;

-- Counts of inconsistencies (should match your earlier numbers)
SELECT 
  SUM(should_be_repeat_flag) AS should_be_repeat,
  SUM(marked_repeat_but_no_history_flag) AS marked_repeat_but_no_history
FROM hotel_bookings;

-- Use this clean flag in analysis (e.g., cancellation rate by repeat status)
SELECT repeat_status_clean,
       COUNT(*) AS bookings,
       ROUND(AVG(is_canceled)*100,2) AS cancel_rate_pct,
       ROUND(AVG(adr),2) AS avg_adr
FROM hotel_bookings
GROUP BY repeat_status_clean;

-- More columns sanity checks 

-- distinct sets
SELECT COUNT(DISTINCT reserved_room_type) AS distinct_reserved,
       COUNT(DISTINCT assigned_room_type) AS distinct_assigned
FROM hotel_bookings;

-- how often they differ (upgrade/downgrade signal)
SELECT 
  SUM(reserved_room_type <> assigned_room_type) AS diff_count
FROM hotel_bookings;

SELECT 
  MIN(booking_changes) AS min_changes,
  MAX(booking_changes) AS max_changes,
  SUM(booking_changes < 0) AS neg_changes_count
FROM hotel_bookings;

SELECT 
  MIN(days_in_waiting_list) AS min_wait,
  MAX(days_in_waiting_list) AS max_wait,
  SUM(days_in_waiting_list < 0) AS neg_wait_count,
  SUM(days_in_waiting_list > 365) AS over_year_wait_count  -- flag outliers
FROM hotel_bookings;

SELECT 
  MIN(total_of_special_requests) AS min_req,
  MAX(total_of_special_requests) AS max_req,
  SUM(total_of_special_requests < 0) AS neg_req_count
FROM hotel_bookings;

SELECT * FROM hotel_bookings;

-- Phase 3 Start 

-- 1) Adding Arrival Date Collum 
ALTER TABLE hotel_bookings
ADD COLUMN arrival_date DATE;

UPDATE hotel_bookings
SET arrival_date = STR_TO_DATE(
    CONCAT(arrival_date_day_of_month, '-', arrival_date_month, '-', arrival_date_year),
    '%d-%M-%Y'
);

SELECT arrival_date, arrival_date_day_of_month, arrival_date_month, arrival_date_year
FROM hotel_bookings
LIMIT 10;

-- A) Any parsing failures?
SELECT 
  SUM(arrival_date IS NULL) AS bad_arrival_dates
FROM hotel_bookings;

-- B) Range check (dataset is Jul 2015 – Aug 2017)
SELECT 
  MIN(arrival_date) AS min_arrival,
  MAX(arrival_date) AS max_arrival,
  SUM(arrival_date < '2015-07-01' OR arrival_date > '2017-08-31') AS out_of_range_rows
FROM hotel_bookings;

-- 2) Convert reservation_status_date to a real DATE

ALTER TABLE hotel_bookings
ADD COLUMN reservation_status_dt DATE;

UPDATE hotel_bookings
SET reservation_status_dt = STR_TO_DATE(reservation_status_date, '%d-%m-%Y');

SELECT 
  MIN(reservation_status_dt) AS min_status_dt,
  MAX(reservation_status_dt) AS max_status_dt,
  SUM(reservation_status_dt IS NULL) AS bad_status_dt
FROM hotel_bookings;

-- Quick peek
SELECT reservation_status_date, reservation_status_dt
FROM hotel_bookings
LIMIT 10;

SELECT 
  SUM(reservation_status_dt < '2015-07-01') AS status_before_window,
  SUM(reservation_status_dt > '2017-09-14') AS status_after_window
FROM hotel_bookings;

-- 3) stay_length, guest_count, cancellation_flag

ALTER TABLE hotel_bookings
  ADD COLUMN stay_length INT,
  ADD COLUMN guest_count INT,
  ADD COLUMN cancellation_flag TINYINT;

UPDATE hotel_bookings
SET stay_length = COALESCE(stays_in_weekend_nights,0) + COALESCE(stays_in_week_nights,0),
    guest_count = COALESCE(adults,0) + COALESCE(children,0) + COALESCE(babies,0),
    cancellation_flag = is_canceled;

-- Quick check
SELECT 
  MIN(stay_length) AS min_stay, MAX(stay_length) AS max_stay,
  MIN(guest_count) AS min_guests, MAX(guest_count) AS max_guests
FROM hotel_bookings;

SELECT 
    COUNT(*) AS total_rows,
    SUM(cancellation_flag = 0) AS zero_count,
    SUM(cancellation_flag = 1) AS one_count,
    SUM(cancellation_flag NOT IN (0,1)) AS invalid_values
FROM hotel_bookings;

SELECT 
    SUM(cancellation_flag <> is_canceled) AS mismatch_count
FROM hotel_bookings;

SELECT 
    cancellation_flag,
    COUNT(*) AS count_rows
FROM hotel_bookings
GROUP BY cancellation_flag;

-- 4) booking_date (arrival_date – lead_time)
ALTER TABLE hotel_bookings
  ADD COLUMN booking_date DATE;

UPDATE hotel_bookings
SET booking_date = DATE_SUB(arrival_date, INTERVAL COALESCE(lead_time,0) DAY);

-- Verify range feels right
SELECT MIN(booking_date) AS min_booking, MAX(booking_date) AS max_booking
FROM hotel_bookings;

-- 5) season (Northern Hemisphere)
ALTER TABLE hotel_bookings
  ADD COLUMN season VARCHAR(10);

UPDATE hotel_bookings
SET season = CASE MONTH(arrival_date)
  WHEN 12 THEN 'Winter' WHEN 1 THEN 'Winter' WHEN 2 THEN 'Winter'
  WHEN 3 THEN 'Spring' WHEN 4 THEN 'Spring' WHEN 5 THEN 'Spring'
  WHEN 6 THEN 'Summer' WHEN 7 THEN 'Summer' WHEN 8 THEN 'Summer'
  WHEN 9 THEN 'Autumn' WHEN 10 THEN 'Autumn' WHEN 11 THEN 'Autumn'
END;

-- Verify
SELECT season, COUNT(*) AS cnt
FROM hotel_bookings
GROUP BY season
ORDER BY cnt DESC;

-- Optional: ensure no NULLs
SELECT SUM(season IS NULL) AS null_season FROM hotel_bookings;

-- FINAL CHECK BLOCK Pre-KPI Verification

SELECT 
    MIN(lead_time) AS min_lt,
    MAX(lead_time) AS max_lt,
    AVG(lead_time) AS avg_lt
FROM hotel_bookings;

SELECT 
    MIN(adr) AS min_adr,
    MAX(adr) AS max_adr,
    AVG(adr) AS avg_adr
FROM hotel_bookings;

SELECT 
    MIN(guest_count),
    MAX(guest_count),
    AVG(guest_count)
FROM hotel_bookings;

SELECT 
    MIN(stay_length),
    MAX(stay_length),
    AVG(stay_length)
FROM hotel_bookings;

SELECT hotel, COUNT(*) 
FROM hotel_bookings
GROUP BY hotel;

SELECT arrival_date_year, COUNT(*)
FROM hotel_bookings
GROUP BY arrival_date_year
ORDER BY arrival_date_year;

SELECT 
    SUM(is_canceled) AS total_canceled,
    COUNT(*) AS total_bookings,
    ROUND(SUM(is_canceled)/COUNT(*)*100,2) AS cancel_rate_pct
FROM hotel_bookings;

-- KPIS (DISTRIBUTED IN 4 GROUPS)

            -- 1ST GROUP-Booking Volume & Trends
-- Total Bookings
SELECT 
    COUNT(*) AS total_bookings 
FROM hotel_bookings;

-- Booking by Year 
SELECT 
    arrival_date_year AS year,
    COUNT(*) AS bookings
FROM hotel_bookings
GROUP BY arrival_date_year
ORDER BY arrival_date_year;

-- Booking by Month 
SELECT 
    arrival_date_month AS month,
    COUNT(*) AS bookings
FROM hotel_bookings
GROUP BY arrival_date_month
ORDER BY FIELD(arrival_date_month,
    'January','February','March','April','May','June','July','August','September','October','November','December');

-- Bookings by Season
SELECT 
    season,
    COUNT(*) AS bookings
FROM hotel_bookings
GROUP BY season
ORDER BY bookings DESC;

    -- Group B:Profit & Revenue Metrics

-- Overall ADR
SELECT ROUND(AVG(adr),2) AS adr_overall_realized
FROM hotel_bookings
WHERE is_canceled = 0;

-- ADR by year
SELECT arrival_date_year AS year,
       ROUND(AVG(adr),2) AS adr_realized
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY arrival_date_year
ORDER BY year;

-- ADR by month
SELECT arrival_date_month AS month_name,
       ROUND(AVG(adr),2) AS adr_realized
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY arrival_date_month
ORDER BY FIELD(arrival_date_month,'January','February','March','April','May','June','July','August','September','October','November','December');

-- ADR by hotel type (City vs Resort)
SELECT hotel,
       ROUND(AVG(adr),2) AS adr_realized
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel
ORDER BY adr_realized DESC;

-- ADR by Season
SELECT season,
       ROUND(AVG(adr),2) AS adr_realized
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY season
ORDER BY adr_realized DESC;

-- Overall realized revenue
SELECT ROUND(SUM(adr * stay_length),2) AS revenue_realized
FROM hotel_bookings
WHERE is_canceled = 0;

-- Potential revenue (incl. canceled)
SELECT ROUND(SUM(adr * stay_length),2) AS revenue_potential
FROM hotel_bookings;

-- Revenue by yeaR
SELECT arrival_date_year AS year,
       ROUND(SUM(adr * stay_length),2) AS revenue_realized
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY arrival_date_year
ORDER BY year;

-- Revenue by month
SELECT arrival_date_month AS month_name,
       ROUND(SUM(adr * stay_length),2) AS revenue_realized
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY arrival_date_month
ORDER BY FIELD(arrival_date_month,'January','February','March','April','May','June','July','August','September','October','November','December');

-- Revenue by hotel type
SELECT hotel,
       ROUND(SUM(adr * stay_length),2) AS revenue_realized
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel
ORDER BY revenue_realized DESC;

-- Revenue by season
SELECT season,
       ROUND(SUM(adr * stay_length),2) AS revenue_realized
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY season
ORDER BY revenue_realized DESC;

-- Avg revenue per booking
SELECT ROUND(AVG(adr * stay_length),2) AS avg_rev_per_booking
FROM hotel_bookings
WHERE is_canceled = 0;

      -- Guest Behavior KPIs
 -- Average Length of Stay
-- Overall LOS (only realized stays)
SELECT ROUND(AVG(stay_length),2) AS avg_los
FROM hotel_bookings
WHERE is_canceled = 0;

-- By hotel
SELECT hotel, ROUND(AVG(stay_length),2) AS avg_los
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel
ORDER BY avg_los DESC;

-- By season
SELECT season, ROUND(AVG(stay_length),2) AS avg_los
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY season
ORDER BY avg_los DESC;
 
  -- Guest Composition (adults / children / babies)
-- Averages per booking (realized)
SELECT 
  ROUND(AVG(adults),2)   AS avg_adults,
  ROUND(AVG(children),2) AS avg_children,
  ROUND(AVG(babies),2)   AS avg_babies,
  ROUND(AVG(guest_count),2) AS avg_guest_count
FROM hotel_bookings
WHERE is_canceled = 0;

-- Share of bookings with kids
SELECT 
  ROUND(100*AVG(CASE WHEN children > 0 OR babies > 0 THEN 1 ELSE 0 END),2) AS pct_bookings_with_kids
FROM hotel_bookings
WHERE is_canceled = 0;

-- Guest-count buckets
SELECT bucket, COUNT(*) AS bookings
FROM (
  SELECT CASE 
           WHEN guest_count <= 1 THEN '1'
           WHEN guest_count = 2 THEN '2'
           WHEN guest_count BETWEEN 3 AND 4 THEN '3-4'
           ELSE '5+'
         END AS bucket
  FROM hotel_bookings
  WHERE is_canceled = 0
) x
GROUP BY bucket
ORDER BY 
  CASE bucket WHEN '1' THEN 1 WHEN '2' THEN 2 WHEN '3-4' THEN 3 ELSE 4 END;
  
  -- Lead Time – summary & buckets
-- Summary stats
SELECT 
  MIN(lead_time) AS min_lt,
  MAX(lead_time) AS max_lt,
  ROUND(AVG(lead_time),2) AS avg_lt
FROM hotel_bookings;

-- Bucket distribution (all bookings)
SELECT bucket, COUNT(*) AS bookings
FROM (
  SELECT CASE
           WHEN lead_time <= 7 THEN '0–7 days'
           WHEN lead_time <= 30 THEN '8–30'
           WHEN lead_time <= 90 THEN '31–90'
           WHEN lead_time <= 180 THEN '91–180'
           ELSE '181+'
         END AS bucket
  FROM hotel_bookings
) b
GROUP BY bucket
ORDER BY 
  CASE bucket 
    WHEN '0–7 days' THEN 1 
    WHEN '8–30' THEN 2 
    WHEN '31–90' THEN 3 
    WHEN '91–180' THEN 4 
    ELSE 5 END;
    
 -- Lead Time by hotel & season (for quick patterns)
-- By hotel
SELECT hotel, ROUND(AVG(lead_time),1) AS avg_lead_time
FROM hotel_bookings
GROUP BY hotel
ORDER BY avg_lead_time DESC;

-- By season
SELECT season, ROUND(AVG(lead_time),1) AS avg_lead_time
FROM hotel_bookings
GROUP BY season
ORDER BY avg_lead_time DESC;
 
 -- Repeat vs New guest mix (behavior signal)
-- Share of repeat guests
SELECT 
  ROUND(100*AVG(CASE WHEN repeat_status_clean = 1 THEN 1 ELSE 0 END),2) AS pct_repeat_guests
FROM hotel_bookings;

-- Avg LOS by repeat vs new (realized)
SELECT repeat_status_clean, ROUND(AVG(stay_length),2) AS avg_los
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY repeat_status_clean;

 -- Bookings with special requests
SELECT 
  ROUND(100*AVG(CASE WHEN total_of_special_requests > 0 THEN 1 ELSE 0 END),2) AS pct_bookings_with_requests,
  ROUND(AVG(total_of_special_requests),2) AS avg_requests_per_booking
FROM hotel_bookings
WHERE is_canceled = 0;

       -- GROUP D — CANCELLATION INTELLIGENCE
-- Overall cancellation percentage
SELECT 
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS total_canceled,
    ROUND(SUM(is_canceled)*100.0/COUNT(*),2) AS cancel_rate_pct
FROM hotel_bookings;

-- Cancellation trends by year
SELECT 
    arrival_date_year AS year,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled_bookings,
    ROUND(SUM(is_canceled)*100.0/COUNT(*),2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY arrival_date_year
ORDER BY year;

-- Cancellation Rate by Lead-Time Bucket , More lead time often increases cancellations
SELECT bucket, 
       COUNT(*) AS total_bookings,
       SUM(is_canceled) AS canceled_bookings,
       ROUND(SUM(is_canceled)*100.0/COUNT(*),2) AS cancel_rate_pct
FROM (
    SELECT 
        CASE 
            WHEN lead_time <= 7 THEN '0–7 days'
            WHEN lead_time <= 30 THEN '8–30 days'
            WHEN lead_time <= 90 THEN '31–90 days'
            WHEN lead_time <= 180 THEN '91–180 days'
            ELSE '181+ days'
        END AS bucket,
        is_canceled
    FROM hotel_bookings
) AS t
GROUP BY bucket
ORDER BY 
    CASE bucket 
        WHEN '0–7 days' THEN 1 
        WHEN '8–30 days' THEN 2 
        WHEN '31–90 days' THEN 3 
        WHEN '91–180 days' THEN 4 
        ELSE 5 
    END;

-- Cancellation Rate by Market Segment ,Channel / Segment based cancellation
SELECT 
    market_segment,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled_bookings,
    ROUND(SUM(is_canceled)*100.0/COUNT(*),2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY market_segment
ORDER BY cancel_rate_pct DESC;

-- Country-wise cancellation heat check
SELECT 
    country,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled_bookings,
    ROUND(SUM(is_canceled)*100.0/COUNT(*),2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY country
HAVING COUNT(*) > 100  -- filter to major countries only
ORDER BY cancel_rate_pct DESC
LIMIT 10;

-- Estimated unrealized vs realized revenue
SELECT 
    ROUND(SUM(CASE WHEN is_canceled = 1 THEN adr * stay_length ELSE 0 END),2) AS lost_revenue,
    ROUND(SUM(CASE WHEN is_canceled = 0 THEN adr * stay_length ELSE 0 END),2) AS realized_revenue
FROM hotel_bookings;

-- Data Enrichment (Joins with Lookup Tables)

-- Join hotel_bookings with market_segment_lookup
SELECT 
    hb.*,
    msl.segment_desc
FROM hotel_bookings AS hb
LEFT JOIN market_segment_lookup AS msl
    ON hb.market_segment = msl.market_segment;

-- Join hotel_bookings with distribution_channel_lookup
SELECT 
    hb.*,
    dcl.channel_desc
FROM hotel_bookings AS hb
LEFT JOIN distribution_channel_lookup AS dcl
    ON hb.distribution_channel = dcl.distribution_channel;

CREATE OR REPLACE VIEW hotel_bookings_enriched AS
SELECT 
    hb.*,
    msl.segment_desc,
    dcl.channel_desc
FROM hotel_bookings AS hb
LEFT JOIN market_segment_lookup AS msl
    ON hb.market_segment = msl.market_segment
LEFT JOIN distribution_channel_lookup AS dcl
    ON hb.distribution_channel = dcl.distribution_channel;


SELECT * FROM hotel_bookings_enriched limit 10 ;

SELECT
  (SELECT COUNT(*) FROM hotel_bookings) AS base_count,
  (SELECT COUNT(*) FROM hotel_bookings_enriched) AS view_count;

