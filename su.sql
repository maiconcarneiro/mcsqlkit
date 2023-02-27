-- Author: Maicon Carneiro (dibiei.com)
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
--osuser,
module, 
--program, 
--status, 
'@n ' || sid as snap,
sql_id,
--to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') as last_time, 
to_char(NVL(SQL_EXEC_START,PREV_EXEC_START),'dd/mm/yyyy hh24:mi:ss') as last_time, 
--(sysdate-SQL_EXEC_START)*24*60*60 secs,
event
from gv$session s
where 1=1
and type = 'USER'
--and module not like 'sqlplus%'
--and event not like 'SQL*Net%'
and status = 'ACTIVE'
--and sql_id not in ('44r41gfztjgw6')
and module <> 'GoldenGate'
and username = '&1'
and machine like '&2%'
--and machine like '%sqlplus%'
--and username not IN ('SYS','PUBLIC')
--and sql_id='42j3td55kgj61'
order by s.logon_time;
