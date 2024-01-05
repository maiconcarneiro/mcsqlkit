set pagesize 1000
set linesize 300
col n format 99
col sid format 999999
col serial# format 99999
col machine format a30 trunc
col osuser format a20 trunc
col username format a20 trunc
col program format a40 trunc
col status format a10 trunc
col last_time format a20
col event format a40 trunc
col snap format a12
col module format a30 trunc
col child format 9999
select s.inst_id n, 
s.sid, 
s.serial#, 
s.machine, 
s.username,
osuser,
s.module, 
sq.plan_hash_value,
s.sql_child_number as child,
to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') as logon_time, 
--to_char(NVL(s.SQL_EXEC_START,s.PREV_EXEC_START),'dd/mm/yyyy hh24:mi:ss') as last_time, 
to_char(s.SQL_EXEC_START,'dd/mm/yyyy hh24:mi:ss') as last_time, 
event
from gv$session s
join gv$sql sq on s.inst_id = sq.inst_id and s.sql_id = sq.sql_id and s.sql_child_number = sq.child_number
where 1=1
and s.type = 'USER'
and s.status = 'ACTIVE'
and s.event = '&1'
order by s.logon_time;