--d. return only the first record from the ordered list for which each continent's running total of gdp_per_capita meets or exceeds $70,000.00 with the following columns:
--    continent_name
--    country_code
--    country_name
--    gdp_per_capita
--    running_total

--Had to do 2 CTEs one with the running total, the second with a rank row, and then select the top 6 with rank as 1 to get the correct countries
WITH CTE_CumSum AS (
SELECT con.continent_name
	,c.country_code
	,c.country_name
	,g.gdp_per_capita
	,g.[year]
	,SUM(g.gdp_per_capita) OVER (
			PARTITION BY con.continent_name
			ORDER BY c.country_name DESC) AS 'CumSum'
FROM per_capita AS g
INNER JOIN countries AS c
ON c.country_code = g.country_code
INNER JOIN continent_map AS m
ON m.country_code = c.country_code
INNER JOIN continents AS con
ON con.continent_code = m.continent_code
WHERE g.[year] = 2009

)

,CTE_Rank AS (
SELECT *
	,ROW_NUMBER() OVER(
		PARTITION BY c.continent_name
		ORDER BY c.cumsum) AS 'Rank'
FROM CTE_CumSum AS c
WHERE c.CumSum > 70000
)
SELECT TOP 6 r.continent_name
			,r.country_code
			,r.country_name
			,FORMAT(r.gdp_per_capita,'$###,###.00') AS gdp_per_capita
			,FORMAT(r.CumSum,'$###,###.00') AS running_total
FROM CTE_Rank AS r
INNER JOIN CTE_CumSum AS c
ON c.[year] = r.[year]
WHERE r.rank = 1
ORDER BY SUBSTRING(c.continent_name,2,3) ASC
	,c.country_name DESC
