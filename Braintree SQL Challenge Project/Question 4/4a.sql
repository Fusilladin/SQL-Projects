--4a. What is the COUNT of countries and 
--	SUM of their related gdp_per_capita values for the 
--	year 2007 
--	where the string 'an' (case insensitive) 
--	appears anywhere in the country name?
WITH CTE_GDP AS (
SELECT 
	COUNT(country_name) AS 'Num'
	,[year]
	,ROUND(SUM(cap.gdp_per_capita),2) AS 'GDP' 
FROM per_capita AS cap
INNER JOIN countries as coun
ON coun.country_code = cap.country_code 
WHERE [year] = 2007
AND [coun].[country_name] LIKE '%an%'
GROUP BY [year]
)
SELECT 
	 [Num] As 'Num Countries With "AN"'
	,[year] AS 'Year'
	,FORMAT([GDP],'$#,###,###.##') AS 'Total GDP'
FROM CTE_GDP




