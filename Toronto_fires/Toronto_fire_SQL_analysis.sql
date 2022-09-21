
USE Toronto
GO
SELECT * FROM fire


-- Plan for analysis


--1. If you buy a new house where alarm system must be installed first? In what room would you install it? 
--What is the most frequent place for fire incident?
--2. Fire in which parts of the house led to the largest business impact?
--3. The highest per cent of people rescued based on the where fire incident took its place?
--4. What parts of the house suffer from dollar loss the most?
--5. Places with the most people displaced due to fire incident?
--6. What is the ratio of fire incident that was speaded or confined?
--7. How the presence of fire alaram system influenced the evacuation? (broad topic) given that the fire alarm system was on or present
--8. What was the most frequent ignition source?
--9. What was the material that first ignited based in which area this hapenned (determine that most frequent
--place and its source)
--10. What materials can be extinguished by the occupant and in what cases it is crucial to call fire department,
--where this risk is determined
--11. What was the most frequnt cause for the fire incident?
--12. What type of alarm is the most tends to fail?
--13. What locations in Toronto need better fire incident service? in which areas the time for the fire team arrival was the  longest?
--14.How long it took for a team to arrive? What are the locations with the longest/shortest fire under control time?
--15. What materials/rooms ignited resulted in the longest/shortest time to bring it under control? 



--1. If you buy a new house where alarm system must be installed first? In what room would you install it? 
-- What is the most frequent place for fire incident?

SELECT TOP 10 Area_of_Origin, COUNT(*) AS number_of_incidents_per_facility
FROM fire
GROUP BY Area_of_Origin
ORDER BY COUNT(*) DESC

-- results: these are summarized in the decreasing order
-- of the frequency of insidents: kitchen, balcony, sleeping area, trash, living area, garage, laundry area, toilet


--2. Fire in which parts of the house led to the largest business impact?

SELECT Area_of_Origin, 1 - (CAST(SUM(impact_number) AS FLOAT)/COUNT(*)) AS ratio__of_impacted_vs_nonimpacted, 
	   COUNT(*) AS TOTAL_COUNT
FROM
	(SELECT Area_of_Origin, Business_Impact, 
	IIF(Business_Impact = 'No business interruption', 1, 0) AS impact_number
	FROM fire) table_ff
GROUP BY Area_of_Origin
ORDER BY SUM(impact_number)/COUNT(*) ASC

-- results: attic area, lobbies, supply storages, roof are the areas for witch suffer the highest business impact


--3. The lowest per cent of people rescued based on the where fire incident took its place?

SELECT AVG(1 - Count_of_Persons_Rescued/perc_rescued_people_modified)AS percent_died, Area_of_Origin
FROM
	(
	SELECT Area_of_Origin, IIF(perc_rescued_people = 0, 1, perc_rescued_people) AS perc_rescued_people_modified,
	Count_of_Persons_Rescued
	FROM 
		(SELECT Area_of_Origin, Civilian_Casualties + Count_of_Persons_Rescued AS perc_rescued_people,
		Count_of_Persons_Rescued
		FROM fire) table_gg
	) FF
	GROUP BY Area_of_Origin
HAVING AVG(1 - Count_of_Persons_Rescued/perc_rescued_people_modified) = 1
ORDER BY AVG(1 - Count_of_Persons_Rescued/perc_rescued_people_modified) DESC

-- results: the results are not clear of what hapenned here, need further investigation


--4. What parts of the house suffer from dollar loss the most?

SELECT Area_of_Origin AS fire_place, SUM(Estimated_Dollar_Loss) AS _total_dollar_loss
FROM fire
GROUP BY Area_of_Origin
ORDER BY SUM(Estimated_Dollar_Loss) DESC

-- cooking area suffered the highest dollar loss, the nsleeping area and garage


--5. Places in which fire occurred causing the highest amount of people displaced due to that?

SELECT Area_of_Origin AS fire_place, SUM(Estimated_Number_Of_Persons_Displaced) AS total_people_displaced
FROM fire
GROUP BY Area_of_Origin
ORDER BY SUM(Estimated_Number_Of_Persons_Displaced) DESC

-- cooking area had the highest amount of people displaced


--6. What is the ratio of fire incident that was speaded or confined? filter on those who are more spread than confined

WITH cte_lookup_table
AS
(SELECT Area_of_Origin, COUNT(Extent_Of_Fire) AS total_cases_per_area, 
	   ROUND(SUM(IIF(Extent_Of_Fire LIKE '%confined%' OR Extent_Of_Fire LIKE 'Confined%', 1, 0))/CAST(COUNT(Extent_Of_Fire) AS FLOAT),2) AS Confined,
	   ROUND(SUM(IIF(Extent_Of_Fire LIKE '%spread%' OR Extent_Of_Fire LIKE 'Spread%', 1, 0))/CAST(COUNT(Extent_Of_Fire) AS FLOAT),2) AS Spread
FROM fire
GROUP BY Area_of_Origin) 
SELECT *, (Confined - Spread) AS difference_confined_spread
FROM cte_lookup_table
ORDER BY (Confined - Spread) DESC


--7. How the presence of fire alaram system influenced the evacuation? (broad topic) given that the fire alarm system was on or present

SELECT CAST(SUM(system_present) AS FLOAT)/11214 AS total_sum_of_working_systems
FROM
	(SELECT IIF(Fire_Alarm_System_Presence = 'Fire alarm system present', 1, 0) AS system_present
	FROM fire) ff
	
-- total amount of systems
SELECT COUNT (Fire_Alarm_System_Presence) FROM fire
-- 11214

-- results: only 55% had the working alarm systems?



--8. What was the most frequent ignition source?

SELECT Ignition_source, COUNT(Ignition_source) AS ignition_source
FROM fire
GROUP BY Ignition_source
ORDER BY COUNT(Ignition_source) DESC

-- results: stove, smoking supplies, oven, candles, burners, electrical equipment


--9. What was the material that first ignited based in which area this hapenned (determine that most frequent
--place and its source)

-- the most dangerous area (kitchen)
SELECT TOP 10 Area_of_Origin, COUNT(*) AS number_of_incidents_per_facility
FROM fire
GROUP BY Area_of_Origin
ORDER BY COUNT(*) DESC

-- place and the source
SELECT Area_of_Origin, Material_First_Ignited, 
	   COUNT(*) AS number_of_incidents_per_facility, COUNT(Material_First_Ignited) AS n_cases_materials_ignited
FROM fire
GROUP BY Area_of_Origin, Material_First_Ignited
ORDER BY COUNT(Material_First_Ignited) DESC

-- the most dangerous materials (kitchen: cooking oil, kitchen: rubbish storage)


--10. What materials TOP 10 and areas TOP 10 can be extinguished by the occupant, in all other cases please call fire department

-- areas
SELECT Area_of_Origin, SUM(IIF(Method_Of_Fire_Control = 'Extinguished by occupant', 1, 0)) / CAST(11214 AS FLOAT)  AS can_be_extinguished_by_occupant
FROM fire
GROUP BY Area_of_Origin
ORDER BY SUM(IIF(Method_Of_Fire_Control = 'Extinguished by occupant', 1, 0)) DESC

SELECT COUNT(Method_Of_Fire_Control) FROM fire
-- 11214

-- results: cooking areas had the highest % of fires that can be shut down by the occupant

-- materials
SELECT Material_First_Ignited, SUM(IIF(Method_Of_Fire_Control = 'Extinguished by occupant', 1, 0)) / CAST(11214 AS FLOAT)  AS can_be_extinguished_by_occupant
FROM fire
GROUP BY Material_First_Ignited
ORDER BY SUM(IIF(Method_Of_Fire_Control = 'Extinguished by occupant', 1, 0)) DESC

-- results: cooking oil ignition can be solved most frequently


--11. What was the most frequent cause for the fire incident? Where this hapenned? What was ignited?

SELECT Area_of_Origin, Material_First_Ignited, COUNT(Possible_Cause) AS Possible_Cause_Count
FROM fire
GROUP BY Area_of_Origin, Material_First_Ignited, Possible_Cause
ORDER BY COUNT(Possible_Cause) DESC

-- results: cooking oil, grease, rubbish/trash


--12. What type of alarm is the most tends to fail and the most robust?

WITH cte_alarms AS
-- most robust alarms
(SELECT worked.Smoke_Alarm_at_Fire_Origin_Alarm_Type, worked.alarm_type_count_worked, failed.alarm_type_count_failed
FROM
	(SELECT Smoke_Alarm_at_Fire_Origin_Alarm_Type, COUNT(Smoke_Alarm_at_Fire_Origin_Alarm_Type) AS alarm_type_count_worked
	FROM fire
	WHERE  Smoke_Alarm_at_Fire_Origin_Alarm_Failure LIKE 'Not applicable: Alarm operated%'
	GROUP BY Smoke_Alarm_at_Fire_Origin_Alarm_Type) worked

INNER JOIN
-- most failed alarms
	(SELECT Smoke_Alarm_at_Fire_Origin_Alarm_Type, COUNT(Smoke_Alarm_at_Fire_Origin_Alarm_Type) AS alarm_type_count_failed
	FROM fire
	WHERE  Smoke_Alarm_at_Fire_Origin_Alarm_Failure NOT LIKE 'Not applicable: Alarm operated%'
	GROUP BY Smoke_Alarm_at_Fire_Origin_Alarm_Type) failed
	ON worked.Smoke_Alarm_at_Fire_Origin_Alarm_Type = failed.Smoke_Alarm_at_Fire_Origin_Alarm_Type)
SELECT *, (alarm_type_count_worked + alarm_type_count_failed) AS total_alarms
FROM cte_alarms
ORDER BY alarm_type_count_worked DESC

-- results: hardwired alarms are the most robust, while wireless are the least robust


--13. What locations in Toronto need better fire incident service? in which areas the time for the fire team arrival was the 
--longest?

SELECT * FROM fire
-- for Tableau analysis


--14.How long it took for a team to arrive? What are the locations with the longest/shortest fire under control time?

SELECT (TFS_Arrival_Time - TFS_Alarm_Time) AS time_needed_for_arrival
FROM fire

SELECT  MAX(min_diff) AS the_longest_time, 
		MIN(min_diff) AS the_shortest_time, 
		AVG(min_diff) AS the_average_time
FROM (
	SELECT CAST(TFS_Arrival_Time AS TIME) AS time_of_arrival, CAST(TFS_Alarm_Time AS TIME) AS time_of_alarm_starts,
	DATEDIFF(MINUTE, TFS_Alarm_Time, TFS_Arrival_Time) AS min_diff
	FROM fire) DD

-- results:
	-- the longest time is 297 min
	-- the shortest time is 0 min
	-- the average time is 5 min


--15. What materials/rooms ignited resulted in the longest/shortest time to bring it under control? 

SELECT Area_of_Origin, CAST(TFS_Alarm_Time AS TIME), CAST(Fire_Under_Control_Time AS TIME),
DATEDIFF(MINUTE, TFS_Alarm_Time, Fire_Under_Control_Time) AS min_diff_fire_under_control
FROM fire
ORDER BY DATEDIFF(MINUTE, TFS_Alarm_Time, Fire_Under_Control_Time) DESC

-- results: trash and other storage area had the highest time to brign fire under control


-- The end...










