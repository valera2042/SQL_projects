USE Portfolio_bikes
GO

SELECT * FROM bikes

--Plan for the analysis:
--1. Find the day in a month with the longest average trip time
--2. Sort days of the week by the average trip duration during the day
--3. Which stations were the most popular station to start off the trip and to end the trip?
--4. Any difference in the longevity of the trips for members and casual users?
--5. Extract time from the column and check what time during the day was the most the least busy for the bikers
--6. Calcuualte the distance length by pifagorean theorem and find days that have the shortest and longest by average distance trips 
--7. What was the average number of trip per day?
--8. What was the percentage of days with trip duration higher than that of the monthly average trip duration?
--9. What were the stations with the highest percentage of trips that ended at the same station?
--10. During what days trip were the longest?

-- 11. average trip duration


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



