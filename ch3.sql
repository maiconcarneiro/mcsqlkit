undefine sql_id
clear breaks

set lines 200
set pagesize 100
set verify off;

col execs               FORMAT 999,999,999
col avg_lio             FORMAT 999,999,999,999.9 
col begin_interval_time FORMAT a20
col node                FORMAT 99999
col waits format a100
col sql_id format a1 trunc
col avg_rows_proc heading "Rows" format 999,999,999
col avg_time_sec heading "Avg Time (sec)" format 999,999,999.99
col avg_time_ms heading "Avg Time (ms)" format 999,999,999.99
col plan_hash_value heading "Plan Hash" format 99999999999

break on sql_id skip 1
compute avg of avg_etime_se on sql_id
compute avg of avg_etime_ms on sql_id
compute avg of execs on sql_id

ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

SELECT 
    node,
	snap_id,
    begin_interval_time,
    sql_id,
    plan_hash_value,
    execs,
--    round((avg_etime / 1000000), 2) avg_time_sec,
    round((avg_etime /    1000), 2) avg_time_ms,
--    round((avg_etime/1000),2) - LAG(round((avg_etime/1000),2),1,0) OVER (ORDER BY begin_interval_time) "DIFF(ms)",
    avg_rows_proc,
--    sql_hist_px_1exec,
--    sql_profile,
    waits
FROM (
SELECT
    ss.snap_id,
    ss.instance_number node,
    begin_interval_time,
    sql_id,
    plan_hash_value,
    nvl(executions_delta, 0) execs,
    elapsed_time_delta          / DECODE(nvl(executions_delta,  0), 0, 1, executions_delta)                avg_etime,
    ELAPSED_TIME_TOTAL          / DECODE(nvl(executions_total,  0), 0, 1, executions_total)                avg_etime_tot,
    round((rows_processed_delta / DECODE(nvl(executions_delta,  0), 0, 1, executions_delta)),  2)          avg_rows_proc,
    round(buffer_gets_delta     / DECODE(nvl(buffer_gets_delta, 0), 0, 1, executions_delta),   2)          avg_lio,
    ROUND(px_servers_execs_delta)/ DECODE(nvl(px_servers_execs_delta,  0), 0, 1, executions_delta)         sql_hist_px_1exec,
    sql_profile,
    (
    select LISTAGG(rownum || ' - ' || event2||'('||percent||'%)', chr(10) ) WITHIN GROUP (ORDER BY percent DESC) AS event from (
    SELECT 
       nvl(event,session_state) event2,
       ROUND((COUNT(sql_id) / SUM(COUNT(nvl(event,session_state))) OVER(PARTITION BY sql_id)) * 100,2) AS percent
     FROM dba_hist_active_sess_history x
    WHERE ss.snap_id = x.snap_id
      AND ss.instance_number = x.instance_number
      AND x.sql_id   = s.sql_id
      AND x.sql_id = nvl('&1', sql_id)
    GROUP BY sql_id, nvl(event,session_state)
    ORDER BY percent DESC 
    ) where rownum <=5
    ) as waits
FROM
    dba_hist_sqlstat    s,
    dba_hist_snapshot   ss
WHERE sql_id = nvl('&&1', sql_id)
    AND ss.end_interval_time >= sysdate-&2
    AND ss.snap_id = s.snap_id
    AND ss.instance_number = s.instance_number
    AND executions_delta > 0
)
ORDER BY 2,1
/
