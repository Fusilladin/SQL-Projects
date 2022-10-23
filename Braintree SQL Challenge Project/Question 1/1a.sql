--a) Alphabetically list all of the country codes in the continent_map table that appear more than once. 

--a) I did a SELECT TOP 1000 rows to bring up the data and then started adjusting the query. 
--First was to put in a HAVING clause at the end because it is an aggregate column. 
--HAVING COUNT(country_code) > 1. 
--Then since the query wouldn't run just like that I had to change it to:
SELECT  [country_code]
	,COUNT([country_code])
  FROM [Braintree].[dbo].[continent_map]
  GROUP BY [country_code]
  HAVING COUNT(country_code) > 1