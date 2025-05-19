--=====

--- change the date based on your requirement 

set pagesize 300 linesize 500
--DEFINE 1="username,sql_id"
--DEFINE 2="session_type='FOREGROUND'"

--VARIABLE bdate VARCHAR2(35)
--VARIABLE edate VARCHAR2(35)
--exec SELECT CAST('25-MAR-2023 07:25' AS DATE) into :Bdate FROM dual;
--exec SELECT CAST('25-MAR-2023 08:00' AS DATE) into :edate FROM dual;


-- @ashtop username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate
--
-- Other:
--     This script uses only the in-memory V$ACTIVE_SESSION_HISTORY, use
--     @dashtop.sql for accessiong the DBA_HIST_ACTIVE_SESS_HISTORY archive
--              
--------------------------------------------------------------------------------
COL "%This" FOR A7
--COL p1     FOR 99999999999999
--COL p2     FOR 99999999999999
--COL p3     FOR 99999999999999
COL p1text FOR A30 word_wrap
COL p2text FOR A30 word_wrap
COL p3text FOR A30 word_wrap
COL p1hex  FOR A17
COL p2hex  FOR A17
COL p3hex  FOR A17
COL AAS    FOR 9999.9
COL totalseconds HEAD "Total|Seconds" FOR 99999999
COL event  FOR A40 WORD_WRAP
--set linesize 200
col USERNAME for a20
col min_sample_time for a18
col max_sample_time for a18

SELECT * FROM (
    SELECT /*+ LEADING(a) USE_HASH(u) */
        COUNT(*)                                                     totalseconds
        , abs(ROUND(COUNT(*) / ((CAST(&4 AS DATE) - CAST(&3 AS DATE)) * 86400), 1)) AAS
        , LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ')||' |' "%This"
        , &1
        , SUM(CASE WHEN wait_class IS NULL           THEN 1 ELSE 0 END) "CPU"
        , SUM(CASE WHEN wait_class ='User I/O'       THEN 1 ELSE 0 END) "User I/O"
        , SUM(CASE WHEN wait_class ='Application'    THEN 1 ELSE 0 END) "Application"
        , SUM(CASE WHEN wait_class ='Concurrency'    THEN 1 ELSE 0 END) "Concurrency"
        , SUM(CASE WHEN wait_class ='Commit'         THEN 1 ELSE 0 END) "Commit"
        , SUM(CASE WHEN wait_class ='Configuration'  THEN 1 ELSE 0 END) "Configuration"
        , SUM(CASE WHEN wait_class ='Cluster'        THEN 1 ELSE 0 END) "Cluster"
        , SUM(CASE WHEN wait_class ='Idle'           THEN 1 ELSE 0 END) "Idle"
        , SUM(CASE WHEN wait_class ='Network'        THEN 1 ELSE 0 END) "Network"
        , SUM(CASE WHEN wait_class ='System I/O'     THEN 1 ELSE 0 END) "System I/O"
        , SUM(CASE WHEN wait_class ='Scheduler'      THEN 1 ELSE 0 END) "Scheduler"
        , SUM(CASE WHEN wait_class ='Administrative' THEN 1 ELSE 0 END) "Administrative"
        , SUM(CASE WHEN wait_class ='Queueing'       THEN 1 ELSE 0 END) "Queueing"
        , SUM(CASE WHEN wait_class ='Other'          THEN 1 ELSE 0 END) "Other"
        , to_char(MIN(sample_time),'DD/MM/RR HH24:MI:SS') min_sample_time
        , to_char(MAX(sample_time),'DD/MM/RR HH24:MI:SS') max_sample_time
    --    , MAX(sql_exec_id) - MIN(sql_exec_id)
    FROM
        (SELECT
             a.*
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
        FROM gv$active_session_history a) a
		--from DBA_HIST_ACTIVE_SESS_HISTORY a) a
      , dba_users u
	  --, cdb_users u
    WHERE
        a.user_id = u.user_id (+)
    AND &2
  AND sample_time BETWEEN &3  AND &4 
    GROUP BY
        &1
    ORDER BY
        TotalSeconds DESC
       , &1
)
WHERE
    ROWNUM <= 20
/
