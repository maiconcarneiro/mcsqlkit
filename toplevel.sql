/*
 Queries the SQL IDs of queries executed by the SQL_ID of a PLSQL
 Rodrigo Gonçalves
*/

SELECT * FROM (
SELECT sql_id, count(*) 
FROM GV$ACTIVE_SESSION_HISTORY 
where sample_time >= (sysdate-&2)
and top_level_sql_id = '&1'
group by sql_id order by 2 desc
) WHERE ROWNUM <= 20;

SELECT * FROM (
SELECT sql_id, count(*) 
FROM DBA_HIST_ACTIVE_SESS_HISTORY
where sample_time >= (sysdate-&2)
and top_level_sql_id = '&1'
group by sql_id order by 2 desc
) WHERE ROWNUM <= 20;