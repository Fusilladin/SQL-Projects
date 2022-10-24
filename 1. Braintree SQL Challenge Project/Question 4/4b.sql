--4b. Repeat question 4a, but this time make the query 
--	case sensitive.

--Just need to change the WHERE/AND statement to this to do a case sensitive search. Fairly simple.
AND [coun].[country_name] COLLATE Latin1_General_CS_AS LIKE '%an%'