--7. Find the country 
--	with the highest AVG gdp_per_capita 
--	for each continent 
--	for all years.

--Used 2 CTEs again. First used one to create the avg gdp quantity then the next one to create the partitioned rank column and then selected all of that in an ordered list by continent name DESC where rank was 1 
WITH CTE_gdp AS (
SELECT	 con.continent_name
		,c.country_name
		,SUM(g.[gdp_per_capita]) / 9 AS 'gdp'
FROM per_capita AS g
INNER JOIN countries AS c
ON c.country_code = g.country_code
INNER JOIN continent_map AS m
ON m.country_code = c.country_code
INNER JOIN continents AS con
ON con.continent_code = m.continent_code
GROUP BY c.country_name
		,con.continent_name
		)
,CTE_Rank AS (
SELECT *
	,ROW_NUMBER() OVER(
		PARTITION BY g.continent_name
		ORDER BY g.gdp DESC) AS 'Rank'
FROM CTE_gdp AS g
		)
SELECT
			 r.continent_name
			,r.country_name
			,FORMAT(r.gdp,'$###,###.00') AS avg_gdp
FROM CTE_Rank AS r
INNER JOIN CTE_gdp AS g
ON g.country_name = r.country_name
WHERE r.[rank] = 1
ORDER BY r.continent_name
		,r.gdp DESC