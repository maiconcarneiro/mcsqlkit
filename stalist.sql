/*
 Query to list all jobs created by sta.sql script.
 Maicon Carneiro - dibiei.blog
 Updated: 19/10/2024
*/

set sqlformat
set feedback off
SET SQLFORMAT
SET PAGES 50
SET LINES 400
COL JOB_NAME FORMAT A40
COL START_DATE FORMAT a20
COL STATUS FORMAT A15
COL STATE FORMAT A15
COL SQL_ID FORMAT A20
COL COMMENTS FORMAT A70
COL TASK_NAME FORMAT A15
COL LOG_DATE FORMAT A20

PROMP Jobs Pendentes:

SELECT lower(REGEXP_SUBSTR(JOB_NAME, '[^_]+_[^_]+_[^_]+_(.*)', 1, 1, NULL, 1)) AS SQL_ID, 
       REGEXP_SUBSTR(JOB_NAME, '^[^_]+_([^_]+_[^_]+)', 1, 1, NULL, 1) AS TASK_NAME,
       JOB_NAME,
       STATE, 
       TO_CHAR(START_DATE,'DD/MM/YYYY HH24:MI:SS') AS START_DATE,
       SUBSTR(COMMENTS,1,70) AS COMMENTS
FROM DBA_SCHEDULER_JOBS 
WHERE JOB_NAME LIKE 'STA%';

PROMP
PROMP Jobs Finalizados:

SELECT lower(REGEXP_SUBSTR(JOB_NAME, '[^_]+_[^_]+_[^_]+_(.*)', 1, 1, NULL, 1)) AS SQL_ID, 
       REGEXP_SUBSTR(JOB_NAME, '^[^_]+_([^_]+_[^_]+)', 1, 1, NULL, 1) AS TASK_NAME, 
       JOB_NAME,
       TO_CHAR(LOG_DATE,'DD/MM/YYYY HH24:MI:SS') AS LOG_DATE,
       STATUS
FROM DBA_SCHEDULER_JOB_LOG 
WHERE JOB_NAME LIKE 'STA%' 
AND LOG_DATE >= SYSTIMESTAMP-2
ORDER BY LOG_ID DESC;

PROMP
