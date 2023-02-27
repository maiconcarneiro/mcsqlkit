-- Author: Maicon Carneiro (dibiei.com)
SELECT
    s.sid,
    s.serial#,
    s.machine,
    to_char(s.logon_time,'dd/mm/yyyy hh24:mi:ss') logon_time,
    to_char(s.sql_exec_start,'dd/mm/yyyy hh24:mi:ss') sql_exec_start,
    sq.executions,
    sq.plan_hash_value,
    s.username,
    s.program,
    s.sql_hash_value,
    s.sql_id
FROM
    gv$session s,
    gv$sql sq
WHERE s.sql_id = sq.sql_id
  AND s.inst_id = sq.inst_id
  AND s.inst_id = 1 
  AND s.sid = '&1'
 /
