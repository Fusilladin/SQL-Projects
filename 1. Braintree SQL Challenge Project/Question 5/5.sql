--5. Find the SUM of gpd_per_capita 
--	by year 
--	and the COUNT of countries 
--	for each year that have non-null gdp_per_capita 
--	where (i) the year is before 2012 
--	and (ii) the country has a null gdp_per_capita in 2012. 
	
--Your result should have the columns:

--    year
--    country_count
--    total

--Had to create 2 CTEs for aggr functions and then combine them to be able to get the yearly sum of gdp per capita per year. First had to get the list of countries that where NULL in 2012  using a CASE function and then once I got that list I had to exclude countries that had NULLs throughout the selected years. Then in the last part of the statement I can GORUP BY year and find the COUNT of countries in each year as well as the SUM of gdp in each year for that list of countries
WITH CTE_Countries AS (
SELECT * 
FROM per_capita
WHERE(
	CASE
		WHEN [year] = 2012 AND gdp_per_capita = 0
		THEN 'yes'
		ELSE 'no'
	END
	) = 'yes'
)
, CTE_Count AS (
SELECT
	 g.[year]
	,CASE
		WHEN g.gdp_per_capita = 0
		THEN NULL
		ELSE g.country_code
	 END AS 'coun' 
	,g.gdp_per_capita
FROM CTE_Countries AS c
INNER JOIN per_capita AS g
ON g.[country_code] = c.[country_code]
WHERE g.country_code = c.country_code
AND g.[year] <  2012
)

SELECT cnt.[year] AS 'Year'
	,COUNT(cnt.coun) 'Count'
	,FORMAT(SUM(cnt.gdp_per_capita),'$###,###.00') AS 'Yearly GDP'
FROM CTE_Countries AS c
INNER JOIN CTE_Count AS cnt
ON c.country_code = cnt.coun
GROUP BY cnt.[year]
