/*
Tables for Survey Analysis 
*/


----General Demographics of Respondents---
--Table 1. Age Demographic 
WITH age_data AS (
	SELECT 
	(CASE
	WHEN Age BETWEEN 0 AND 18 THEN '0-18'
	WHEN Age BETWEEN 19 AND 25 THEN '19-25'
	WHEN AGE BETWEEN 26 AND 40 THEN '26-40'
	WHEN Age BETWEEN 41 AND 65 THEN '41-65'
	WHEN AGE >= 66 THEN '66+'
	end ) AS age_group,
	COUNT(*) AS num_count
	FROM PortfolioProject..PassengerSatisfaction
	GROUP BY (CASE WHEN Age BETWEEN 0 AND 18 THEN '0-18' WHEN Age BETWEEN 19 AND 25 THEN '19-25' WHEN AGE BETWEEN 26 AND 40 THEN '26-40' WHEN Age BETWEEN 41 AND 65 THEN '41-65' WHEN AGE >= 66 THEN '66+' end )
)

SELECT *,
	num_count*100/(SUM(num_count) OVER()) AS percent_group --OVER clause modfies scope of SUM to be for the entire coloumn, not grouped by age_group
	--SUM(num_count) OVER() AS total_count --OVER clause modfies scope of SUM to be for the entire coloumn, not grouped by age_group
FROM age_data
GROUP BY age_group, num_count
ORDER BY age_group

--Table 2. Demographic: Class Used 
--47% used Business class and 44% used economy 
SELECT 
	Class, 
	COUNT(*) AS Class_count, 
	COUNT(*) *100 / sum(COUNT(*)) OVER() AS percent_Class
FROM PortfolioProject..PassengerSatisfaction
GROUP BY Class


--Table 4. Distance travelled
--Considerations for long vs. short flights 
--64% of tavelling was under 1200 miles (1200 is the average flight distance) 
WITH distance_data AS (
	SELECT 
	(CASE
	WHEN Flight_Distance BETWEEN 0 AND 1200 THEN 'under_1200'
	WHEN Flight_Distance >1200 THEN 'over 1200'
	ELSE 'unknown'
	end ) AS distance_group,
	COUNT(*) AS num_count
	FROM PortfolioProject..PassengerSatisfaction
	GROUP BY (CASE WHEN Flight_Distance BETWEEN 0 AND 1200 THEN 'under_1200' WHEN Flight_Distance >1200 THEN 'over 1200'	ELSE 'unknown' end )
)

SELECT *,
	num_count*100/(SUM(num_count) OVER()) AS percent_group --OVER clause modfies scope of SUM to be for the entire coloumn, not grouped by age_group
	--SUM(num_count) OVER() AS total_count --OVER clause modfies scope of SUM to be for the entire coloumn, not grouped by age_group
	--AVG(Flight_Distance) AS avg_distance
FROM distance_data
GROUP BY distance_group, num_count
ORDER BY distance_group


--Table 5. Overall Satisfaction 
--43% satisfied, 56% neutral or dissatisfied 
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
GROUP BY Satisfaction

---Table 6. 
----The Unhappiest Respondents----
--Satisfaction and class
--economy not satisfied  while buisness class is 
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Class = 'Economy'
GROUP BY Satisfaction
--Short flights
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Flight_Distance<1200
GROUP BY Satisfaction
--personal travel 
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Travel_Type = 'Personal'
GROUP BY Satisfaction