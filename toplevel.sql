SELECT * FROM (
SELECT sql_id, count(*) 
FROM GV$ACTIVE_SESSION_HISTORY 
where sample_time >= (sysdate-2/24)
and top_level_sql_id = '&1'
group by sql_id order by 2 desc
) WHERE ROWNUM <= 20;