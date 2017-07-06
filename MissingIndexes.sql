-- Missing Indexes by Database
SELECT
	  DatabaseName = DB_NAME(database_id)
	, [Number Indexes Missing] = count(1) 
FROM
	sys.dm_db_missing_index_details 
GROUP BY
	DB_NAME(database_id) 
ORDER BY
	2 DESC;