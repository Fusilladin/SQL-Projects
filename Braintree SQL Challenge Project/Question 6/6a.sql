--6. All in a single query, execute all of the steps below and provide the results as your final answer:

--a) create a single list of all per_capita records for year 2009 that includes columns:
--    continent_name
--    country_code
--    country_name
--    gdp_per_capita

--Just got to join the tables, select the correct columns, and do the correct WHERE clause
SELECT con.continent_name
	,c.country_code
	,c.country_name
	,FORMAT(g.gdp_per_capita,'$###,###.00') AS 'Total GDP'
FROM per_capita AS g
INNER JOIN countries AS c
ON c.country_code = g.country_code
INNER JOIN continent_map AS m
ON m.country_code = c.country_code
INNER JOIN continents AS con
ON con.continent_code = m.continent_code
WHERE g.[year] = 2009