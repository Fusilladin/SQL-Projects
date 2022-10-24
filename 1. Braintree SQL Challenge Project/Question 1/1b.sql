--b) Display any values where country_code is null as country_code = "FOO" and make this row appear first in the list


--b) To find all of the NULL country_code values i did:
SELECT  [country_code]
      ,[continent_code]
	FROM [Braintree].[dbo].[continent_map]
	WHERE country_code = ''

--Then to change them from NULL to 'FOO' I did:
--UPDATE [continent_map]
SET [country_code] = 'FOO'
--SELECT [country_code]  
	FROM [Braintree].[dbo].[continent_map]
	WHERE country_code = ''

--I highlighted the UPDATE statement through to the WHERE to update the table then selected the SELECT statement to see my updates
--SELECT [country_code] 
	FROM [Braintree].[dbo].[continent_map]
	WHERE country_code = '' -- 'FOO'

--Then to make the FOO columns come up first I added a [key] column 
ALTER TABLE [continent_map]
ADD [key] INT

--and numbered the FOO columns 1-4:
DECLARE @n1 INT
SET @n1 = 0
UPDATE [continent_map]
SET [key] = @n1
	,@n1 = @n1 + 1
--SELECT * FROM [continent_map]
WHERE country_code = 'FOO'

--Then to number the rest of the rows I did 
DECLARE @n1 INT
SET @n1 = 4
UPDATE [continent_map]
SET [key] = @n1
	,@n1 = @n1 + 1
--SELECT * FROM [continent_map]
--ORDER BY [key]
WHERE country_code != 'FOO'

--And checked the list after using the ORDER BY statement to pull the 'FOO' country_codes first and then the rest of the records.