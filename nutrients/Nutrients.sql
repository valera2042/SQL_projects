


-- Plan for the analysis
-- 1. Get general info about products for each nutrition factor
-- 2. Get the healthiest products across all nutrition factors
-- 3. Get the set of products recommended for people with diabetes
-- 4. Get the set of products recommended for people with heart problems
-- 5. Get the set of products recommended for people with osteoporosis
-- 6. Get the set of products recommended for people with high cholesterol level


-- start using database
USE Nutrition
GO

SELECT * FROM nutrients

-- rename wrongly named column
SP_RENAME 'nutrients.irom','iron'



-- 1. Get general info about products for each nutrition factor

-- get foods that are rich in proteins
SELECT TOP 10 name
FROM nutrients
ORDER BY protein DESC
-- results: scrambled eggs, tofu, pork, etc..


-- get foods that are rich in polysaturated fat
SELECT TOP 10 name 
FROM nutrients
ORDER BY polyunsaturated_fatty_acids DESC
-- results: nuts, suflower seeds, peanuts etc..


-- select foods with the lowest rank for the salt, saturated_fats, cholesterol and sugars
WITH cte_healthy_food as
	(SELECT name, DENSE_RANK() OVER(ORDER BY saturated_fat) as the_least_saturated_fat, 
	DENSE_RANK() OVER(ORDER BY cholesterol) as the_least_cholesterol, 
	DENSE_RANK() OVER(ORDER BY sodium) as the_least_sodium, 
	DENSE_RANK() OVER(ORDER BY sugars) as the_least_sugars 
	FROM nutrients)
SELECT name FROM cte_healthy_food
WHERE the_least_saturated_fat = 1 AND the_least_cholesterol = 1 AND the_least_sodium = 1 AND the_least_sugars = 1
-- results: cod fish, roasted turkey, fat-free beef, row pollock, etc..


-- foods with the highest total amount of vitamins
SELECT TOP 10 name
FROM nutrients
ORDER BY (vitamin_b12 + vitamin_b6 + vitamin_c + vitamin_d + vitamin_e + vitamin_k + tocopherol_alpha) DESC
-- results: mollusks, beef, lamb, herring fish


-- foods with the highest total amount of minerals
SELECT TOP 10 name
FROM nutrients
ORDER BY (iron + copper + calcium + magnesiuM + manganese + phosphorous + potassium + selenium + zink) DESC
-- results: dried tofu, dried peppers, cowpeas mature seeds, fish


-- it looks like the fish is very rich in nutrients and minerals. Lets find the most nutricious fish in the table
-- store temp data in a view
CREATE VIEW healthy_fish_table AS
(
SELECT *, 
	--create a colum with the clean sodium level
	CAST(CAST(RTRIM(REPLACE(sodium, 'mg', '')) AS NUMERIC) AS INT) AS sodium_level, 
	--create a colum with the clean fat level
	CAST(CAST(RTRIM(REPLACE(saturated_fat, 'g', '')) AS NUMERIC) AS INT) AS saturated_fat_level,
	--create a colum with the clean polysaturated_fat level
	CAST(CAST(RTRIM(REPLACE(polyunsaturated_fatty_acids, 'g', '')) AS NUMERIC) AS INT) AS unsaturated_fat_level,
	--create a colum with the clean calcium level
	CAST(CAST(RTRIM(REPLACE(calcium, 'mg', '')) AS NUMERIC) AS INT) AS calcium_level,
	--create a colum with the clean magnesium level
	CAST(CAST(RTRIM(REPLACE(magnesium, 'mg', '')) AS NUMERIC) AS INT) AS magnesium_level,
	--create a colum with the clean phosphorous level
	CAST(CAST(RTRIM(REPLACE(phosphorous, 'mg', '')) AS NUMERIC) AS INT) AS phosphorous_level
FROM nutrients
WHERE (name LIKE 'Fish%') OR (name LIKE '%fish%')
AND sodium LIKE '%mg' )


SELECT name FROM
	(SELECT name, sodium_level, saturated_fat_level, unsaturated_fat_level, calcium_level, magnesium_level, phosphorous_level,
	--create a colum with the clean sodium level
	DENSE_RANK() OVER(ORDER BY sodium_level) as sodium_level_rank, 
	--create a colum with saturated fat level
	DENSE_RANK() OVER(ORDER BY saturated_fat_level) as saturated_fat_rank,
	--create a colum with unsaturated fat level
	DENSE_RANK() OVER(ORDER BY unsaturated_fat_level) as unsaturated_fat_rank, 
	--create a colum with clean calcium level
	DENSE_RANK() OVER(ORDER BY calcium_level) as calcium_rank,
	--create a colum with the clean magnesium level
	DENSE_RANK() OVER(ORDER BY magnesium_level) as magnesium_rank
FROM healthy_fish_table) DD
WHERE sodium_level_rank IN (1,2,3) AND saturated_fat_rank IN (1,2,3) AND  unsaturated_fat_rank IN (1,2,3) AND
calcium_rank IN (1,2,3) AND magnesium_rank IN (1,2,3)

--results:  1. raw cod fish, 
--			2. fermented salmon
--	        3. raw pollock


-- 2. Get the healthiest products across all nutrition factors

SELECT * FROM nutrients

-- lets assign the rating to each product based on the total amount of nutrients: 
-- maximum of vitamins/minerals and min of calories/fat/salt
SELECT name, calories, saturated_fat, sodium,
(vitamin_b12 + vitamin_b6 + vitamin_c + vitamin_d + vitamin_e + vitamin_k + tocopherol_alpha) AS sum_vitamins,
(iron + copper + calcium + magnesiuM + manganese + phosphorous + potassium + selenium + zink) AS sum_minerals
FROM nutrients


CREATE VIEW cleaned_nutrients AS
(
SELECT *, 
	-- macronutrients/fat, create a colum with the clean fat level
	CAST(CAST(RTRIM(REPLACE(saturated_fat, 'g', '')) AS NUMERIC) AS INT) AS saturated_fat_level,

	-- minerals
	--create a colum with the clean sodium level
	CAST(CAST(RTRIM(REPLACE(sodium, 'mg', '')) AS NUMERIC) AS INT) AS sodium_level, 
	--create a colum with the clean calcium level
	CAST(CAST(RTRIM(REPLACE(calcium, 'mg', '')) AS NUMERIC) AS INT) AS calcium_level,
	--create a colum with the clean magnesium level
	CAST(CAST(RTRIM(REPLACE(magnesium, 'mg', '')) AS NUMERIC) AS INT) AS magnesium_level,
	--create a colum with the clean phosphorous level
	CAST(CAST(RTRIM(REPLACE(phosphorous, 'mg', '')) AS NUMERIC) AS INT) AS phosphorous_level,
	--create a colum with the clean potassium level
	CAST(CAST(RTRIM(REPLACE(potassium, 'mg', '')) AS NUMERIC) AS INT) AS potassium_level,
	--create a colum with the clean selenium level
	CAST(CAST(RTRIM(REPLACE(selenium, 'mcg', '')) AS NUMERIC) AS INT) AS selenium_level,
	--create a colum with the clean copper level
	CAST(CAST(RTRIM(REPLACE(copper, 'mg', '')) AS NUMERIC) AS INT) AS copper_level,
	--create a colum with the clean zink level
	CAST(CAST(RTRIM(REPLACE(zink, 'mg', '')) AS NUMERIC) AS INT) AS zink_level,
	--create a colum with the clean polysaturated_fat level

	-- vitamins
	--create a colum with the clean folate level
	CAST(CAST(RTRIM(REPLACE(folate, 'mcg', '')) AS NUMERIC) AS INT) AS folate_level,
	--create a colum with the clean niacin level
	CAST(CAST(RTRIM(REPLACE(niacin, 'mg', '')) AS NUMERIC) AS INT) AS niacin_level,
	--create a colum with the clean vitamin_b level
	CAST(CAST(RTRIM(REPLACE(riboflavin, 'mg', '')) AS NUMERIC) AS INT) AS vitamin_b_level,
	--create a colum with the clean thiamin level
	CAST(CAST(RTRIM(REPLACE(thiamin, 'mg', '')) AS NUMERIC) AS INT) AS thiamin_level,
	--create a colum with the clean vitamin_a level
	CAST(CAST(RTRIM(REPLACE(vitamin_a_rae, 'mcg', '')) AS NUMERIC) AS INT) AS vitamin_a_level,
	--create a colum with the clean vitamin_b6 level
	CAST(CAST(RTRIM(REPLACE(vitamin_b6, 'mg', '')) AS NUMERIC) AS INT) AS vitamin_b6_level,
	--create a colum with the clean vitamin_c level
	CAST(CAST(RTRIM(REPLACE(vitamin_c, 'mg', '')) AS NUMERIC) AS INT) AS vitamin_c_level,
	--create a colum with the clean vitamin_e level
	CAST(CAST(RTRIM(REPLACE(vitamin_e, 'mg', '')) AS NUMERIC) AS INT) AS vitamin_e_level,
	--create a colum with the clean vitamin_k level
	CAST(CAST(RTRIM(REPLACE(vitamin_k, 'mcg', '')) AS NUMERIC) AS INT) AS vitamin_k_level
FROM nutrients)

SELECT TOP 20 name, 
	DENSE_RANK() OVER(ORDER BY calories) AS calories_rank, 
	DENSE_RANK() OVER(ORDER BY saturated_fat_level) AS saturated_fat_level_rank, 
	DENSE_RANK() OVER(ORDER BY sodium_level) AS sodium_level_rank,
	DENSE_RANK() OVER(ORDER BY(folate_level + niacin_level + vitamin_b_level + thiamin_level + vitamin_a_level +
								vitamin_b6_level + vitamin_c_level + vitamin_e_level + vitamin_k_level) DESC) AS vitamins_level_rank,
	DENSE_RANK() OVER(ORDER BY(calcium_level + magnesium_level + phosphorous_level + potassium_level +
								selenium_level + zink_level) DESC) AS minerals_level_rank
FROM cleaned_nutrients
-- results: some dried food, seeds, celery flakes, chives



-- 3. Get the set of products for people with diabetes
-- For peoplw with diabetes it is crucial to avoid foods with too much flucose, it is desirable to have as much as 
-- possible raw foods with max 'long' carbohydrates like starxh, so in this case we will find foods with min of 
-- glucose and max of carbohydrates, also the cut off of 75 g/100 g will be applied to ensure the wheat products on the top

SELECT name
FROM
	(SELECT name, carbohydrate, glucose, 
	CAST(CAST(RTRIM(REPLACE(carbohydrate, 'g', '')) AS NUMERIC) AS INT)- CAST(CAST(RTRIM(REPLACE(sugars, 'g', '')) 
	AS NUMERIC) AS INT) AS long_carbohydrates 
	FROM cleaned_nutrients) GG
WHERE long_carbohydrates < 75
ORDER BY long_carbohydrates DESC, glucose ASC
--results: corn, wheat grains, cereals, pancakesm, potato unprepared



-- 4. Get the set of products for people with heart problems
-- the following minerals are crucial for the normal heart functioning: potassium and magnesium
-- fiber is of a great importance as well

SELECT name, (potassium_rank + magnesium_rank + fiber_rank) AS total_rank
FROM
(
SELECT name,
	--create a colum with the clean polysaturated_fat level
	DENSE_RANK() OVER(ORDER BY (CAST(CAST(RTRIM(REPLACE(potassium, 'mg', '')) AS NUMERIC) AS INT)) DESC) AS potassium_rank,
	DENSE_RANK() OVER(ORDER BY (CAST(CAST(RTRIM(REPLACE(magnesium, 'mg', '')) AS NUMERIC) AS INT)) DESC) AS magnesium_rank, 
	DENSE_RANK() OVER(ORDER BY (CAST(CAST(RTRIM(REPLACE(fiber, 'g', '')) AS NUMERIC) AS INT)) DESC) AS fiber_rank
FROM cleaned_nutrients) FF
ORDER BY (potassium_rank + magnesium_rank + fiber_rank) ASC
-- results: crude corn bran, dried fungi, wheat crude bran, seed_weed dried?


-- 5. Get the set of products for people with osteoporosis
-- people with osteoporosis need the highest amount of calcium, phosporous and proteins


SELECT name, (protein_rank + calcium_rank + phosphorous_rank) AS total_rank
FROM
(
SELECT name,
	--create a colum with the clean polysaturated_fat level
	DENSE_RANK() OVER(ORDER BY (CAST(CAST(RTRIM(REPLACE(protein, 'g', '')) AS NUMERIC) AS INT)) DESC) AS protein_rank,
	DENSE_RANK() OVER(ORDER BY (CAST(CAST(RTRIM(REPLACE(calcium, 'mg', '')) AS NUMERIC) AS INT)) DESC) AS calcium_rank, 
	DENSE_RANK() OVER(ORDER BY (CAST(CAST(RTRIM(REPLACE(phosphorous, 'mg', '')) AS NUMERIC) AS INT)) DESC) AS phosphorous_rank
FROM cleaned_nutrients) FF
ORDER BY (protein_rank + calcium_rank + phosphorous_rank) ASC
--results: parmesan cheese, milk, etc..



-- 6. Get the set of products for people with high cholesterol level
-- for those with high scholesterol level it is crucial to consume a lot of fibers and the least amounts of cholesterol

SELECT name, (cholesterol_rank + calcium_rank) AS total_rank
FROM
(
SELECT name,
	--create a colum with the clean polysaturated_fat level
	DENSE_RANK() OVER(ORDER BY (CAST(CAST(RTRIM(REPLACE(cholesterol, 'mg', '')) AS NUMERIC) AS INT)) ASC) AS cholesterol_rank,
	DENSE_RANK() OVER(ORDER BY (CAST(CAST(RTRIM(REPLACE(calcium, 'mg', '')) AS NUMERIC) AS INT)) DESC) AS calcium_rank
FROM cleaned_nutrients) FF
ORDER BY (cholesterol_rank + calcium_rank) ASC
--results: tofu, cereals_ready_to_eat


