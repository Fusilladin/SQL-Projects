-- Exmaple Report 
--
-- Variable for the date
DECLARE @startdate date       
SET @startdate = CAST(DATEADD(DAY, -2, GETDATE()) AS DATE);
DECLARE @enddate date
SET @enddate = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);

-- Variable for the time
DECLARE @starttime time
SET @starttime = '07:00:00';
DECLARE @endtime time
SET @endtime = '19:59:59';

-- Variable for Category1: 'A1' 'Category1'
--						   'A2' 'Category1'

-- Variable for Category2: 'A1' 'Category2' 
--						   'A2' 'Category2'

-- Variable for Category3: 'A1' 'Category3'
--						   'A2' 'Category3'

-- Variable for Category4: 'A1' 'Category4'
--						   'A2' 'Category4'

-- Variable for Cateogry5: 'A1' 'Category5'
--						   'A2' 'Category5'

DECLARE @List TABLE (
	ID INT IDENTITY(1,1),
	Item NVARCHAR(50)
);
INSERT INTO @List
VALUES ('Category1'), ('Category2'), 
	('Category3'),('Category4'),('Category5'),
	('Category1'), ('Category2'), 
	('Category3'),('Category4'),('Category5'),;

DECLARE @CurrentID INT = 1;
DECLARE @category NVARCHAR(50);

WHILE @CurrentID <= (SELECT MAX(ID) FROM @List)
BEGIN
DECLARE @subcategory NVARCHAR(50)
SET @category = IIF(@CurrentID >= 6,'A1','A2');
SET @category = (SELECT Item FROM @List WHERE ID = @CurrentID);
SELECT CONCAT(@category,' ',@subcategory) [Category & Subcategory]

DROP TABLE IF EXISTS #Employee
SELECT distinct
[EmployeeId]
,CASE WHEN [EmployeeId] IN ('Name1','Name2','Name3','Name4','Name5','Name6','Name7','Name8','Name9','Name10','Name11','Name12','Name13','Name14','Name15','Name16','Name17','Name18','Name19','Name20','Name21','Name22','Name23','Name24','Name25','Name26','Name27','Name28','Name29','Name30')
				THEN 'Active'
				ELSE 'Inactive' END AS [Employee Status]
,CASE WHEN [EmployeeId] IN ('Name1','Name2','Name3','Name4','Name5','Name6','Name7','Name8','Name9','Name10','Name11','Name12','Name13','Name14','Name15','Name16','Name17','Name18','Name19','Name20','Name21','Name22','Name23','Name24','Name25','Name26','Name27','Name28','Name29','Name30')
				THEN (ROW_NUMBER() OVER(ORDER BY [EmployeeId])+100)
	ELSE (ROW_NUMBER() OVER(ORDER BY [EmployeeId]) + 1000)
	END AS [EmployeeKey]

INTO #Employees
FROM [Table1]
WHERE 1=1
GROUP BY [EmployeeId]
;

DROP TABLE IF EXISTS #StartHour
SELECT DISTINCT	DATEADD(HOUR,DATEDIFF(HOUR,0, [Date]),0) AS [Date1]
,CAST(DATEADD(HOUR,DATEDIFF(HOUR,0, [CallStartTime]),0) AS Time) AS [Hour1]
,CONCAT( DATEADD(HOUR,DATEDIFF(HOUR,0, [Date]),0) 
	,CAST(DATEADD(HOUR,DATEDIFF(HOUR,0, [CallStartTime]),0) AS TIME))
		AS [datekey]

INTO #StartHour
FROM [Table1]
WHERE CAST(DATEADD(HOUR,DATEDIFF(HOUR,0, [CallStartTime]),0) AS Time)
	BETWEEN @starttime AND @endtime
AND DATEADD(HOUR,DATEDIFF(HOUR,0, [Date]),0) 
	BETWEEN @startdate AND @enddate
;

-- Metrics
DROP TABLE IF EXISTS #TempTbl1
SELECT 
s.[date1]
,s.[hour1]
,s.[datekey]
,t.*
,a.[Employee Status]
INTO #TempTbl1 
FROM [Table1] t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(DATEADD(HOUR,DATEDIFF(HOUR,0, [Date]),0) 
	,CAST(DATEADD(HOUR,DATEDIFF(HOUR,0, [CallStartTime]),0) AS TIME))
LEFT JOIN #Employees a on a.[EmployeeId] = t.[EmployeeId] 
WHERE 1=1
	AND t.[direction] = @subcategory
	AND CAST(t.[DateTimeNoNull] AS DATE) BETWEEN @startdate AND @enddate
	AND CAST(t.[CallStartTime] AS TIME)
	BETWEEN @starttime AND @endtime
	AND t.[category] LIKE '%'+@category+'%'

DROP TABLE IF EXISTS #EmployeeCount2
SELECT s.[Date1],s.[hour1],s.datekey
,a.[employee count]
INTO #EmployeeCount2
FROM #StartHour s
LEFT JOIN 
	(SELECT ISNULL(COUNT(Distinct [EmployeeId]),0) AS [employee Count], [datekey] FROM #TempTbl1 c WHERE [Employee Status] = 'Active' GROUP BY [datekey]) AS [a]
	ON s.datekey = a.datekey
ORDER BY s.[datekey] ASC

DROP TABLE IF EXISTS #EmployeeCountDaily
SELECT s.[Date1]
,a.[employee count]
INTO #EmployeeCountDaily
FROM #StartHour s
LEFT JOIN 
	(SELECT ISNULL(COUNT(Distinct [EmployeeId]),0) AS [employee Count], [date1] FROM #TempTbl1 c WHERE [Employee Status] = 'Active' GROUP BY [date1]) AS [a]
	ON s.Date1 = a.Date1
GROUP BY s.[date1],a.[employee count]
ORDER BY s.[date1] ASC

/*
select *
from #Employeecount2
order by datekey

select *
from #StartHour
order by datekey
*/

DROP TABLE IF EXISTS #Metric1
SELECT 
s.[Date1],s.[Hour1],s.[datekey]
,ISNULL(COUNT(*),0) AS [Totals Metric1]
INTO #Metric1
FROM #StartHour s
LEFT JOIN #TempTbl1 c on s.[datekey] = c.[datekey] 
GROUP BY s.[Date1],s.[Hour1],s.[datekey]
ORDER BY [date1],[hour1] ASC


DROP TABLE IF EXISTS #Metric2
SELECT 
s.[Date1],s.[Hour1],s.[datekey]
,ISNULL(COUNT(*),0) AS [Metric2]
INTO #Metric2
FROM #StartHour s
LEFT JOIN #TempTbl1 c on s.[datekey] = c.[datekey] 
WHERE 1=1
AND [EmployeeId] != ''
AND [EmployeeId] IS NOT NULL
GROUP BY s.[Date1],s.[Hour1],s.[datekey]
ORDER BY [date1],[hour1] ASC


DROP TABLE IF EXISTS #Metric2Rate
select 
t.[date1] AS [Date]
,t.[hour1] AS [Time]
,s.[datekey]
,CASE WHEN (SUM(ISNULL(c.[Metric2],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(c.[Metric2],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric2 %]
INTO #Metric2Rate
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
GROUP BY t.[date1],t.[hour1],s.[datekey]

DROP TABLE IF EXISTS #Metric2RateDaily
select 
t.[date1] AS [Date]
,CASE WHEN (SUM(ISNULL(c.[Metric2],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(c.[Metric2],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric2 %]
INTO #Metric2RateDaily
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
GROUP BY t.[date1]


DROP TABLE IF EXISTS #Metric3
SELECT 
[Date1],[Hour1],[datekey]
,ISNULL(COUNT(*),0) AS [Metric 3]
INTO #Metric3
FROM #TempTbl1
WHERE 1=1
AND ([EmployeeId] = ''
OR [EmployeeId] IS NULL)
AND [MetricDuration] <= 30
GROUP BY [Date1],[Hour1],[datekey]
ORDER BY [date1],[hour1] ASC

DROP TABLE IF EXISTS #Metric4
SELECT 
[Date1],[Hour1],[datekey]
,ISNULL(COUNT(*),0) AS [Metric4]
INTO #Metric4
FROM #TempTbl1
WHERE 1=1
AND ([EmployeeId] = ''
OR [EmployeeId] IS NULL)
AND [MetricDuration] >= 31
GROUP BY [Date1],[Hour1],[datekey]
ORDER BY [date1],[hour1] ASC

DROP TABLE IF EXISTS #Metric4Rate
SELECT 
t.[date1] AS [Date]
,t.[hour1] AS [Time]
,s.[datekey]
,CASE WHEN (SUM(ISNULL(la.[Metric4],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(la.[Metric4],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric4Rate]
INTO #Metric4Rate
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric4 la on la.[datekey] = t.[datekey]
GROUP BY t.[date1],t.[hour1],s.[datekey]

DROP TABLE IF EXISTS #Metric4Rate
SELECT 
t.[date1] AS [Date]
,CASE WHEN (SUM(ISNULL(la.[Metric4],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(la.[Metric4],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric4Rate]
INTO #Metric4Rate
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric4 la on la.[datekey] = t.[datekey]
GROUP BY t.[date1]


DROP TABLE IF EXISTS #Metric5
SELECT 
[Date1],[Hour1],[datekey]
,ISNULL(COUNT(*),0) AS [Metric5]
INTO #Metric5
FROM #TempTbl1
WHERE 1=1
AND [TertiaryCategory3] = 'Metric5'
GROUP BY [Date1],[Hour1],[datekey]
ORDER BY [date1],[hour1] ASC

DROP TABLE IF EXISTS #Metric5Rate
SELECT 
t.[date1] AS [Date]
,t.[hour1] AS [Time]
,s.[datekey]
,CASE WHEN (SUM(ISNULL(r.[Metric5],0)) = 0
		OR SUM(ISNULL(t.[Metric2],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(r.[Metric5],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Metric2],0)) AS FLOAT)),0) END AS [Metric5 %]
INTO #Metric5Rate
from #Metric2 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric5 r on r.[datekey] = t.[datekey]
GROUP BY t.[date1],t.[hour1],s.[datekey]

DROP TABLE IF EXISTS #Metric5RateDaily
SELECT 
t.[date1] AS [Date]
,CASE WHEN (SUM(ISNULL(r.[Metric5],0)) = 0
		OR SUM(ISNULL(t.[Metric2],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(r.[Metric5],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Metric2],0)) AS FLOAT)),0) END AS [Metric5 %]
INTO #Metric5RateDaily
from #Metric2 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric5 r on r.[datekey] = t.[datekey]
GROUP BY t.[date1]


DROP TABLE IF EXISTS #Metric6
SELECT
[Date1],[Hour1],[datekey]
,ISNULL(COUNT(*),0) AS [Metric6]
INTO #Metric6
FROM #TempTbl1
WHERE 1=1
AND [TertiaryCategory2] = 'Metric6'
GROUP BY [Date1],[Hour1],[datekey]
ORDER BY [date1],[hour1] ASC

DROP TABLE IF EXISTS #Metric6Rate
SELECT 
t.[date1] AS [Date]
,t.[hour1] AS [Time]
,s.[datekey]
,CASE WHEN (SUM(ISNULL(t.[Metric6],0)) = 0
		OR SUM(ISNULL(r.[Metric5],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(t.[Metric6],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(r.[Metric5],0)) AS FLOAT)),0) END AS [Metric6 %]
INTO #Metric6Rate
from #Metric6 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric5 r on r.[datekey] = t.[datekey]
GROUP BY t.[date1],t.[hour1],s.[datekey]

DROP TABLE IF EXISTS #Metric6RateDaily
SELECT 
t.[date1] AS [Date]
,CASE WHEN (SUM(ISNULL(t.[Metric6],0)) = 0
		OR SUM(ISNULL(r.[Metric5],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(t.[Metric6],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(r.[Metric5],0)) AS FLOAT)),0) END AS [Metric6 %]
INTO #Metric6RateDaily
from #Metric6 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric5 r on r.[datekey] = t.[datekey]
GROUP BY t.[date1]

DROP TABLE IF EXISTS #TotalMetric7Time
SELECT 
t.[Date1],t.[Hour1],t.[datekey]
,ISNULL(a.tmd,0) AS [Total Metric7 Duration Value] 
,CASE WHEN SUM(ISNULL(CAST([TotalMetric7Duration] AS INT),0)) = 0 THEN ' 00:00:00 '
	ELSE CONCAT(' ',CAST(FORMAT((SUM(CAST(ISNULL(CAST([TotalMetric7Duration] AS INT),0) AS INT)) / 3600), '00') + ':'+
    FORMAT(((SUM(CAST(ISNULL(CAST([TotalMetric7Duration] AS INT),0) AS INT)) % 3600) / 60),'00') + ':' + 
	FORMAT((SUM(CAST(ISNULL(CAST([TotalMetric7Duration] AS INT),0) AS INT)) % 60), '00') AS VARCHAR(10)),' ') END AS [Total Metric7 Duration]
,CASE WHEN (SUM(ISNULL(a.tmd,0)) = 0
		OR SUM(ISNULL(c.[Metric2],0)) = 0) THEN 0
	ELSE CAST(ISNULL((CAST(SUM(ISNULL(a.tmd,0)) AS FLOAT) / CAST(SUM(ISNULL(c.[Metric2],0)) AS FLOAT)),0) AS FLOAT) END AS [Avg Metric7 Duration Value]
INTO #TotalMetric7Time
FROM #TempTbl1 t
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
INNER JOIN (
			SELECT t.[Date1],t.[Hour1],t.[datekey],SUM(ISNULL(CAST([TotalMetric7Duration] AS INT),0)) [tmd] FROM #TempTbl1 t GROUP BY t.[Date1],t.[Hour1],t.[datekey]
		)  a
		ON a.datekey = t.datekey
WHERE 1=1
GROUP BY t.[Date1],t.[Hour1],t.[datekey],a.tmd
ORDER BY t.[date1],t.[hour1] ASC

DROP TABLE IF EXISTS #AvgMetric7Time
SELECT 
t.[Date1],t.[Hour1],t.[datekey]
,CASE WHEN ISNULL([Avg Metric7 Duration Value],0) = 0 THEN ' 00:00:00 '
	ELSE CONCAT(' ',CAST(FORMAT((CAST(ISNULL([Avg Metric7 Duration Value],0) AS INT) / 3600), '00') + ':'+
    FORMAT(((CAST(ISNULL([Avg Metric7 Duration Value],0) AS INT) % 3600) / 60),'00') + ':' + 
	FORMAT((CAST(ISNULL([Avg Metric7 Duration Value],0) AS INT) % 60), '00') AS VARCHAR(10)),' ') END AS [Avg Metric7 Duration]
INTO #AvgMetric7Time
FROM #TempTbl1 t
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #TotalMetric7Time a on a.datekey = t.datekey
GROUP BY t.[Date1],t.[Hour1],t.[datekey],[Avg Metric7 Duration Value]
ORDER BY t.[date1],t.[hour1] ASC

DROP TABLE IF EXISTS #AvgMetric7TimeDaily
SELECT 
t.[Date1]
,CASE WHEN AVG(ISNULL([Avg Metric7 Duration Value],0)) = 0 THEN ' 00:00:00 '
	ELSE CONCAT(' ',CAST(FORMAT((CAST(AVG(ISNULL([Avg Metric7 Duration Value],0)) AS INT) / 3600), '00') + ':'+
    FORMAT(((CAST(AVG(ISNULL([Avg Metric7 Duration Value],0)) AS INT) % 3600) / 60),'00') + ':' + 
	FORMAT((CAST(AVG(ISNULL([Avg Metric7 Duration Value],0)) AS INT) % 60), '00') AS VARCHAR(10)),' ') END AS [Avg Metric7 Duration]
INTO #AvgMetric7TimeDaily
FROM #TempTbl1 t
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #TotalMetric7Time a on a.datekey = t.datekey
GROUP BY t.[Date1]
ORDER BY t.[date1]

DROP TABLE IF EXISTS #TotalMetric8Time
SELECT
t.[Date1],t.[Hour1],t.[datekey]
,ISNULL(a.tmd,0) AS [Total Metric8 Duration Value] 
,CASE WHEN SUM(ISNULL(CAST([TotalMetric8Duration] AS INT),0)) = 0 THEN ' 00:00:00 '
	ELSE CONCAT(' ',CAST(FORMAT((SUM(CAST(ISNULL(CAST([TotalMetric8Duration] AS INT),0) AS INT)) / 3600), '00') + ':'+
    FORMAT(((SUM(CAST(ISNULL(CAST([TotalMetric8Duration]AS INT),0) AS INT)) % 3600) / 60),'00') + ':' + 
	FORMAT((SUM(CAST(ISNULL(CAST([TotalMetric8Duration]AS INT),0) AS INT)) % 60), '00') AS VARCHAR(10)),' ') END AS [Total Metric8 Duration]
,CASE WHEN (SUM(ISNULL(a.tmd,0)) = 0
		OR SUM(ISNULL(c.[Metric2],0)) = 0) THEN 0
	ELSE CAST(ISNULL((CAST(SUM(ISNULL(a.tmd,0)) AS FLOAT) / CAST(SUM(ISNULL(c.[Metric2],0)) AS FLOAT)),0) AS FLOAT) END AS [Avg Metric8 Duration Value]
INTO #TotalMetric8Time
FROM #TempTbl1 t
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
INNER JOIN (
			SELECT t.[Date1],t.[Hour1],t.[datekey],SUM(ISNULL(CAST([TotalMetric8Duration]AS INT),0)) [tmd] FROM #TempTbl1 t GROUP BY t.[Date1],t.[Hour1],t.[datekey]
		)  a
		ON a.datekey = t.datekey
WHERE 1=1
GROUP BY t.[Date1],t.[Hour1],t.[datekey],a.tmd
ORDER BY t.[date1],t.[hour1] ASC

DROP TABLE IF EXISTS #AvgMetric8Time
SELECT 
t.[Date1],t.[Hour1],t.[datekey]
,CASE WHEN ISNULL([Avg Metric8 Duration Value],0) = 0 THEN ' 00:00:00 '
	ELSE CONCAT(' ',CAST(FORMAT((CAST(ISNULL([Avg Metric8 Duration Value],0) AS INT) / 3600), '00') + ':'+
    FORMAT(((CAST(ISNULL([Avg Metric8 Duration Value],0) AS INT) % 3600) / 60),'00') + ':' + 
	FORMAT((CAST(ISNULL([Avg Metric8 Duration Value],0) AS INT) % 60), '00') AS VARCHAR(10)),' ') END AS [Avg Metric8 Duration]
INTO #AvgMetric8Time
FROM #TempTbl1 t
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #TotalMetric8Time a on a.datekey = t.datekey
GROUP BY t.[Date1],t.[Hour1],t.[datekey],[Avg Metric8 Duration Value]
ORDER BY t.[date1],t.[hour1] ASC


DROP TABLE IF EXISTS #AvgMetric8TimeDaily
SELECT 
t.[Date1]
,CASE WHEN AVG(ISNULL([Avg Metric8 Duration Value],0)) = 0 THEN ' 00:00:00 '
	ELSE CONCAT(' ',CAST(FORMAT((CAST(AVG(ISNULL([Avg Metric8 Duration Value],0)) AS INT) / 3600), '00') + ':'+
    FORMAT(((CAST(AVG(ISNULL([Avg Metric8 Duration Value],0)) AS INT) % 3600) / 60),'00') + ':' + 
	FORMAT((CAST(AVG(ISNULL([Avg Metric8 Duration Value],0)) AS INT) % 60), '00') AS VARCHAR(10)),' ') END AS [Avg Metric8 Duration]
INTO #AvgMetric8TimeDaily
FROM #TempTbl1 t
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #TotalMetric8Time a on a.datekey = t.datekey
GROUP BY t.[Date1]
ORDER BY t.[date1]


DROP TABLE IF EXISTS #TotalMetric9Time
SELECT 
t.[Date1],t.[Hour1],t.[datekey]
,ISNULL(a.tmd,0) AS [Total Metric9 Duration Value] 
,CASE WHEN SUM(ISNULL(CAST([TotalemployeeMetric9Duration]AS INT),0)) = 0 THEN ' 00:00:00 '
	ELSE CONCAT(' ',CAST(FORMAT((SUM(CAST(ISNULL(CAST([TotalemployeeMetric9Duration]AS INT),0) AS INT)) / 3600), '00') + ':'+
    FORMAT(((SUM(CAST(ISNULL(CAST([TotalemployeeMetric9Duration]AS INT),0) AS INT)) % 3600) / 60),'00') + ':' + 
	FORMAT((SUM(CAST(ISNULL(CAST([TotalemployeeMetric9Duration]AS INT),0) AS INT)) % 60), '00') AS VARCHAR(10)),' ') END AS [Total Metric9 Duration]
,CASE WHEN (SUM(ISNULL(a.tmd,0)) = 0
		OR SUM(ISNULL(c.[Metric2],0)) = 0) THEN 0
	ELSE CAST(ISNULL((CAST(SUM(ISNULL(a.tmd,0)) AS FLOAT) / CAST(SUM(ISNULL(c.[Metric2],0)) AS FLOAT)),0) AS FLOAT) END AS [Avg Metric9 Duration Value]
INTO #TotalMetric9Time
FROM #TempTbl1 t
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
INNER JOIN (
			SELECT t.[Date1],t.[Hour1],t.[datekey],SUM(ISNULL(CAST([TotalemployeeMetric9Duration]AS INT),0)) [tmd] FROM #TempTbl1 t GROUP BY t.[Date1],t.[Hour1],t.[datekey]
		)  a
		ON a.datekey = t.datekey
WHERE 1=1
GROUP BY t.[Date1],t.[Hour1],t.[datekey],a.tmd
ORDER BY t.[date1],t.[hour1] ASC

DROP TABLE IF EXISTS #AvgMetric9Time
SELECT 
t.[Date1],t.[Hour1],t.[datekey]
,CASE WHEN ISNULL([Avg Metric9 Duration Value],0) = 0 THEN ' 00:00:00 '
	ELSE CONCAT(' ',CAST(FORMAT((CAST(ISNULL([Avg Metric9 Duration Value],0) AS INT) / 3600), '00') + ':'+
    FORMAT(((CAST(ISNULL([Avg Metric9 Duration Value],0) AS INT) % 3600) / 60),'00') + ':' + 
	FORMAT((CAST(ISNULL([Avg Metric9 Duration Value],0) AS INT) % 60), '00') AS VARCHAR(10)),' ') END AS [Avg Metric9 Duration]
INTO #AvgMetric9Time
FROM #TempTbl1 t
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #TotalMetric9Time a on a.datekey = t.datekey
GROUP BY t.[Date1],t.[Hour1],t.[datekey],[Avg Metric9 Duration Value]
ORDER BY t.[date1],t.[hour1] ASC

DROP TABLE IF EXISTS #AvgMetric9TimeDaily
SELECT 
t.[Date1]
,CASE WHEN AVG(ISNULL([Avg Metric9 Duration Value],0)) = 0 THEN ' 00:00:00 '
	ELSE CONCAT(' ',CAST(FORMAT((CAST(AVG(ISNULL([Avg Metric9 Duration Value],0)) AS INT) / 3600), '00') + ':'+
    FORMAT(((CAST(AVG(ISNULL([Avg Metric9 Duration Value],0)) AS INT) % 3600) / 60),'00') + ':' + 
	FORMAT((CAST(AVG(ISNULL([Avg Metric9 Duration Value],0)) AS INT) % 60), '00') AS VARCHAR(10)),' ') END AS [Avg Metric9 Duration]
INTO #AvgMetric9TimeDaily
FROM #TempTbl1 t
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #TotalMetric9Time a on a.datekey = t.datekey
GROUP BY t.[Date1]
ORDER BY t.[date1]


DROP TABLE IF EXISTS #Metric10
SELECT 
[Date1],[Hour1],[datekey]
,ISNULL(COUNT(*),0) AS [Metric10]
INTO #Metric10
FROM #TempTbl1
WHERE 1=1
AND [Category4] IN ('Test1','Test2')
GROUP BY [Date1],[Hour1],[datekey]
ORDER BY [date1],[hour1] ASC

DROP TABLE IF EXISTS #Metric10Rate
SELECT 
t.[date1] AS [Date]
,t.[hour1] AS [Time]
,s.[datekey]
,CASE WHEN (SUM(ISNULL(lm.[Metric10],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(lm.[Metric10],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric 10 %]
INTO #Metric10Rate
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric10 lm on lm.[datekey] = t.[datekey]
GROUP BY t.[date1],t.[hour1],s.[datekey]

DROP TABLE IF EXISTS #Metric10RateDaily
SELECT 
t.[date1] AS [Date]
,CASE WHEN (SUM(ISNULL(lm.[Metric10],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(lm.[Metric10],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric 10 %]
INTO #Metric10RateDaily
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric10 lm on lm.[datekey] = t.[datekey]
GROUP BY t.[date1]

DROP TABLE IF EXISTS #Metric11
SELECT 
[Date1],[Hour1],[datekey]
,ISNULL(COUNT(*),0) AS [Metric11]
INTO #Metric11
FROM #TempTbl1
WHERE 1=1
AND [TertiaryCategory2] = 'Test1'
GROUP BY [Date1],[Hour1],[datekey]
ORDER BY [date1],[hour1] ASC

DROP TABLE IF EXISTS #Metric11Rate
SELECT 
t.[date1] AS [Date]
,t.[hour1] AS [Time]
,s.[datekey]
,CASE WHEN (SUM(ISNULL(nc.[Metric11],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(nc.[Metric11],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric11Rate]
INTO #Metric11Rate
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric11 nc on nc.[datekey] = t.[datekey]
GROUP BY t.[date1],t.[hour1],s.[datekey]

DROP TABLE IF EXISTS #Metric11RateDaily
SELECT 
t.[date1] AS [Date]
,CASE WHEN (SUM(ISNULL(nc.[Metric11],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(nc.[Metric11],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric11Rate]
INTO #Metric11RateDaily
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric11 nc on nc.[datekey] = t.[datekey]
GROUP BY t.[date1]

DROP TABLE IF EXISTS #Metric12
SELECT 
[Date1],[Hour1],[datekey]
,COUNT(*) AS [Metric12]
INTO #Metric12
FROM #TempTbl1
WHERE 1=1
AND [TertiaryCategory2] LIKE 'Test1'
GROUP BY [Date1],[Hour1],[datekey]
ORDER BY [date1],[hour1] ASC

DROP TABLE IF EXISTS #Metric12Rate
SELECT 
t.[date1] AS [Date]
,t.[hour1] AS [Time]
,s.[datekey]
,CASE WHEN (SUM(ISNULL(iv.[Metric12],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(iv.[Metric12],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric12 Rate]
INTO #Metric12Rate
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric12 iv on iv.[datekey] = t.[datekey]
GROUP BY t.[date1],t.[hour1],s.[datekey]

DROP TABLE IF EXISTS #Metric12RateDaily
SELECT 
t.[date1] AS [Date]
,CASE WHEN (SUM(ISNULL(iv.[Metric12],0)) = 0
		OR SUM(ISNULL(t.[Totals Metric1],0)) = 0) THEN 0
	ELSE ISNULL((CAST(SUM(ISNULL(iv.[Metric12],0)) AS FLOAT) / 
	CAST(SUM(ISNULL(t.[Totals Metric1],0)) AS FLOAT)),0) END AS [Metric12 Rate]
INTO #Metric12RateDaily
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #Metric12 iv on iv.[datekey] = t.[datekey]
GROUP BY t.[date1]




IF @CurrentID < 6
BEGIN

---- aggr query
SELECT 
CAST(t.[date1] AS DATE) AS [Date]
,RIGHT(CAST(t.[hour1] AS smalldatetime),8) AS [Time]
,ISNULL(t.[Totals Metric1],0) AS [Totals Metric1]
,ISNULL(c.[Metric2],0) AS [Metric2]
,ISNULL(cr.[Metric2 %],0) AS [Metric2 %]
,ISNULL(sa.[Metric 3],0) AS [Metric 3]
,ISNULL(la.[Metric4],0) AS [Metric4]
,ISNULL(ar.[Metric4Rate],0) AS [Metric4Rate]
,ISNULL(r.[Metric5],0) AS [Metric5]
,ISNULL(rr.[Metric5 %],0) AS [Metric5 %]
,ISNULL(p.[Metric6],0) AS [Metric6]
,ISNULL(pr.[Metric6 %],0) AS [Metric6 %]
,ISNULL([Avg Metric7 Duration],' 00:00:00 ') AS [Avg Metric7 Duration]
,ISNULL([Avg Metric8 Duration],' 00:00:00 ') AS [Avg Metric8 Duration]
,ISNULL([Avg Metric9 Duration],' 00:00:00 ') AS [Avg Metric9 Duration]
,ISNULL(a2.[employee Count],0) AS [employees]
FROM #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #EmployeeCount2 a2 on a2.[datekey] = t.[datekey]
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #Metric2Rate cr on cr.[datekey] = t.[datekey]
LEFT JOIN #Metric3 sa on sa.[datekey] = t.[datekey]
LEFT JOIN #Metric4 la on la.[datekey] = t.[datekey]
LEFT JOIN #Metric4Rate ar on ar.[datekey] = t.[datekey]
LEFT JOIN #Metric5 r on r.[datekey] = t.[datekey]
LEFT JOIN #Metric5Rate rr on rr.[datekey] = t.[datekey]
LEFT JOIN #Metric6 p on p.[datekey] = t.[datekey]
LEFT JOIN #Metric6Rate pr on pr.[datekey] = t.[datekey]
LEFT JOIN #AvgMetric7Time att on att.[datekey] = t.[datekey]
LEFT JOIN #AvgMetric8Time wtt on wtt.[datekey] = t.[datekey]
LEFT JOIN #AvgMetric9Time htt on htt.[datekey] = t.[datekey]
ORDER BY t.[date1],t.[hour1] ASC

-- AGGR DAILY 
----
SELECT 
CAST(t.[date1] AS DATE) AS [Date]
,SUM(ISNULL(t.[Totals Metric1],0)) AS [Totals Metric1]
,SUM(ISNULL(c.[Metric2],0)) AS [Metric2]
,ISNULL(crd.[Metric2 %],0) AS [Metric2 %]
,SUM(ISNULL(sa.[Metric 3],0)) AS [Metric 3]
,SUM(ISNULL(la.[Metric4],0)) AS [Metric4]
,ISNULL(ard.[Metric4Rate],0) AS [Metric4Rate]
,SUM(ISNULL(r.[Metric5],0)) AS [Metric5]
,ISNULL(rrd.[Metric5 %],0) AS [Metric5 %]
,SUM(ISNULL(p.[Metric6],0)) AS [Metric6]
,ISNULL(prd.[Metric6 %],0) AS [Metric6 %]
,ISNULL([Avg Metric7 Duration],' 00:00:00 ') AS [Avg Metric7 Duration]
,ISNULL([Avg Metric8 Duration],' 00:00:00 ') AS [Avg Metric8 Duration]
,ISNULL([Avg Metric9 Duration],' 00:00:00 ') AS [Avg Metric9 Duration]
,ISNULL(ad.[employee Count],0) AS [employees]
FROM #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #EmployeeCountDaily ad on ad.[Date1] = t.[Date1]
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #Metric2RateDaily crd on crd.[Date] = t.[Date1]
LEFT JOIN #Metric3 sa on sa.[datekey] = t.[datekey]
LEFT JOIN #Metric4 la on la.[datekey] = t.[datekey]
LEFT JOIN #Metric4Rate ard on ard.[Date] = t.[Date1]
LEFT JOIN #Metric5 r on r.[datekey] = t.[datekey]
LEFT JOIN #Metric5RateDaily rrd on rrd.[date] = t.[date1]
LEFT JOIN #Metric6 p on p.[datekey] = t.[datekey]
LEFT JOIN #Metric6RateDaily prd on prd.[date] = t.[date1]
LEFT JOIN #AvgMetric7TimeDaily atmd on atmd.[date1] = t.[date1]
LEFT JOIN #AvgMetric8TimeDaily wtmd on wtmd.[date1] = t.[date1]
LEFT JOIN #AvgMetric9TimeDaily htmd on htmd.[date1] = t.[date1]
GROUP BY t.[Date1],[Metric2 %],[Metric4Rate],[Metric5 %],[Metric6 %],[employee Count],[Avg Metric7 Duration],[Avg Metric8 Duration],[Avg Metric9 Duration]
ORDER BY t.[date1]

END
ELSE
BEGIN

----  aggr query 2
select 
CAST(t.[date1] AS DATE) AS [Date]
,RIGHT(CAST(t.[hour1] AS smalldatetime),8) AS [Time]
,ISNULL(t.[Totals Metric1],0) AS [Totals Metric1]
,ISNULL(c.[Metric2],0) AS [Metric2]
,ISNULL(cr.[Metric2 %],0) AS [Metric2 %]
,ISNULL(sa.[Metric 3],0) AS [Metric 3]
,ISNULL(la.[Metric4],0) AS [Metric4]
,ISNULL(ar.[Metric4Rate],0) AS [Metric4Rate]
,ISNULL(lm.[Metric10],0) AS [Left Message]
,ISNULL(lmr.[Metric 10 %],0) AS [Metric 10 %]
,ISNULL(nc.[Metric11],0) AS [No Contact]
,ISNULL(ncr.[Metric11Rate],0) AS [No Contact %]
,ISNULL(iv.[Metric12],0) AS [Metric12]
,ISNULL(ivr.[Metric12 Rate],0) AS [Invalid %]
,ISNULL(r.[Metric5],0) AS [Metric5]
,ISNULL(rr.[Metric5 %],0) AS [Metric5 %]
,ISNULL(p.[Metric6],0) AS [Metric6]
,ISNULL(pr.[Metric6 %],0) AS [Metric6 %]
,ISNULL([Avg Metric7 Duration],' 00:00:00 ') AS [Avg Metric7 Duration]
,ISNULL([Avg Metric8 Duration],' 00:00:00 ') AS [Avg Metric8 Duration]
,ISNULL([Avg Metric9 Duration],' 00:00:00 ') AS [Avg Metric9 Duration]
,ISNULL(a2.[employee Count],0) AS [employees]
from #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #EmployeeCount2 a2 on a2.[datekey] = t.[datekey]
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #Metric2Rate cr on cr.[datekey] = t.[datekey]
LEFT JOIN #Metric3 sa on sa.[datekey] = t.[datekey]
LEFT JOIN #Metric4 la on la.[datekey] = t.[datekey]
LEFT JOIN #Metric4Rate ar on ar.[datekey] = t.[datekey]
LEFT JOIN #Metric5 r on r.[datekey] = t.[datekey]
LEFT JOIN #Metric10 lm on lm.[datekey] = t.[datekey]
LEFT JOIN #Metric10Rate lmr on lmr.[datekey] = t.[datekey]
LEFT JOIN #Metric11 nc on nc.[datekey] = t.[datekey]
LEFT JOIN #Metric11Rate ncr on ncr.[datekey] = t.[datekey]
LEFT JOIN #Metric12 iv on iv.[datekey] = t.[datekey]
LEFT JOIN #Metric12Rate ivr on ivr.[datekey] = t.[datekey]
LEFT JOIN #AvgMetric7Time att on att.[datekey] = t.[datekey]
LEFT JOIN #AvgMetric8Time wtt on wtt.[datekey] = t.[datekey]
LEFT JOIN #AvgMetric9Time htt on htt.[datekey] = t.[datekey]
LEFT JOIN #Metric5Rate rr on rr.[datekey] = t.[datekey]
LEFT JOIN #Metric6 p on p.[datekey] = t.[datekey]
LEFT JOIN #Metric6Rate pr on pr.[datekey] = t.[datekey]
ORDER BY t.[date1],t.[hour1] ASC

-- AGGR DAILY 2
----
SELECT 
CAST(t.[date1] AS DATE) AS [Date]
,SUM(ISNULL(t.[Totals Metric1],0)) AS [Totals Metric1]
,SUM(ISNULL(c.[Metric2],0)) AS [Metric2]
,ISNULL(crd.[Metric2 %],0) AS [Metric2 %]
,SUM(ISNULL(sa.[Metric 3],0)) AS [Metric 3]
,SUM(ISNULL(la.[Metric4],0)) AS [Metric4]
,ISNULL(ard.[Metric4Rate],0) AS [Metric4Rate]
,SUM(ISNULL(lm.[Metric10],0)) AS [Left Message]
,ISNULL(lmrd.[Metric 10 %],0) AS [Metric 10 %]
,SUM(ISNULL(nc.[Metric11],0)) AS [No Contact]
,ISNULL(ncrd.[Metric11Rate],0) AS [No Contact %]
,SUM(ISNULL(iv.[Metric12],0)) AS [Metric12]
,ISNULL(ivrd.[Metric12 Rate],0) AS [Invalid %]
,SUM(ISNULL(r.[Metric5],0)) AS [Metric5]
,ISNULL(rrd.[Metric5 %],0) AS [Metric5 %]
,SUM(ISNULL(p.[Metric6],0)) AS [Metric6]
,ISNULL(prd.[Metric6 %],0) AS [Metric6 %]
,ISNULL([Avg Metric7 Duration],' 00:00:00 ') AS [Avg Metric7 Duration]
,ISNULL([Avg Metric8 Duration],' 00:00:00 ') AS [Avg Metric8 Duration]
,ISNULL([Avg Metric9 Duration],' 00:00:00 ') AS [Avg Metric9 Duration]
,ISNULL(ad.[employee Count],0) AS [employees]
FROM #Metric1 t
LEFT JOIN #StartHour s on s.[datekey] = CONCAT(t.[date1],t.[hour1])
LEFT JOIN #EmployeeCountDaily ad on ad.[Date1] = t.[Date1]
LEFT JOIN #Metric2 c on c.[datekey] = t.[datekey]
LEFT JOIN #Metric2RateDaily crd on crd.[Date] = t.[Date1]
LEFT JOIN #Metric3 sa on sa.[datekey] = t.[datekey]
LEFT JOIN #Metric4 la on la.[datekey] = t.[datekey]
LEFT JOIN #Metric4Rate ard on ard.[Date] = t.[Date1]
LEFT JOIN #Metric10 lm on lm.[datekey] = t.[datekey]
LEFT JOIN #Metric10RateDaily lmrd on lmrd.[date] = t.[date1]
LEFT JOIN #Metric11 nc on nc.[datekey] = t.[datekey]
LEFT JOIN #Metric11RateDaily ncrd on ncrd.[date] = t.[date1]
LEFT JOIN #Metric12 iv on iv.[datekey] = t.[datekey]
LEFT JOIN #Metric12RateDaily ivrd on ivrd.[date] = t.[date1]
LEFT JOIN #Metric5 r on r.[datekey] = t.[datekey]
LEFT JOIN #Metric5RateDaily rrd on rrd.[date] = t.[date1]
LEFT JOIN #Metric6 p on p.[datekey] = t.[datekey]
LEFT JOIN #Metric6RateDaily prd on prd.[date] = t.[date1]
LEFT JOIN #AvgMetric7TimeDaily atmd on atmd.[date1] = t.[date1]
LEFT JOIN #AvgMetric8TimeDaily wtmd on wtmd.[date1] = t.[date1]
LEFT JOIN #AvgMetric9TimeDaily htmd on htmd.[date1] = t.[date1]
GROUP BY t.[Date1],[Metric2 %],[Metric5 %],[Metric6 %],[employee Count],[Avg Metric7 Duration],[Avg Metric8 Duration],[Avg Metric9 Duration]
	,[Metric 10 %],[Metric11Rate],[Metric12 Rate],[Metric4Rate]
ORDER BY t.[date1]

END
SET @CurrentID = @CurrentID + 1;
END
