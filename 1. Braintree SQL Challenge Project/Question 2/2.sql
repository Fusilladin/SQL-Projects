--02. List the countries ranked 10-12 in each continent 
	--by the percent of year-over-year growth 
	--descending 
	--from 2011 to 2012.

--The percent of growth should be calculated as:
--	 ((2012 gdp - 2011 gdp) / 2011 gdp)
--The list should include the columns:
--    rank
--    continent_name
--    country_code
--    country_name
--    growth_percent

--First step is going through my object explorer and looking for which tables have all of the columns I need.
--It appears I need to join all 4 tables together to get every column needed:
SELECT [coun].[country_name]	
	,[con].[continent_name]
	,[cap].[year]
	,[cap].[gdp_per_capita]
FROM [dbo].[continents] AS con
INNER JOIN  [dbo].[continent_map] AS map
ON [con].[continent_code] = map.continent_code
INNER JOIN [dbo].[countries] AS coun
ON [coun].[country_code] = [map].[country_code]
INNER JOIN [dbo].[per_capita] AS cap
ON [cap].[country_code] = [coun].[country_code]

--Next is to pull just those years necessary with a WHERE clause
WHERE [cap].[year] IN (2011,2012)

--When trying to do mathematical calculations I realized that I need to change my column datatypes so:
ALTER TABLE [per_capita]
ALTER column [year] INT

ALTER TABLE [per_capita]
ALTER column [gdp_per_capita] FLOAT

--For this next part I used the CASE statement as well as jopining 2 CTEs together, CASTing datatypes and doing multiple joins and well as partitioning and aggregate functions. There are multiple ways to accomplish this such as using a self join or temporary table, but this is the approach I took

WITH CTE_Capita AS (
SELECT country_code
,SUM(CASE
	WHEN [year] = 2011 THEN gdp_per_capita
	ELSE 0
END) AS '2011'
,SUM(CASE
	WHEN [year] = 2012 THEN gdp_per_capita
	ELSE 0
END) AS '2012'
FROM per_capita
WHERE [year] IN (2011,2012)
GROUP BY [country_code]
)
,CTE_Aggr AS (
SELECT  [coun].[country_name]
	,[cont].[continent_name]
	,[cte].[country_code] 
	,CASE
		WHEN 2011 = 0
		THEN 0
		WHEN 2011 != 0
		THEN ROUND(([2012] - [2011]) / [2011],2)
		ELSE 0
	END AS Total
	,ROW_NUMBER() OVER(
		Partition BY [cont].[continent_name] 
		ORDER BY 
				CASE
					WHEN 2011 = 0
					THEN 0
					WHEN 2011 != 0
					THEN ([2012] - [2011]) / [2011]
					ELSE 0
				END 
		) AS 'Rank'
FROM CTE_Capita AS cte
INNER JOIN [countries] AS coun
ON [coun].country_code = cte.country_code
INNER JOIN [continent_map] as map
ON [map].country_code = [coun].country_code
INNER JOIN [continents] AS cont
ON [cont].[continent_code] = [map].[continent_code]
WHERE [2011] != 0
AND [2012] != 0
)
SELECT [continent_name]
	,[country_name]
	,[Rank]
	,CONCAT(CAST([Total] AS NVARCHAR(255)),'%') AS 'YOY Growth'
FROM CTE_Capita AS Cap
INNER JOIN CTE_Aggr AS Aggr
ON Aggr.country_code = cap.country_code
WHERE [Rank] 
BETWEEN 10 AND 12
ORDER BY [continent_name],[Rank]

