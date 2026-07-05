SET LINESIZE 400
SET PAGESIZE 200

COL blocking_tree FORMAT A30 HEADING 'Blocking Tree|(Holder -> Waiter)'
COL username FORMAT A15
COL sql_id FORMAT A13
COL machine FORMAT A20 TRUNC
COL program FORMAT A20 TRUNC
COL event FORMAT A30 TRUNC
COL status FORMAT A12
COL seconds_in_wait FORMAT 999,999,999 HEADING 'Wait Sec'
col blocker format a15
col final_blocker format a15

SELECT 
    -- Visualizes the hierarchy. Root holders have no indentation; waiters are indented.
    LPAD(' ', 3 * (LEVEL - 1)) || 
        CASE 
            WHEN LEVEL = 1 THEN 'Holder: ' 
            ELSE 'Waiter: ' 
        END || ss.sid || ' ' || ss.inst_id AS blocking_tree,
    ss.username,
    ss.sql_id,
    ss.machine,
    substr(ss.program,1, instr(ss.program,' ',1,1)-1) AS program,
    ss.event,
    ss.status,
    ss.seconds_in_wait,
    ss.blocking_session || ' ' || ss.blocking_instance AS blocker,
    ss.final_blocking_session || ' ' || ss.final_blocking_instance AS final_blocker
FROM gv$session ss
WHERE ss.sid IN (
    -- Filter to only include sessions that are either blockers or actively blocked
    SELECT sid FROM gv$session WHERE blocking_session IS NOT NULL
    UNION
    SELECT blocking_session FROM gv$session WHERE blocking_session IS NOT NULL
)
-- Establish the hierarchy: Parent is the blocking session, Child is the waiting session
START WITH ss.blocking_session IS NULL 
       AND ss.sid IN (SELECT blocking_session FROM gv$session WHERE blocking_session IS NOT NULL)
CONNECT BY PRIOR ss.sid = ss.blocking_session
       AND PRIOR ss.inst_id = COALESCE(ss.blocking_instance, ss.inst_id)
-- Keeps the tree structure intact while ordering waiters of the same level by wait time
ORDER SIBLINGS BY ss.seconds_in_wait DESC;
