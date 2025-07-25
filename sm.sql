set verify off
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
col sql_exec_start format a20
col event format a40 trunc
col snap format a12
col module format a20 trunc
col action format a30
select inst_id n, 
sid, 
serial#, 
status,
machine, 
username,
module,
action, 
sql_id,
--to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') as last_time, 
to_char(NVL(SQL_EXEC_START,PREV_EXEC_START),'dd/mm/yyyy hh24:mi:ss') as sql_exec_start, 
event
from gv$session s
where 1=1
and type = 'USER'
--and status = 'ACTIVE'
and module LIKE '%&1%'
order by s.logon_time;
