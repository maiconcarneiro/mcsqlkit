/*
 sid.sql -> @sid <SESSION ID> <INST_ID>
 Maicon Carneiro - 26/02/2023
*/

set sqlformat
set pagesize 1000
set linesize 400
col n format 99
col sid format 999999
col serial# format 99999
col machine format a40 trunc
col osuser format a20 trunc
col username format a20 trunc
col program format a40 trunc
col status format a10 trunc
col last_time format a20
col event format a40 trunc
col snap format a12
col module format a30 trunc
col sql_id format a15
col secs format 999,999,999.9999
select inst_id n, 
sid, 
serial#, 
machine, 
username,
module, 
status, 
sql_id,
to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') as logon_time, 
to_char(NVL(SQL_EXEC_START,PREV_EXEC_START),'dd/mm/yyyy hh24:mi:ss') as last_time, 
--(sysdate-SQL_EXEC_START)*24*60*60 secs,
event
from gv$session s
where 1=1
and sid = &1
and inst_id = &2
order by s.logon_time;
