USE Portfolio_bikes
GO

SELECT * FROM bikes

--Plan for the analysis:
--1. Find the day in a month with the longest average trip time
--2. Sort days of the week by the average trip duration during the day
--3. Which stations were the most popular station to start off the trip and to end the trip?
--4. Any difference in the longevity of the trips for members and casual users?
--5. Extract time from the column and check what time during the day was the most the least busy for the bikers
--6. What are the rush hours for bikers?
--7. Calculate the distance length by pifagorean theorem and find days that have the shortest and longest by average distance trips 
--8. What was the average number of trip per day?
--9. What was the percentage of days with trip duration higher than that of the monthly average trip duration?
--10. What were the stations with the highest percentage of trips that ended at the same station?
--11. During what days trip were the longest?

-- 11. average trip duration
-- Join, case, iif, ratio

--1. Find the day in a month with the longest average trip time starting at the trip start

-- find the longest average trip time

SELECT day_of_start, AVG(total_diff_seconds) AS average_diff_by_day
FROM
	(SELECT 
	-- find diff per hour, min, sec
	DATEDIFF(HOUR, started_at, ended_at) AS hours_diff,
	DATEDIFF(MINUTE, started_at, ended_at) AS min_diff,
	DATEDIFF(SECOND, started_at, ended_at) AS sec_diff,

	-- convert difference to second
	DATEDIFF(HOUR, started_at, ended_at) * 3600 + 
	DATEDIFF(MINUTE, started_at, ended_at) * 60 +
	DATEDIFF(SECOND, started_at, ended_at) AS total_diff_seconds,

	-- get the day
	DATEPART(DAY, started_at) AS day_of_start
	FROM bikes) start_travel
GROUP BY day_of_start
ORDER BY AVG(total_diff_seconds) DESC

-- calculating the exact difference between the trips
SELECT 12251/60
SELECT 8800/60
SELECT 12251/60 - 8800/60
-- the day with the longest average time trip was on the 3rd of April 2020 with the total time of 204 hours
-- which is larger than that of the 2nd busiest day accounted for only 146 hours, so the time difference is 
-- about 25%.



--2. Sort days of the week by the average trip duration during the day

-- get the day from the datetime column

SELECT 
-- get the day name
DATENAME(WEEKDAY, started_at) AS day_of_start,

-- calculate the total time driven
SUM(DATEDIFF(HOUR, started_at, ended_at) * 3600 + 
DATEDIFF(MINUTE, started_at, ended_at) * 60 +
DATEDIFF(SECOND, started_at, ended_at)) AS total_diff_seconds

FROM bikes
GROUP BY DATENAME(WEEKDAY, started_at)
ORDER BY SUM(DATEDIFF(HOUR, started_at, ended_at) * 3600 + 
		DATEDIFF(MINUTE, started_at, ended_at) * 60 +
		DATEDIFF(SECOND, started_at, ended_at))

-- results: Wednesday was the day with the lowest traffic, while weekend was the busiest.
-- the ratio Wednesday/Sunday or Saturday was about 1/3


--3. Which stations were the most popular station to start off the trip and to end the trip by day?

SELECT * FROM bikes

-- the most popular stations to start off the trip
SELECT TOP 10
	DATENAME(WEEKDAY, started_at) AS day_of_start, start_station_name, 
	COUNT(start_station_name) AS count_stations
FROM bikes
GROUP BY DATENAME(WEEKDAY, started_at), start_station_name
ORDER BY COUNT(start_station_name) DESC
-- Clark and Elm street, Stockton, Broadway


-- the most popular stations to end up the trip
SELECT TOP 10
	DATENAME(WEEKDAY, ended_at) AS day_of_start, start_station_name, 
	COUNT(start_station_name) AS count_stations
FROM bikes
GROUP BY DATENAME(WEEKDAY, ended_at), start_station_name
ORDER BY COUNT(start_station_name) DESC
-- Clark and Elm street, Stockton, Broadway


--4. Any difference in the longevity of the trips for members and casual users?

SELECT member_casual,
-- total time for a trip
SUM(DATEDIFF(HOUR, started_at, ended_at) * 3600 + 
DATEDIFF(MINUTE, started_at, ended_at) * 60 +
DATEDIFF(SECOND, started_at, ended_at)) AS total_diff_seconds
FROM bikes
GROUP BY member_casual

-- results: it is about 1.5 times longer trip were detected for the members in contrast to casual users


--5. Extract time from the column and check what time during the day was the most the least busy for the bikers
-- use iif, case statement

-- 00:00:01 - 05:00:00 night
-- 05:00:01 - 12:00:00 morning
-- 12:00:01 - 17:00:00 day
-- 17:00:01 - 23:00:00 evening

SELECT * FROM bikes
CREATE VIEW part_of_the_days AS
	(SELECT 
	-- get the day part 
		CASE 
			WHEN time_casted BETWEEN '00:00:01' AND '05:00:00' THEN 'night'
			WHEN time_casted BETWEEN '05:00:01' AND '12:00:00' THEN 'morning'
			WHEN time_casted BETWEEN '12:00:01' AND '17:00:00' THEN 'day'
			ELSE 'evening'
		END AS part_of_the_day,
		total_diff_seconds
	FROM
		-- assign new column based on the time
		(SELECT CAST(started_at AS TIME) AS time_casted,
		DATEDIFF(HOUR, started_at, ended_at) * 3600 + 
		DATEDIFF(MINUTE, started_at, ended_at) * 60 +
		DATEDIFF(SECOND, started_at, ended_at) AS total_diff_seconds
		FROM bikes) lookup_table)


SELECT part_of_the_day, SUM(total_diff_seconds) AS total_time_driven
FROM part_of_the_days
GROUP BY part_of_the_day
ORDER BY SUM(total_diff_seconds) DESC

-- results: the use of bikes in the morning is 8 times of that in the night, while daily use and evening use exceed the 
-- morning by 10 times!



--6. What are the rush hours for bikers?

SELECT hour_of_start, SUM(total_diff_seconds) AS total_time_of_ride
FROM

	(SELECT ride_id AS rided_id,
	DATEPART(HOUR, started_at) AS hour_of_start
	FROM bikes) ride_hour

	INNER JOIN

	(SELECT ride_id, CAST(started_at AS TIME) AS time_casted,
	DATEDIFF(HOUR, started_at, ended_at) * 3600 + 
	DATEDIFF(MINUTE, started_at, ended_at) * 60 +
	DATEDIFF(SECOND, started_at, ended_at) AS total_diff_seconds
	FROM bikes) ride_total 
	ON ride_hour.rided_id = ride_total.ride_id

GROUP BY hour_of_start
ORDER BY SUM(total_diff_seconds) DESC

-- results: the rush hour is from 3 pm to 4 pm



--7. Calcuualte the distance length by pifagorean theorem and find days that have the shortest and longest by average distance trips 
SELECT * FROM bikes

CREATE VIEW part_of_the_check AS
	(SELECT ride_id,
	-- get the day part 
		CASE 
			WHEN time_casted BETWEEN '00:00:01' AND '05:00:00' THEN 'night'
			WHEN time_casted BETWEEN '05:00:01' AND '12:00:00' THEN 'morning'
			WHEN time_casted BETWEEN '12:00:01' AND '17:00:00' THEN 'day'
			ELSE 'evening'
		END AS part_of_the_day,
		total_diff_seconds
	FROM
		-- assign new column based on the time
		(SELECT ride_id, CAST(started_at AS TIME) AS time_casted,
		DATEDIFF(HOUR, started_at, ended_at) * 3600 + 
		DATEDIFF(MINUTE, started_at, ended_at) * 60 +
		DATEDIFF(SECOND, started_at, ended_at) AS total_diff_seconds
		FROM bikes) lookup_table)

SELECT part_of_the_day, AVG(length_trip) AS max_length_a_day
FROM
(SELECT ride_id AS ride, SQRT(POWER(ABS(start_lat - end_lat), 2) + POWER(ABS(start_lng - end_lng),2)) AS length_trip 
FROM bikes) rides

INNER JOIN

(SELECT * FROM part_of_the_check) view_trips
ON rides.ride = view_trips.ride_id
GROUP BY part_of_the_day
ORDER BY AVG(length_trip) DESC

-- results: distance covered by bikers was relatively the same for morning, day and evening


--8. What was the average number of trips per day?

SELECT DATEPART(DAY, started_at) AS started_day, COUNT(ride_id) AS total_rides
FROM bikes
GROUP BY DATEPART(DAY, started_at)
ORDER BY COUNT(ride_id) DESC
-- last part of the month was the most active


--9. What was the percentage of days with trip duration higher than that of the monthly average trip duration?

SELECT * FROM bikes


--10. What were the stations with the highest percentage of trips that ended at the same station?

SELECT the_same_station, 
CAST(same AS float)/CAST(total AS float) AS ratio_yes, 
CAST(not_the_same AS float)/CAST(total AS float) AS ratio_no 

FROM
	(SELECT the_same_station, COUNT(ride_id) AS count_trips, SUM(IIF(the_same_station='Yes', 1, 0)) AS same,
	SUM(IIF(the_same_station='no', 1, 0)) AS not_the_same, 
	SUM(IIF(the_same_station='Yes', 1, 0)) + SUM(IIF(the_same_station='no', 1, 0)) AS total
	FROM
	(SELECT ride_id, IIF(start_station_id = end_station_id, 'yes', 'no') AS the_same_station
	FROM bikes) gg
GROUP BY the_same_station) HH

