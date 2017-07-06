-- Average CPU TIME
SELECT TOP 5
	  [Query Hash] = query_stats.query_hash 
    , [Avg CPU Time] = SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count)
    , [Statement Text] = MIN(query_stats.statement_text)
FROM 
    (SELECT
		  QS.* 
		, SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1
		,((CASE statement_end_offset
			WHEN -1 THEN DATALENGTH(ST.text)
			ELSE QS.statement_end_offset END - QS.statement_start_offset)/2) + 1) AS statement_text
     FROM
		sys.dm_exec_query_stats AS QS
     CROSS APPLY
		sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats
GROUP BY
	query_stats.query_hash
ORDER BY
	2 DESC;