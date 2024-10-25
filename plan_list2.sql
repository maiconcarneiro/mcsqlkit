PROMP SIGNATURE.: &1
PROMP
PROMP 1) SQL Plan Baselines:
PROMP ==================================================================================
SET LINESIZE 400
SET PAGESIZE 500
SET FEEDBACK OFF
SET VERIFY OFF
COL SIGNATURE  FORMAT 9999999999999999999999
COL SQL_HANDLE FORMAT A20
COL PLAN_NAME  FORMAT A30
COL ORIGIN     FORMAT A15 TRUNC
COL CREATED    HEADING "Created" FORMAT A15
COL MODIFIED   HEADING "Modified" FORMAT A15
COL ENABLED    HEADING "Enab" FORMAT A5
COL ACCEPTED   heading "Accept" FORMAT A6
COL FIXED 	   FORMAT A7
COL REPRODUCED Heading "Valid" FORMAT A5
COL EXECUTIONS FORMAT 99999999
COL PLAN_HASH_VALUE heading "Plan | Hash Value" FORMAT a15
SELECT /*+ PARALLEL(2) */ 
       SQL_HANDLE, 
       PLAN_NAME, 
	   (select replace(plan_table_output,'Plan hash value: ','')
         from table( dbms_xplan.display_sql_plan_baseline('' || SQL_HANDLE || '','' || PLAN_NAME || '') )
        where plan_table_output like '%Plan hash value%'
       ) as PLAN_HASH_VALUE,
       TO_CHAR(CREATED,'DD/MM/YY HH24:MI') CREATED,
       TO_CHAR(LAST_MODIFIED,'DD/MM/YY HH24:MI') AS MODIFIED, 
       ENABLED, 
       ACCEPTED, 
	   REPRODUCED,
	   ORIGIN
FROM DBA_SQL_PLAN_BASELINES B
where 1=1
and signature = &1
order by signature, modified;

PROMP
PROMP
PROMP 2) SQL Profiles:
PROMP ==================================================================================
COL NAME HEADING "Profile Name"
COL CATEGORY HEADING "Category" FORMAT A15
COL FORCE HEADING "Force|Matching"
SELECT /*+ PARALLEL(2) */
       NAME,
	   CATEGORY,
       TO_CHAR(CREATED,'DD/MM/YY HH24:MI')       AS CREATED,
       TO_CHAR(LAST_MODIFIED,'DD/MM/YY HH24:MI') AS MODIFIED,
       FORCE_MATCHING                            AS FORCE,
	   STATUS,
	   TYPE
FROM DBA_SQL_PROFILES P
 where signature = &1
ORDER BY LAST_MODIFIED;

PROMP
PROMP
PROMP 3) Planos carregados em memoria (GV$SQL):
PROMP ==================================================================================
col sql_id format a18
col plan_hash_value heading "Plan | Hash Value" format 999999999999
col sql_profile format a30
col sql_plan_baseline format a30
col sql_patch format a30
col signature format 999999999999999999999
col is_bind_sensitive heading "Is|Bind|Sens"
col is_bind_aware heading "Is|Bind|Aware"
select distinct 
       sql_id,
       plan_hash_value,
       sql_profile,
       sql_plan_baseline,
       sql_patch,
       exact_matching_signature as signature,
       is_bind_sensitive,
       is_bind_aware
 from   gv$sql
 where  FORCE_MATCHING_SIGNATURE = &1;
PROMP
PROMP