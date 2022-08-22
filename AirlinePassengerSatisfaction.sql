/*
Project: Maven Airline Customer Satisfaction Analysis and EDA
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
Date: 2022-06-02
*/

---Before Uploading---
--Used Excel to clean for spelling, number range disrepencies and NULLS. Also used to change column names to be more usable in SQL (i.e. added underscores, shortened them)

/*
Setting Up
Let's bring up the data and clean it for analysis
*/
--Bring up data set
SELECT *
FROM PortfolioProject.dbo.PassengerSatisfaction 

--Will check again for NULLS

SELECT *
FROM PortfolioProject.dbo.PassengerSatisfaction 
WHERE ID IS NULL
	OR Gender IS NULL
	OR AGE IS NULL 
	OR [Customer Type] IS NULL 
	OR Travel_Type IS NULL 
	OR Class IS NULL 
	OR Flight_Distance IS NULL 
	OR Departure_Delay IS NULL 
	OR Arrival_Delay IS NULL
	OR Departure_and_Arrival_Time_Convenience IS NULL 
	OR Online_Booking_Ease IS NULL 
	OR CheckIn_Service IS NULL 
	OR Online_Boarding IS NULL 
	OR Gate_Location IS NULL 
	OR Onboard_Service IS NULL 
	OR Seat_Comfort IS NULL 
	OR [Leg_Room Service] IS NULL 
	OR Cleanliness IS NULL 
	OR Food_Drink IS NULL 
	OR InFlight_Service IS NULL 
	OR InFlight_Wifi IS NULL 
	OR InFlight_Entertainment IS NULL 
	OR Baggage_Handling IS NULL 
	OR Satisfaction IS NULL 

UPDATE PortfolioProject..PassengerSatisfaction
SET Arrival_Delay = 0 
WHERE Arrival_Delay IS NULL 

--Making sure scores are between 0-5 and no errors in other information 
SELECT *
FROM PortfolioProject.dbo.PassengerSatisfaction 
WHERE Departure_and_Arrival_Time_Convenience NOT BETWEEN 0 AND 5
	OR Online_Booking_Ease NOT BETWEEN 0 AND 5
	OR CheckIn_Service NOT BETWEEN 0 AND 5
	OR Online_Boarding NOT BETWEEN 0 AND 5
	OR Gate_Location NOT BETWEEN 0 AND 5
	OR Onboard_Service NOT BETWEEN 0 AND 5
	OR Seat_Comfort NOT BETWEEN 0 AND 5
	OR [Leg_Room Service] NOT BETWEEN 0 AND 5
	OR Cleanliness NOT BETWEEN 0 AND 5 
	OR Food_Drink NOT BETWEEN 0 AND 5 
	OR InFlight_Service NOT BETWEEN 0 AND 5
	OR InFlight_Wifi NOT BETWEEN 0 AND 5 
	OR InFlight_Entertainment NOT BETWEEN 0 AND 5 
	OR Baggage_Handling NOT BETWEEN 0 AND 5
	OR Gender NOT IN ('Female', 'Male')
	OR [Customer Type] NOT IN ('Returning', 'First-time')
	OR Travel_Type NOT IN ('Personal', 'Business')
	OR Class NOT IN ('Economy', 'Economy Plus', 'Business')
	OR Satisfaction NOT IN ('Satisfied', 'Neutral or Dissatisfied')
	
--Checking for duplicates 
SELECT ID, 
	COUNT(*)
FROM PortfolioProject..PassengerSatisfaction
GROUP BY ID
HAVING COUNT(*) > 1

--Add column where overall satisfaction score is boolean
--1 = satisfied 
--0 = unsatisfied 
ALTER TABLE PortfolioProject..PassengerSatisfaction
ADD overall_satisfaction INT NULL; --add column

UPDATE PortfolioProject..PassengerSatisfaction
SET overall_satisfaction = 0 
WHERE Satisfaction = 'Neutral or Dissatisfied' 
UPDATE PortfolioProject..PassengerSatisfaction
SET overall_satisfaction = 1 
WHERE Satisfaction = 'Satisfied' 
--Checking to make sure table was updated properly 
SELECT overall_satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE overall_satisfaction IS NULL 



/* 
Passenger Demographics
Let's see who's flying with the airline so we know who to target
*/

--Gender
--No sig. diff
SELECT 
	Gender, 
	COUNT(*) AS gender_count, 
	COUNT(*) *100 / sum(COUNT(*)) OVER() AS percent_gender
FROM PortfolioProject..PassengerSatisfaction
GROUP BY Gender

--Age distribution and percentage
--but this gives me rows instead of one column
SELECT 
	COUNT(CASE WHEN Age BETWEEN 0 AND 18 THEN Age END) AS child, --child (0-18)
	COUNT(CASE WHEN Age BETWEEN 19 AND 25 THEN Age END) AS young_adult,
	COUNT(CASE WHEN Age BETWEEN 26 AND 40 THEN Age END) AS mid_adult,
	COUNT(CASE WHEN Age BETWEEN 41 AND 65 THEN Age END) AS late_adult,
	COUNT(CASE WHEN AGE > 66 THEN Age END) AS senior,
	COUNT(*) AS total
FROM PortfolioProject..PassengerSatisfaction
--This gives me columns 
SELECT 
	(CASE
	WHEN Age BETWEEN 0 AND 18 THEN 'child'
	WHEN Age BETWEEN 19 AND 25 THEN 'young_adult'
	WHEN AGE BETWEEN 26 AND 40 THEN 'mid_adult'
	WHEN Age BETWEEN 41 AND 65 THEN 'late_adult'
	WHEN AGE >= 66 THEN 'senior'
	else 'unknown' --use this to check if anything falls out of the assigned buckets/age groups
	end ) AS age_group,
	COUNT(*) AS num_count
FROM PortfolioProject..PassengerSatisfaction
GROUP BY (CASE
	WHEN Age BETWEEN 0 AND 18 THEN 'child'
	WHEN Age BETWEEN 19 AND 25 THEN 'young_adult'
	WHEN AGE BETWEEN 26 AND 40 THEN 'mid_adult'
	WHEN Age BETWEEN 41 AND 65 THEN 'late_adult'
	WHEN AGE >= 66 THEN 'senior'
	else 'unknown' --use this to check if anything falls out of the assigned buckets/age groups
	end )

--Lets find percentages of age group
	--Will use a CTE for this
	--44% are 41-65 and 30% are 26-40 
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


--Customer type 
--81% are returning customers with only 18% being first-timers 
SELECT 
	[Customer Type], 
	COUNT(*) AS customerType_count, 
	COUNT(*) *100 / sum(COUNT(*)) OVER() AS percent_type
FROM PortfolioProject..PassengerSatisfaction
GROUP BY [Customer Type]

--Purpose of flight 
--69% are travelling for business 
SELECT 
	Travel_Type, 
	COUNT(*) AS Travel_Type_count, 
	COUNT(*) *100 / sum(COUNT(*)) OVER() AS percent_Travel_Type
FROM PortfolioProject..PassengerSatisfaction
GROUP BY Travel_Type

--Class used 
--47% used Business class and 44% used economy 
SELECT 
	Class, 
	COUNT(*) AS Class_count, 
	COUNT(*) *100 / sum(COUNT(*)) OVER() AS percent_Class
FROM PortfolioProject..PassengerSatisfaction
GROUP BY Class

--Average age, distance, delays
--Looks like avg. distance travelled is short (under 1500 miles) 
SELECT	
	AVG(Age) AS avg_age,
	AVG(Flight_Distance) AS avg_distance, 
	AVG(Departure_Delay) AS avg_departdelay,
	AVG(Arrival_Delay) AS avg_arrivedelay
FROM PortfolioProject.dbo.PassengerSatisfaction 

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


--Table with column identifying distance group 
SELECT *,
	(CASE
	WHEN Flight_Distance BETWEEN 0 AND 1200 THEN 'under_1200'
	WHEN Flight_Distance >1200 THEN 'over 1200'
	ELSE 'unknown'
	end ) AS distance_group
	--COUNT(*) AS num_count
	FROM PortfolioProject..PassengerSatisfaction


/* 
Overview of Ratings for Each Category
Let's see which categoroies are highly and lowly rated
*/

--Average satisfaction scores 
--this does not address that some answers are 0 for 'not applicable'
SELECT	
	AVG(Departure_and_Arrival_Time_Convenience) AS avg_Departure_and_Arrival_Time_Convenience,
	AVG(Online_Booking_Ease) AS avg_Online_Booking_Ease,
	AVG(CheckIn_Service) AS avg_CheckIn_Service,
	AVG(Online_Boarding) AS avg_Online_Boarding,
	AVG(Gate_Location) AS avg_Gate_Location,
	AVG(Onboard_Service) AS avg_Onboard_Service,
	AVG(Seat_Comfort) AS avg_Seat_Comfort,
	AVG([Leg_Room Service]) AS avg_legRoom,
	AVG(Cleanliness) AS avg_Cleanliness,
	AVG(Food_Drink) AS avg_Food_Drink,
	AVG(InFlight_Service) AS avg_InFlight_Service,
	AVG(InFlight_Wifi) AS avg_InFlight_Wifi,
	AVG(InFlight_Entertainment) AS avg_InFlight_Entertainment,
	AVG(Baggage_Handling) AS avg_Baggage_Handling
FROM PortfolioProject.dbo.PassengerSatisfaction 

--AVG when accounting for the zeros and not including in average 
--Will turn all '0' to NULL which doesn't get included in AVG calc
--All ratings are around 3 which is pretty neutral 
--worst 3 (avg. <3): Online_Booking_Ease, Gate_Location, InFlight_Wifi
SELECT	
	AVG(NULLIF(Departure_and_Arrival_Time_Convenience,0)) AS avg_Departure_and_Arrival_Time_Convenience,
	AVG(NULLIF(Online_Booking_Ease,0)) AS avg_Online_Booking_Ease,
	AVG(NULLIF(CheckIn_Service,0)) AS avg_CheckIn_Service,
	AVG(NULLIF(Online_Boarding,0)) AS avg_Online_Boarding,
	AVG(NULLIF(Gate_Location,0)) AS avg_Gate_Location,
	AVG(NULLIF(Onboard_Service,0)) AS avg_Onboard_Service,
	AVG(NULLIF(Seat_Comfort,0)) AS avg_Seat_Comfort,
	AVG(NULLIF([Leg_Room Service],0)) AS avg_legRoom,
	AVG(NULLIF(Cleanliness,0)) AS avg_Cleanliness,
	AVG(NULLIF(Food_Drink,0)) AS avg_Food_Drink,
	AVG(NULLIF(InFlight_Service,0)) AS avg_InFlight_Service,
	AVG(NULLIF(InFlight_Wifi,0)) AS avg_InFlight_Wifi,
	AVG(NULLIF(InFlight_Entertainment,0)) AS avg_InFlight_Entertainment,
	AVG(NULLIF(Baggage_Handling,0)) AS avg_Baggage_Handling
FROM PortfolioProject.dbo.PassengerSatisfaction 

--Lets see how much of each rating there was per category 
--will make sure to have '<>0' so calcualtions don't consider zero values which indicate non-applicable 


--47% satisfied 
SELECT 
	Departure_and_Arrival_Time_Convenience, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Departure_and_Arrival_Time_Convenience
FROM PortfolioProject..PassengerSatisfaction
WHERE Departure_and_Arrival_Time_Convenience <> 0 
GROUP BY Departure_and_Arrival_Time_Convenience
ORDER BY Departure_and_Arrival_Time_Convenience 

--41% unsatisfied 
SELECT 
	Online_Booking_Ease, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_onlineBooking
FROM PortfolioProject..PassengerSatisfaction
WHERE Online_Booking_Ease <> 0 
GROUP BY Online_Booking_Ease
ORDER BY Online_Booking_Ease 

--46% satisfied 
SELECT 
	CheckIn_Service, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_CheckIn_Service
FROM PortfolioProject..PassengerSatisfaction
WHERE CheckIn_Service <> 0 
GROUP BY CheckIn_Service
ORDER BY CheckIn_Service 

--50% satisfied 
SELECT 
	Online_Boarding, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Online_Boarding
FROM PortfolioProject..PassengerSatisfaction
WHERE Online_Boarding <> 0 
GROUP BY Online_Boarding
ORDER BY Online_Boarding 

--34% unsatisfied, 36% satisfied --> pretty evenly distributed 
SELECT 
	Gate_Location, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Gate_Location
FROM PortfolioProject..PassengerSatisfaction
WHERE Gate_Location <> 0 
GROUP BY Gate_Location
ORDER BY Gate_Location 

--51% satisfied 
SELECT 
	Onboard_Service, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Onboard_Service
FROM PortfolioProject..PassengerSatisfaction
WHERE Onboard_Service <> 0 
GROUP BY Onboard_Service
ORDER BY Onboard_Service 

--55% satisfied 
SELECT 
	Seat_Comfort, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Seat_Comfort
FROM PortfolioProject..PassengerSatisfaction
WHERE Seat_Comfort <> 0 
GROUP BY Seat_Comfort
ORDER BY Seat_Comfort 

--50% satisfied 
SELECT 
	[Leg_Room Service], 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_legroom
FROM PortfolioProject..PassengerSatisfaction
WHERE [Leg_Room Service] <> 0 
GROUP BY [Leg_Room Service]
ORDER BY [Leg_Room Service] 

--47% satisfied 
SELECT 
	Cleanliness, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Cleanliness
FROM PortfolioProject..PassengerSatisfaction
WHERE Cleanliness <> 0 
GROUP BY Cleanliness
ORDER BY Cleanliness 

--44% satisfied, 33% unsatisfied 
SELECT 
	Food_Drink, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Food_Drink
FROM PortfolioProject..PassengerSatisfaction
WHERE Food_Drink <> 0 
GROUP BY Food_Drink
ORDER BY Food_Drink 

--62% satisfied 
SELECT 
	InFlight_Service, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_InFlight_Service
FROM PortfolioProject..PassengerSatisfaction
WHERE InFlight_Service <> 0 
GROUP BY InFlight_Service
ORDER BY InFlight_Service 

--30% satisifed, 42% unsatisfied 
SELECT 
	InFlight_Wifi, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_InFlight_Wifi
FROM PortfolioProject..PassengerSatisfaction
WHERE InFlight_Wifi <> 0 
GROUP BY InFlight_Wifi
ORDER BY InFlight_Wifi 

--42% satisfied 
SELECT 
	InFlight_Entertainment, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_InFlight_Entertainment
FROM PortfolioProject..PassengerSatisfaction
WHERE InFlight_Entertainment <> 0 
GROUP BY InFlight_Entertainment
ORDER BY InFlight_Entertainment 

--62% satisfied 
SELECT 
	Baggage_Handling, 
	COUNT(*) AS counts,
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Baggage_Handling
FROM PortfolioProject..PassengerSatisfaction
WHERE Baggage_Handling <> 0 
GROUP BY Baggage_Handling
ORDER BY Baggage_Handling 



/*
Overall Satisfaction Rating
*/
--43% satisfied, 56% neutral or dissatisfied 
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
GROUP BY Satisfaction



/* 
Exploring Correlations with ratings and demographics
SELECT (Avg(x * y) – (Avg(x) * Avg(y))) / (StDevP(x) * StDevP(y)) AS ‘correlation’
*/
--Does Departure delay impact satisfaction?
--no.
SELECT 
(Avg(Departure_Delay * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(Departure_Delay) * Avg((cast(overall_satisfaction as decimal(10,4)))))) / (StDevP(Departure_Delay) * StDevP((cast(overall_satisfaction as decimal(10,4)))))  AS PearsonCoefficient,
(Avg(Departure_Delay * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(Departure_Delay) * Avg((cast(overall_satisfaction as decimal(10,4)))))) as numerator,
(StDevP(Departure_Delay) * StDevP((cast(overall_satisfaction as decimal(10,4)))))  as denominator
FROM PortfolioProject..PassengerSatisfaction 

--Does Arrival delay impact satifcation? 
--no
SELECT 
(Avg(Arrival_Delay * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(Arrival_Delay) * Avg((cast(overall_satisfaction as decimal(10,4)))))) / (StDevP(Arrival_Delay) * StDevP((cast(overall_satisfaction as decimal(10,4)))))  AS PearsonCoefficient,
(Avg(Arrival_Delay * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(Arrival_Delay) * Avg((cast(overall_satisfaction as decimal(10,4)))))) as numerator,
(StDevP(Arrival_Delay) * StDevP((cast(overall_satisfaction as decimal(10,4)))))  as denominator
FROM PortfolioProject..PassengerSatisfaction

--Does flight distance impact satisfaction?
--r = 0.29
SELECT 
(Avg(Flight_Distance * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(Flight_Distance) * Avg((cast(overall_satisfaction as decimal(10,4)))))) / (StDevP(Flight_Distance) * StDevP((cast(overall_satisfaction as decimal(10,4)))))  AS PearsonCoefficient,
(Avg(Flight_Distance * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(Flight_Distance) * Avg((cast(overall_satisfaction as decimal(10,4)))))) as numerator,
(StDevP(Flight_Distance) * StDevP((cast(overall_satisfaction as decimal(10,4)))))  as denominator
FROM PortfolioProject..PassengerSatisfaction



--Correlation between overall satisfaction and lowest 3 rating categories 
--1. online booking ease 
--r =0.24
SELECT 
(Avg(Online_Booking_Ease * (cast(overall_satisfaction as decimal(10,4))) ) - (Avg(Online_Booking_Ease) * Avg(cast(overall_satisfaction as decimal(10,4))))) / (StDevP(Online_Booking_Ease) * StDevP(cast(overall_satisfaction as decimal(10,4))))  AS PearsonCoefficient,
(Avg(Online_Booking_Ease * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(Online_Booking_Ease) * Avg(cast(overall_satisfaction as decimal(10,4))))) as numerator,
(StDevP(Online_Booking_Ease) * StDevP(cast(overall_satisfaction as decimal(10,4))))  as denominator
FROM PortfolioProject..PassengerSatisfaction
WHERE Online_Booking_Ease <> 0 --making sure non-applicable entries are not included 
--2.gate location
--no
SELECT 
(Avg(Gate_Location * (cast(overall_satisfaction as decimal(10,4))) ) - (Avg(Gate_Location) * Avg(cast(overall_satisfaction as decimal(10,4))))) / (StDevP(Gate_Location) * StDevP(cast(overall_satisfaction as decimal(10,4))))  AS PearsonCoefficient,
(Avg(Gate_Location * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(Gate_Location) * Avg(cast(overall_satisfaction as decimal(10,4))))) as numerator,
(StDevP(Gate_Location) * StDevP(cast(overall_satisfaction as decimal(10,4))))  as denominator
FROM PortfolioProject..PassengerSatisfaction
WHERE Gate_Location <> 0 --making sure non-applicable entries are not included 
--3. inflight wifi
--r=.39 = relatively strong
SELECT 
(Avg(InFlight_Wifi * (cast(overall_satisfaction as decimal(10,4))) ) - (Avg(InFlight_Wifi) * Avg(cast(overall_satisfaction as decimal(10,4))))) / (StDevP(InFlight_Wifi) * StDevP(cast(overall_satisfaction as decimal(10,4))))  AS PearsonCoefficient,
(Avg(InFlight_Wifi * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(InFlight_Wifi) * Avg(cast(overall_satisfaction as decimal(10,4))))) as numerator,
(StDevP(InFlight_Wifi) * StDevP(cast(overall_satisfaction as decimal(10,4))))  as denominator
FROM PortfolioProject..PassengerSatisfaction
WHERE InFlight_Wifi <> 0 --making sure non-applicable entries are not included 

--Any correlation between demographics and satisfaction scores?
--Age --nope
SELECT 
(Avg(Age * (cast(overall_satisfaction as decimal(10,4))) ) - (Avg(Age) * Avg(cast(overall_satisfaction as decimal(10,4))))) / (StDevP(Age) * StDevP(cast(overall_satisfaction as decimal(10,4))))  AS PearsonCoefficient,
(Avg(Age * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(Age) * Avg(cast(overall_satisfaction as decimal(10,4))))) as numerator,
(StDevP(Age) * StDevP(cast(overall_satisfaction as decimal(10,4))))  as denominator
FROM PortfolioProject..PassengerSatisfaction

--Satisfaction and customer type
--first timers are not that satisfied 
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE [Customer Type] = 'Returning'
GROUP BY Satisfaction
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE [Customer Type] = 'First-time'
GROUP BY Satisfaction

--Satisfaction and travel type 
--Personal travellers are really not satisfied 
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Travel_Type = 'Business'
GROUP BY Satisfaction

SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Travel_Type = 'Personal'
GROUP BY Satisfaction

--Satisfaction and class
--economy not satisfied  while buisness class is 
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Class = 'Economy'
GROUP BY Satisfaction

SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Class = 'Business'
GROUP BY Satisfaction

SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Class = 'Economy Plus'
GROUP BY Satisfaction


--Satisfaction and distance travelled
SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Flight_Distance<1200
GROUP BY Satisfaction

SELECT 
	Satisfaction, 
	COUNT(*) AS Satisfaction_count, 
	COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percent_Satisfaction
FROM PortfolioProject..PassengerSatisfaction
WHERE Flight_Distance>1200
GROUP BY Satisfaction

/*
Avg. satisfaction scores across categories by demographics
*/
--This will not consider any entries that entered 0 (non-applicable) for any of the categories 

DROP TABLE if exists avg_ratings_table
CREATE TABLE avg_ratings_table(
	ID numeric, 
	Gender nvarchar (255), 
	Age int, 
	[Customer Type] nvarchar (255), 
	Travel_Type nvarchar (255), 
	Class nvarchar (255), 
	Flight_Distance int, 
	Departure_Delay int, 
	Arrival_Delay int, 
	overall_satisfaction int, 
	Departure_and_Arrival_Time_Convenience int, 
	Online_Booking_Ease int, 
	CheckIn_Service int, 
	Online_Boarding int, 
	Gate_Location int, 
	Onboard_Service int, 
	Seat_Comfort int, 
	[Leg_Room Service] int, 
	Cleanliness int, 
	Food_Drink int, 
	InFlight_Service int, 
	InFlight_Wifi int, 
	InFlight_Entertainment int, 
	Baggage_Handling int,
	avg_rating decimal(10,4)
)

INSERT INTO avg_ratings_table
SELECT ID, Gender, Age, [Customer Type], Travel_Type, Class, Flight_Distance, Departure_Delay, Arrival_Delay, overall_satisfaction, Departure_and_Arrival_Time_Convenience, Online_Booking_Ease, CheckIn_Service, Online_Boarding, Gate_Location, Onboard_Service, Seat_Comfort, [Leg_Room Service], Cleanliness, Food_Drink, InFlight_Service, InFlight_Wifi, InFlight_Entertainment, Baggage_Handling,
	avg_rating = (Departure_and_Arrival_Time_Convenience +Online_Booking_Ease+CheckIn_Service +Online_Boarding+Gate_Location+ Onboard_Service + Seat_Comfort + [Leg_Room Service]+ Cleanliness +Food_Drink +InFlight_Service +InFlight_Wifi +InFlight_Entertainment + Baggage_Handling)/14
FROM PortfolioProject.dbo.PassengerSatisfaction 
WHERE Departure_and_Arrival_Time_Convenience <>0 and Online_Booking_Ease <>0 and CheckIn_Service <>0 and Online_Boarding <> 0 and Gate_Location <>0 and Onboard_Service <>0
	and Seat_Comfort <> 0 and [Leg_Room Service] <>0 and Cleanliness<> 0 and Food_Drink <>0 and InFlight_Service<>0 and InFlight_Wifi <>0 and InFlight_Entertainment <>0
	and Baggage_Handling <>0
GROUP BY ID, Gender, Age, [Customer Type], Travel_Type, Class, Flight_Distance, Departure_Delay, Arrival_Delay, overall_satisfaction, Departure_and_Arrival_Time_Convenience, Online_Booking_Ease, CheckIn_Service, Online_Boarding, Gate_Location, Onboard_Service, Seat_Comfort, [Leg_Room Service], Cleanliness, Food_Drink, InFlight_Service, InFlight_Wifi, InFlight_Entertainment, Baggage_Handling
ORDER BY avg_rating

SELECT *
FROM avg_ratings_table

/* 
Exploring Correlations with avg. category ratings 
SELECT (Avg(x * y) – (Avg(x) * Avg(y))) / (StDevP(x) * StDevP(y)) AS ‘correlation’
*/
--general demographics, worst 3 rated categories, best rated category
SELECT 
(Avg(avg_rating * (cast(overall_satisfaction as decimal(10,4)))) - (Avg(avg_rating) * Avg((cast(overall_satisfaction as decimal(10,4)))))) / (StDevP(avg_rating) * StDevP((cast(overall_satisfaction as decimal(10,4)))))  AS overall_satisfaction,
(Avg(Age * avg_rating) - (Avg(Age) * Avg(avg_rating))) / (StDevP(Age) * StDevP(avg_rating))  AS Age,
(Avg(Departure_Delay * avg_rating) - (Avg(Departure_Delay) * Avg(avg_rating))) / (StDevP(Departure_Delay) * StDevP(avg_rating))  AS Departure_Delay,
(Avg(Arrival_Delay * avg_rating) - (Avg(Arrival_Delay) * Avg(avg_rating))) / (StDevP(Arrival_Delay) * StDevP(avg_rating))  AS Arrival_Delay, 
(Avg(Flight_Distance * avg_rating) - (Avg(Flight_Distance) * Avg(avg_rating))) / (StDevP(Flight_Distance) * StDevP(avg_rating))  AS Flight_Distance,
(Avg((cast(Online_Booking_Ease AS decimal)) * avg_rating) - (Avg((cast(Online_Booking_Ease AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Online_Booking_Ease AS decimal))) * StDevP(avg_rating))  AS Online_Booking_Ease,
(Avg((cast(Gate_Location AS decimal)) * avg_rating) - (Avg((cast(Gate_Location AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Gate_Location AS decimal))) * StDevP(avg_rating))  AS Gate_Location,
(Avg((cast(InFlight_Wifi AS decimal)) * avg_rating) - (Avg((cast(InFlight_Wifi AS decimal))) * Avg(avg_rating))) / (StDevP((cast(InFlight_Wifi AS decimal))) * StDevP(avg_rating))  AS InFlight_Wifi,
(Avg((cast(InFlight_Service AS decimal)) * avg_rating) - (Avg((cast(InFlight_Service AS decimal))) * Avg(avg_rating))) / (StDevP((cast(InFlight_Service AS decimal))) * StDevP(avg_rating))  AS InFlight_Service,
(Avg((cast(Food_Drink AS decimal)) * avg_rating) - (Avg((cast(Food_Drink AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Food_Drink AS decimal))) * StDevP(avg_rating))  AS Food_Drink,
(Avg((cast(Departure_and_Arrival_Time_Convenience AS decimal)) * avg_rating) - (Avg((cast(Departure_and_Arrival_Time_Convenience AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Departure_and_Arrival_Time_Convenience AS decimal))) * StDevP(avg_rating))  AS Departure_and_Arrival_Time_Convenience,
(Avg((cast(Food_Drink AS decimal)) * avg_rating) - (Avg((cast(Food_Drink AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Food_Drink AS decimal))) * StDevP(avg_rating))  AS Food_Drink,
(Avg((cast(CheckIn_Service AS decimal)) * avg_rating) - (Avg((cast(CheckIn_Service AS decimal))) * Avg(avg_rating))) / (StDevP((cast(CheckIn_Service AS decimal))) * StDevP(avg_rating))  AS CheckIn_Service,
(Avg((cast(Online_Boarding AS decimal)) * avg_rating) - (Avg((cast(Online_Boarding AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Online_Boarding AS decimal))) * StDevP(avg_rating))  AS Online_Boarding,
(Avg((cast(Onboard_Service AS decimal)) * avg_rating) - (Avg((cast(Onboard_Service AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Onboard_Service AS decimal))) * StDevP(avg_rating))  AS Onboard_Service,
(Avg((cast(Seat_Comfort AS decimal)) * avg_rating) - (Avg((cast(Seat_Comfort AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Seat_Comfort AS decimal))) * StDevP(avg_rating))  AS Seat_Comfort,
(Avg((cast([Leg_Room Service] AS decimal)) * avg_rating) - (Avg((cast([Leg_Room Service] AS decimal))) * Avg(avg_rating))) / (StDevP((cast([Leg_Room Service] AS decimal))) * StDevP(avg_rating))  AS [Leg_Room Service],
(Avg((cast(Cleanliness AS decimal)) * avg_rating) - (Avg((cast(Cleanliness AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Cleanliness AS decimal))) * StDevP(avg_rating))  AS Cleanliness,
(Avg((cast(InFlight_Entertainment AS decimal)) * avg_rating) - (Avg((cast(InFlight_Entertainment AS decimal))) * Avg(avg_rating))) / (StDevP((cast(InFlight_Entertainment AS decimal))) * StDevP(avg_rating))  AS InFlight_Entertainment,
(Avg((cast(Baggage_Handling AS decimal)) * avg_rating) - (Avg((cast(Baggage_Handling AS decimal))) * Avg(avg_rating))) / (StDevP((cast(Baggage_Handling AS decimal))) * StDevP(avg_rating))  AS Baggage_Handling
FROM avg_ratings_table 


--Satisfaction and customer type
--no diff. - around 3
SELECT 
	[Customer Type],
	AVG(avg_rating) AS avg_rating
FROM avg_ratings_table
GROUP BY [Customer Type]

--Satisfaction and travel type 
--no diff. - around 3
SELECT 
	Travel_Type,
	AVG(avg_rating) AS avg_rating
FROM avg_ratings_table
GROUP BY Travel_Type

--Satisfaction and class
--all around 3
SELECT 
	Class,
	AVG(avg_rating) AS avg_rating
FROM avg_ratings_table
GROUP BY Class

/*
RANDOM
*/
SELECT *
FROM PortfolioProject..PassengerSatisfaction
WHERE Class = 'Business'


SELECT ID, Gender, Age, 
	[Customer Type], Travel_Type, Class, Flight_Distance, Departure_Delay, Arrival_Delay, overall_satisfaction, Departure_and_Arrival_Time_Convenience, Online_Booking_Ease, CheckIn_Service, Online_Boarding, Gate_Location, Onboard_Service, Seat_Comfort, [Leg_Room Service], Cleanliness, Food_Drink, InFlight_Service, InFlight_Wifi, InFlight_Entertainment, Baggage_Handling,
	avg_rating = (Departure_and_Arrival_Time_Convenience +Online_Booking_Ease+CheckIn_Service +Online_Boarding+Gate_Location+ Onboard_Service + Seat_Comfort + [Leg_Room Service]+ Cleanliness +Food_Drink +InFlight_Service +InFlight_Wifi +InFlight_Entertainment + Baggage_Handling)/14
FROM PortfolioProject.dbo.PassengerSatisfaction 
GROUP BY ID, Gender, Age, [Customer Type], Travel_Type, Class, Flight_Distance, Departure_Delay, Arrival_Delay, overall_satisfaction, Departure_and_Arrival_Time_Convenience, Online_Booking_Ease, CheckIn_Service, Online_Boarding, Gate_Location, Onboard_Service, Seat_Comfort, [Leg_Room Service], Cleanliness, Food_Drink, InFlight_Service, InFlight_Wifi, InFlight_Entertainment, Baggage_Handling
ORDER BY avg_rating

/*
Insights for Improvement
*/

