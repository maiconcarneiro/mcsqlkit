/*
 Query para listar o resumo de PHV usado por cada SQL ID no AWR
 Compartilhado por André Moreno
*/

SET verify OFF
SET feedback OFF
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD/MM/YYYY HH24:MI:SS';
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SET feedback ON

VARIABLE sql_id VARCHAR2(13)
DEF sql_id = '&&1';

PROMPT
PROMPT #################################################################
PROMPT #       A L L    S Q L     P L A N   H A S H   V A L U E
PROMPT #################################################################
COLUMN sql_id               HEADING "SQL_ID"                 FORMAT a13
COLUMN plan_hash_value      HEADING "PLAN_HASH_VALUE"        FORMAT 9999999999999999
COLUMN cost                 HEADING "Cost"                   FORMAT 9999999999
COLUMN last_used            HEADING "Last_Used"              FORMAT a20
COLUMN first_used           HEADING "First_Used"             FORMAT a20
COLUMN first_parsed         HEADING "First_Parsed"           FORMAT a20
COLUMN avg_et_secs          HEADING "AVG Secs"               FORMAT 999,999,999.999999
set lin 1000
set pages 50
SELECT p.sql_id
     , p.plan_hash_value
     , p.cost
     , MAX(s.end_interval_time)  last_used
     , MIN(s.end_interval_time)  first_used
     , MIN(p.timestamp)          first_parsed
     , ROUND(SUM(ss.elapsed_time_total)/SUM(ss.executions_total) /1e6 ,4) avg_et_secs
  FROM gv$database d
     , dba_hist_sql_plan p
     , dba_hist_sqlstat ss
     , dba_hist_snapshot s
WHERE d.dbid = p.dbid
   AND p.dbid = ss.dbid (+)
   AND p.sql_id = ss.sql_id (+)
   AND p.plan_hash_value = ss.plan_hash_value
   AND ss.dbid = s.dbid (+)
   AND ss.instance_number = s.instance_number (+)
   AND ss.snap_id = s.snap_id (+)
   AND p.id = 0 -- Top row which has cost as well
   AND p.sql_id = '&1'
GROUP BY p.sql_id
       , p.plan_hash_value
       , p.cost
ORDER BY first_parsed;

/*
 Complemento usado pelo script coe_xfr_sql_profile.sql (carlos.sierra@oracle.com)
*/

DEF sql_id = '&&1';
PRO
WITH
p AS (
SELECT plan_hash_value
  FROM gv$sql_plan
WHERE sql_id = TRIM('&&1')
   AND other_xml IS NOT NULL
UNION
SELECT plan_hash_value
  FROM dba_hist_sql_plan
WHERE sql_id = TRIM('&&1')
   AND other_xml IS NOT NULL ),
m AS (
SELECT plan_hash_value,
       SUM(elapsed_time)/SUM(executions) avg_et_secs
  FROM gv$sql
WHERE sql_id = TRIM('&&1')
   AND executions > 0
GROUP BY
       plan_hash_value ),
a AS (
SELECT plan_hash_value,
       SUM(elapsed_time_total)/SUM(executions_total) avg_et_secs
  FROM dba_hist_sqlstat
WHERE sql_id = TRIM('&&1')
   AND executions_total > 0
GROUP BY
       plan_hash_value )
SELECT p.plan_hash_value,
       ROUND(NVL(m.avg_et_secs, a.avg_et_secs)/1e6, 3) avg_et_secs
  FROM p, m, a
WHERE p.plan_hash_value = m.plan_hash_value(+)
   AND p.plan_hash_value = a.plan_hash_value(+)
ORDER BY
       avg_et_secs NULLS LAST;
