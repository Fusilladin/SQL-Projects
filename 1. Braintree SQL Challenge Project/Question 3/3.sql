--3. For the year 2012, create a 3 column, 1 row report showing the percent share of gdp_per_capita for the following regions:
--	United Arab Emirates
--	Switzerland
--	Algeria
--	Germany

--First find the country codes
SELECT * 
FROM countries
WHERE country_name in ('United Arab Emirates'
	,'Switzerland'
	,'Algeria'
	,'Germany'
	)
/*
ARE
CHE
DEU
DZA
*/

--Then had to make 2 seperate CTE's to contain to aggr SUM functions of the total and regional total to then put them together in a mathematicals equation in the last part of the query and SELECT TOP 1 so that only 1 row shows up becuase every row was the same anyway.
WITH CTE_Total AS (
SELECT
	 [year]
	,SUM(gdp_per_capita) AS 'Total'
FROM per_capita
WHERE year = 2012
GROUP BY year
)

,CTE_Aggr AS (
SELECT
	 SUM(g.gdp_per_capita) AS 'Regional Total'
	,g.[year]
FROM CTE_Total
INNER JOIN per_capita AS g
ON g.[year] = CTE_Total.[year]
WHERE g.country_code in (
						 'ARE'
						,'CHE'
						,'DEU'
						,'DZA'
						)
AND g.[year] = 2012
GROUP BY g.[year]
)

SELECT TOP 1
	 FORMAT(t.Total,'$###,###.00') AS 'Total'
	,FORMAT(a.[Regional Total],'$###,###.00') AS 'Regional Total'
	,FORMAT((a.[Regional Total]/t.total),'##.00%') 'Regional % of Total'
FROM CTE_Total AS t
INNER JOIN CTE_Aggr AS a
ON a.[year] = t.[year]
INNER JOIN per_capita AS g
ON g.[year] = a.[year]


