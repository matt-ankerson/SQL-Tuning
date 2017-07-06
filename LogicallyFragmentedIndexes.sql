-- Create required table structure only. 
-- Note: this SQL must be the same as in the Database loop given in the 
-- following step. 
SELECT TOP 1
  DatbaseName = DB_NAME(),
  TableName = OBJECT_NAME(s.[object_id]),
  IndexName = i.name,
  [Fragmentation %] = ROUND(avg_fragmentation_in_percent, 2) INTO #TempFragmentation
FROM sys.DM_DB_INDEX_PHYSICAL_STATS(DB_ID(), NULL, NULL, NULL, NULL) s
INNER JOIN sys.indexes i
  ON s.[object_id] = i.[object_id]
  AND s.index_id = i.index_id
WHERE s.[object_id] = -999 -- Dummy value just to get table structure. 
;
-- Loop around all the databases on the server. 
EXEC sp_MSForEachDB 'USE [?]; -- Table already exists. INSERT INTO #TempFragmentation 
SELECT TOP 10 DatbaseName = DB_NAME() ,TableName = OBJECT_NAME(s.[object_id]) ,
IndexName = i.name ,[Fragmentation %] = ROUND(avg_fragmentation_in_percent,2) 
FROM sys.dm_db_index_physical_stats(db_id(),null, null, null, null) s 
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id 
WHERE s.database_id = DB_ID() AND i.name IS NOT NULL 
-- Ignore HEAP indexes. 
AND OBJECTPROPERTY(s.[object_id], ''IsMsShipped'') = 0 
ORDER BY [Fragmentation %] DESC ; '
-- Select records. 
SELECT TOP 10
  *
FROM #TempFragmentation
ORDER BY [Fragmentation %] DESC
-- Tidy up. 
DROP TABLE #TempFragmentation