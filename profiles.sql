def LAST_DAYS="&1"
set verify off
set lines 400
set pages 100
COL NAME FORMAT A30
COL SIGNATURE FORMAT 99999999999999999999999
COL CREATE_DATE FORMAT A20
COL MODIFIED_DATE FORMAT A20
COL FORCE FORMAT A8
COL EXEC_NAME FORMAT A15
COL SQL_TEXT FORMAT A70
SELECT /*+ PARALLEL(2) */
       NAME, 
       SIGNATURE, 
       TO_CHAR(CREATED,'DD/MM/YYYY HH24:MI:SS')       AS CREATE_DATE, 
       TO_CHAR(LAST_MODIFIED,'DD/MM/YYYY HH24:MI:SS') AS MODIFIED_DATE, 
       FORCE_MATCHING                                 AS FORCE, 
       TASK_EXEC_NAME                                 AS EXEC_NAME, 
	   translate(SUBSTR(SQL_TEXT,1,70), chr(10) || chr(13) || chr(09), ' ') as sql_text
FROM DBA_SQL_PROFILES P
 where (created >= trunc(sysdate)-&&LAST_DAYS
  or last_modified >= trunc(sysdate)-&&LAST_DAYS
  )
ORDER BY LAST_MODIFIED;