--c. create a running total of gdp_per_capita by continent_name

--Creating a cumsum or cumulitive sum / rolling total
--using the SUM() OVER() and ORDER BY clauses to create a cumulitive sum across the continent name
SELECT con.continent_name
	,c.country_code
	,c.country_name
	,FORMAT(g.gdp_per_capita,'$###,###.00') AS 'Total GDP'
	,FORMAT(SUM(g.gdp_per_capita) OVER (
			PARTITION BY con.continent_name
			ORDER BY c.country_name DESC)
			,'$###,###.00') AS 'Running Total'
FROM per_capita AS g
INNER JOIN countries AS c
ON c.country_code = g.country_code
INNER JOIN continent_map AS m
ON m.country_code = c.country_code
INNER JOIN continents AS con
ON con.continent_code = m.continent_code
WHERE g.[year] = 2009
ORDER BY SUBSTRING(con.continent_name,2,3) ASC
	,c.country_name DESC'