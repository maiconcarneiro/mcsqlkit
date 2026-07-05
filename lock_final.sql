SET LINESIZE 500
SET PAGESIZE 200

COL blocker_inst_id FORMAT 99 HEADING 'Inst'
COL blocker_sid FORMAT 99999 HEADING 'SID'
COL blocker_serial# FORMAT 999999 HEADING 'Serial#'
COL blocker_username FORMAT A15 HEADING 'Username'
COL blocker_status FORMAT A12 HEADING 'Status'
COL blocker_machine FORMAT A20 TRUNC HEADING 'Machine'
COL blocker_program FORMAT A20 TRUNC HEADING 'Program'
COL blocker_module FORMAT A20 TRUNC HEADING 'Module'
COL blocker_action FORMAT A20 TRUNC HEADING 'Action'
COL blocker_client_info FORMAT A10 TRUNC HEADING 'Client Info'
COL blocker_logon_time FORMAT A20 HEADING 'Logon Time'
COL blocker_last_call_et FORMAT 999,999,999 HEADING 'Last Call|ET (s)'
COL blocker_sql_id FORMAT A13 HEADING 'SQL_ID'
COL blocker_prev_sql_id FORMAT A13 HEADING 'Prev SQL_ID'
COL blocker_event FORMAT A30 TRUNC HEADING 'Event'
COL blocked_session_count FORMAT 99999 HEADING 'Blocked|Count'

WITH Waiter_Aggregation AS (
    -- Aggregate all waiters by their final blocking session
    SELECT final_blocking_instance,
           final_blocking_session,
           COUNT(*) as blocked_session_count
    FROM gv$session
    WHERE final_blocking_session IS NOT NULL
      AND final_blocking_session_status = 'VALID'
    GROUP BY final_blocking_instance, final_blocking_session
)
-- Join the aggregated counts back to gv$session to retrieve detailed root blocker metadata
SELECT 
    w.blocked_session_count,
    s.sid AS blocker_sid,
    s.inst_id AS blocker_inst_id,
    s.serial# AS blocker_serial#,
    s.username AS blocker_username,
    s.status AS blocker_status,
    s.event AS blocker_event,
    s.last_call_et AS blocker_last_call_et,
    s.sql_id AS blocker_sql_id,
    s.prev_sql_id AS blocker_prev_sql_id,
    s.machine AS blocker_machine,
    substr(s.program,1, instr(s.program,' ',1,1)-1) AS blocker_program,
    s.module AS blocker_module,
    --s.action AS blocker_action,
   -- s.client_info AS blocker_client_info,
    TO_CHAR(s.logon_time, 'YYYY-MM-DD HH24:MI:SS') AS blocker_logon_time
FROM Waiter_Aggregation w
JOIN gv$session s ON s.inst_id = w.final_blocking_instance 
                 AND s.sid = w.final_blocking_session
ORDER BY w.blocked_session_count DESC;
