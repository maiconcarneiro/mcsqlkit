SET VERIFY OFF
SET LINESIZE 400
SET PAGESIZE 500
COL SIGNATURE  FORMAT 9999999999999999999999
COL SQL_HANDLE FORMAT A20
COL PLAN_NAME  FORMAT A30
COL ORIGIN     FORMAT A15 TRUNC
COL CREATED    FORMAT A20
COL MODIFIED   FORMAT A20
COL ENABLED    FORMAT A8
COL ACCEPTED   FORMAT A7
COL ADAPTIVE   FORMAT A8
COL PLAN_HASH_VALUE FORMAT A15
WITH SPM AS (
SELECT SIGNATURE, 
       SQL_HANDLE, 
       PLAN_NAME, 
       ORIGIN, 
       TO_CHAR(CREATED,'DD/MM/YYYY HH24:MI:SS') CREATED,
       TO_CHAR(LAST_MODIFIED,'DD/MM/YYYY HH24:MI:SS') AS MODIFIED, 
       ENABLED, 
       ACCEPTED, 
       ADAPTIVE 
     ,(select replace(plan_table_output,'Plan hash value: ','')
         from table(dbms_xplan.display_sql_plan_baseline('' || SQL_HANDLE || '','' || PLAN_NAME || ''))
        where plan_table_output like '%Plan hash value%'
       ) as PLAN_HASH_VALUE
FROM DBA_SQL_PLAN_BASELINES
WHERE 1=1;
AND signature in (select exact_matching_signature from gv$sql where sql_id='&&sql_id' ) ;
)
SELECT P.* , T.AVG_ET_SECS 
  FROM SPM P,
  ( -- sub consulta do coe.sql para obter tempo medio de execucao de cada plano
    WITH
    p AS (
    SELECT plan_hash_value
      FROM gv$sql_plan
     WHERE sql_id = TRIM('&&sql_id.')
       AND other_xml IS NOT NULL
    UNION
    SELECT plan_hash_value
      FROM dba_hist_sql_plan
     WHERE sql_id = TRIM('&&sql_id.')
       AND other_xml IS NOT NULL ),
    m AS (
    SELECT plan_hash_value, SUM(elapsed_time)/SUM(executions) avg_et_secs
      FROM gv$sql
     WHERE sql_id = TRIM('&&sql_id.')
       AND executions > 0
    GROUP BY plan_hash_value ),
    a AS (
    SELECT plan_hash_value,SUM(elapsed_time_total)/SUM(executions_total) avg_et_secs
      FROM dba_hist_sqlstat
     WHERE sql_id = TRIM('&&sql_id.')
       AND executions_total > 0
    GROUP BY plan_hash_value )
    SELECT p.plan_hash_value, ROUND(NVL(m.avg_et_secs, a.avg_et_secs)/1e6, 2) avg_et_secs
      FROM p, m, a
     WHERE p.plan_hash_value = m.plan_hash_value(+)
       AND p.plan_hash_value = a.plan_hash_value(+)
) T
WHERE P.PLAN_HASH_VALUE = T.PLAN_HASH_VALUE(+);
undefine sql_id;
