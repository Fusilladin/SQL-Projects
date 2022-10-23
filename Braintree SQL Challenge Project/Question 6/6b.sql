--b) order this list by:
--continent_name ASC characters 2 through 4 (inclusive) of the country_name DESC

--Just add on a simple ORDER BY statement and parse the continent name using SUBSTRING()
ORDER BY SUBSTRING(con.continent_name,2,3) ASC
	,c.country_name DESC