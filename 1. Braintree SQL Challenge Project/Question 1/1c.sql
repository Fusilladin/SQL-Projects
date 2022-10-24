--c) For all countries that have multiple rows in the continent_map table, delete all multiple records leaving only the 1 record per country. The record that you keep should be the first one when sorted by the continent_code alphabetically ascending. 

--c) First checked all the records with more than 1 record:
SELECT [country_code]
	,COUNT([country_code]) AS Quantity
FROM [continent_map]
GROUP BY [country_code]
HAVING COUNT(country_code) > 1

--then copy pasted those records into another query to find all of the country codes listed in alphabetical order by their continent codes:
SELECT [country_code]	
	,[continent_code]
FROM [continent_map]
WHERE [country_code] IN (
		'ARM','AZE','CYP','FOO','GEO','KAZ','RUS','TUR','UMI'
		)
ORDER BY [country_code]
	,[continent_code]

--Next was to Delete the additional records so I had to Partition them by the number of country_codes then order them by continent:
WITH countryCTE AS 
(
	SELECT *, ROW_NUMBER() OVER(Partition BY [country_code] ORDER BY [country_code],[continent_code]) AS RowNumber
	FROM continent_map
)
SELECT * FROM countryCTE

--Then delete anything with RowNumber greater than 1:
WITH countryCTE AS 
(
	SELECT *, ROW_NUMBER() OVER(Partition BY [country_code] ORDER BY [country_code],[continent_code]) AS RowNumber
	FROM continent_map
)
DELETE FROM countryCTE WHERE RowNumber > 1

--Then I go back up and SELECT the country_codes listed and they come up only once. 
