------------------- HW 1 SQL code ----------------

-- Q3: During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, **respectively**, happened:
-- 1. Up to 1 mile
-- 2. In between 1 (exclusive) and 3 miles (inclusive),
-- 3. In between 3 (exclusive) and 7 miles (inclusive),
-- 4. In between 7 (exclusive) and 10 miles (inclusive),
-- 5. Over 10 miles 
SELECT
     COUNT(*) AS trip_count
 FROM
     green_taxi_data
 WHERE
     lpep_pickup_datetime >= '2019-10-01' and
	 lpep_dropoff_datetime < '2019-11-01'
	 and trip_distance > 10 -- 35189
	-- and trip_distance > 7 and trip_distance <= 10 --27678
	--   and trip_distance > 3 and trip_distance <= 7 --109603
	-- and trip_distance > 1 and trip_distance <= 3 --198924
	-- and trip_distance <= 1 --104802 (actual there is trip < 0. I think should be excluded.)
;

-- Q4: Which was the pick up day with the longest trip distance?
-- Use the pick up time for your calculations.
-- Tip: For every day, we only care about one single trip with the longest distance. 
select *
from green_taxi_data
where trip_distance = (
	select max(trip_distance) 
	from green_taxi_data
	where 
	 lpep_pickup_datetime::date = lpep_dropoff_datetime::date
	)
	and lpep_pickup_datetime::date = lpep_dropoff_datetime::date
; -- "2019-10-11 20:34:21"


-- Q5 Which were the top pickup locations with over 13,000 in
-- `total_amount` (across all trips) for 2019-10-18?
-- Consider only `lpep_pickup_datetime` when filtering by date.
select "PULocationID", "Zone", sum(total_amount)
from green_taxi_data g
left join taxi_zone_lookup t
on g."PULocationID" = t."LocationID"
where lpep_pickup_datetime::date = '2019-10-18'
group by "PULocationID", "Zone"
having sum(total_amount) > 13000
order by 2 desc
;
-- "PULocationID"	"Zone"	"sum"
-- 166	"Morningside Heights"	13029.790000000028
-- 75	"East Harlem South"	16797.260000000068
-- 74	"East Harlem North"	18686.68000000008


-- Q6 For the passengers picked up in October 2019 in the zone
-- name "East Harlem North", which was the drop off zone that had
-- the largest tip?
-- Note: it's `tip` , not `trip`
-- We need the name of the zone, not the ID.
select g."DOLocationID"
	, t."Zone" as drop_off_zone
	, g.tip_amount
	, g.lpep_pickup_datetime
	, g."PULocationID"
from green_taxi_data g
left join taxi_zone_lookup t
	on g."DOLocationID" = t."LocationID"
where tip_amount = (
	select max(Tip_amount)
	from green_taxi_data g
	left join taxi_zone_lookup t
	on g."PULocationID" = t."LocationID"
	where to_char(g.lpep_pickup_datetime, 'YYYY-MM') = '2019-10'
	and "Zone" = 'East Harlem North'
) 
and to_char(g.lpep_pickup_datetime, 'YYYY-MM') = '2019-10'
and g."PULocationID" = 74
;
-- "DOLocationID"	"drop_off_zone"	"tip_amount"	"lpep_pickup_datetime"	"PULocationID"
-- 132	"JFK Airport"	87.3	"2019-10-25 15:50:05"	74




-- "index"	"VendorID"	"lpep_pickup_datetime"	"lpep_dropoff_datetime"	"store_and_fwd_flag"	"RatecodeID"	"PULocationID"	"DOLocationID"	"passenger_count"	"trip_distance"	"fare_amount"	"extra"	"mta_tax"	"tip_amount"	"tolls_amount"	"ehail_fee"	"improvement_surcharge"	"total_amount"	"payment_type"	"trip_type"	"congestion_surcharge"
-- 0	2	"2019-10-01 00:26:02"	"2019-10-01 00:39:58"	"N"	1	112	196	1	5.88	18	0.5	0.5	0	0		0.3	19.3	2	1	0

