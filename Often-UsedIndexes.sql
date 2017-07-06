-- Create required table structure only. 
-- Note: this SQL must be the same as in the Database loop given in the 
-- following step. 
SELECT TOP 1
 [Usage]=(user_seeks+user_scans+user_lookups),DatabaseName=DB_NAME(),TableName=OBJECT_NAME(s.[object_id]),IndexName=i.name
INTO #TempUsage
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.[object_id]=i.[object_id] AND s.index_id=i.index_id
WHERE s.database_id=DB_ID() AND OBJECTPROPERTY(s.[object_id],'IsMsShipped')=0 
AND (user_seeks+user_scans+user_lookups)>0 -- Only report on active rows. 
      AND s.[object_id]=-999 -- Dummy value to get table structure.
      ;

-- Loop around all the databases on the server. 

EXEC sp_MSForEachDB 'USE [?]; 
-- Table already exists. 
INSERT INTO #TempUsage SELECT TOP 10 [Usage] = 
(user_seeks + user_scans + user_lookups) ,DatabaseName = DB_NAME() ,
TableName = OBJECT_NAME(s.[object_id]) ,IndexName = i.name 
FROM sys.dm_db_index_usage_stats s 
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id 
WHERE s.database_id = DB_ID() AND i.name IS NOT NULL 
-- Ignore HEAP indexes. 
AND OBJECTPROPERTY(s.[object_id], ''IsMsShipped'') = 0 
AND (user_seeks + user_scans + user_lookups) > 0 
-- Only report on active rows. 
ORDER BY [Usage] DESC ; '
                    
-- Select records.
                    
SELECT TOP 10
 *
FROM #TempUsage
ORDER BY [Usage] DESC
         
-- Tidy up.
         
DROP TABLE #TempUsage