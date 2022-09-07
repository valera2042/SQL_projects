USE DS
GO

SELECT * FROM salaries

-- Plan for analysis

-- 1. Find the best positions in European Union with the highest salary
-- 2. Does salary depends on the company size? how? Give some examples
-- 3. Does salary depends on the experience level, how? Give some examples
-- 4. Order roles in Great Britain by the remote option
-- 5. What is the lowest and the higest salary for each of the experience level group?
-- 6. Does employee residence Japan has any impact on the average salary in each year?
-- 7. How large the difference in salaries for each of the employment type listed?
-- 8. Company located in which european country has the largest difference between the lowest and the highest salary?
-- 9. What are the roles that become more trendy/less trendy?
-- 10. What currency has changed more during these three years according to the DS payments?
-- 11. The best country to work as Data Analyst (all professions in data analytics field)
-- 12. Do data scientists working remotely earn more than those that work in the office in US?
-- 13. What is the differences in salary for Data Scientists jobs working in small, middle, and large companies in India 



SELECT * FROM salaries
-- 1. Find the best positions in European Union with the highest salary

WITH Salary_cte AS
	(SELECT job_title, DENSE_RANK() OVER(PARTITION BY job_title ORDER BY salary DESC) AS rank_salary, salary
	FROM salaries
	WHERE salary_currency = 'EUR')
SELECT * FROM Salary_cte
WHERE rank_salary = 1
ORDER BY salary

-- results: various data engineering jobs. Not data scientists or analyst


-- 2. Does salary in US depends on the company size? how? Give some examples

-- there are 3 types of companies grouped by size: largest, middle and smallest
SELECT DISTINCT company_size FROM salaries
SELECT company_size, MIN(salary) AS Min_salary, MAX(salary) AS Max_salary
FROM salaries
WHERE company_location = 'US'
GROUP BY company_size

-- results: 
-- max salary of the middle and small companies are relatively the same, 
-- while the large company has TWO ORDERS of magnitude higher salary
-- min salary of the middle and small companies are relatively the same, 
-- while the large company has TWO TIMES higher salary


-- 3. Does salary depends on the experience level, how? Give some examples

SELECT experience_level, AVG(salary) AS average_salary
FROM salaries
GROUP BY experience_level

-- results: entrance level accounts for around 200 k$, middle and executive are about two time higher.


-- 4. Order roles in Great Britain by the remote option

SELECT DISTINCT job_title, salary
FROM salaries
WHERE company_location = 'GB' AND remote_ratio > 0
ORDER BY salary DESC

-- results: Big data engineer, data engineer, etc..


-- 5. What is the lowest and the higest salary for each of the experience level group the largest difference in US?

SELECT experience_level, MIN(salary) AS min_salary, MAX(salary) AS max_salary,
MAX(salary) - MIN(salary) AS salary_difference
FROM salaries
WHERE company_location = 'US'
GROUP BY experience_level
HAVING MAX(salary) - MIN(salary) > 500000

-- results: middle and senior have the largest salary difference among other experience categories


-- 6. Does employee residence in Japan and India has any impact on the average salary in each year?

SELECT work_year, employee_residence, ROUND(AVG(salary), 2) AS average_salary
FROM salaries
WHERE employee_residence = 'JP' OR employee_residence = 'IN'
GROUP BY work_year, employee_residence

-- results: 
-- 1. In 2022 in India there has been a salary increase by 2 times for all DS roles comparing to 2020
-- 2. In 2022 in Japan there has been much less drastic salary increase of 80-90%  during the same time period
-- Overall, salaries have increased dramarically comparing to the inflation rate and other professions


-- 7. How large the difference in salaries for each of the employment type listed?

SELECT employment_type, MIN(salary) AS min_salary, MAX(salary) AS max_salary, MIN(salary) - MAX(salary) AS salary_difference
FROM salaries
GROUP BY employment_type

--results: as expected the largest salary difference was observed for the full time employment across all ds roles


-- 8. Company located in which european country has the largest difference between the lowest and the highest salary?

SELECT TOP 10 company_location, MIN(salary) AS min_salary, 
MAX(salary) AS max_salary, MAX(salary) - MIN(salary) AS salary_difference
FROM salaries
WHERE salary_currency = 'EUR'
GROUP BY company_location
ORDER BY MAX(salary) - MIN(salary) DESC

-- results: Germany, Spain, Switzerland, France are the countrues with the largest difference across the min/max ds salaries


-- 9. What are the roles that become more trendy/less trendy?

-- most popular ds jobs
SELECT * FROM salaries
SELECT job_title
FROM
(SELECT job_title, COUNT(*) AS Total_count_of_a_role, DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank_count
FROM salaries
GROUP BY work_year, job_title) gg
WHERE rank_count IN (1,2,3)
-- results: Data Engineer, Data Scientist, Data Analyst

-- the least popular jobs
SELECT job_title
FROM
(SELECT job_title, COUNT(*) AS Total_count_of_a_role, DENSE_RANK() OVER(ORDER BY COUNT(*) ASC) AS rank_count
FROM salaries
GROUP BY work_year, job_title) gg
WHERE rank_count IN (1,2,3)
-- results: 3D Computer vision researcher, AI Scientist, BI Data Analyst



-- 10. What roles have the highest jump in payments in Europe during three years 2020 - 2022?

SELECT work_year, job_title
FROM
	(SELECT work_year, job_title, MIN(salary) AS min_salary, MAX(salary) AS max_salary, 
	MAX(salary) - MIN(salary) AS salary_difference, 
	DENSE_RANK() OVER(PARTITION BY work_year ORDER BY (MAX(salary) - MIN(salary)) DESC ) AS salary_year_rank
	FROM salaries
	WHERE salary_currency = 'EUR'
	GROUP BY work_year, job_title) hh
WHERE salary_year_rank = 1
-- ORDER BY work_year DESC, MAX(salary) - MIN(salary) DESC

-- results: 
-- 1. In 2020 the Data Scientist job had the highest payjump
-- 2. In 2021 the Machine Learning Engineer job had the highest payjump
-- 3. In 2022 the Data Engineer job had the highest payjump


-- 11. The best European country to work as Analyst (all professions in data analytics field)

SELECT company_location, MAX(salary) AS max_salary
FROM salaries
WHERE salary_currency = 'EUR' AND (job_title LIKE '%Analyst%' OR job_title LIKE 'Analyst%' OR job_title LIKE '%analyst%')
GROUP BY company_location
HAVING MAX(salary) > 50000

-- results: Germany and Danemark provided data scientists with the highest salaries


-- 12. Do data scientists working remotely earn more than those that work in the office in US?

SELECT AVG(salary) AS average_salary
FROM salaries
WHERE company_location = 'US' AND remote_ratio > 0 AND job_title = 'Data Scientist'

UNION ALL

SELECT AVG(salary) AS average_salary
FROM salaries
WHERE company_location = 'US' AND remote_ratio = 0 AND job_title = 'Data Scientist'

-- results: Data Scientists who work remotely earn by 12 k$ more than those who work all the time in the office


-- 13. Differences in salary for Data Scientists jobs working in small, middle, and large companies in India 

SELECT company_size, ROUND(AVG(salary),1) AS average_salary
FROM salaries
WHERE company_location = 'INR' AND company_size = 'L' AND job_title = 'Data Scientist'
GROUP BY company_size

UNION ALL

SELECT company_size, ROUND(AVG(salary),1) AS average_salary
FROM salaries
WHERE company_location = 'INR' AND company_size = 'M' AND job_title = 'Data Scientist'
GROUP BY company_size

UNION ALL

SELECT company_size, ROUND(AVG(salary),1) AS average_salary
FROM salaries
WHERE company_location = 'INR' AND company_size = 'S' AND job_title = 'Data Scientist'
GROUP BY company_size

-- results: 
-- 1. large size companies provide data scientists with 2 times more than middle size companies 
-- and 2.5 times more than small size companies

SELECT * FROM salaries