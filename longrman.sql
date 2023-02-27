-- Author: Maicon Carneiro (dibiei.com)
set sqlformat
set linesize 300
set pagesize 500
col sid format 99999
col inst_id format 99
col target format a15
col "Start time" format a20
col "Min Elapsed" format 99999.99
col "Min Remaining" format 99999.99
col "% Work" format 999.00
col machine format a10 trunc
select s.machine,
       l.inst_id,
       l.sid,
       l.target,
       to_char(start_time,'dd/mm/yyyy hh24:mi:ss') as "Start time",
       round(l.elapsed_seconds/60,2)  as "Min Elapsed",
       round(time_remaining/60,2)     as "Min Remaining",
       round(sofar/totalwork*100,2)   as "% Work",
	   round((sofar*param.value)/1024/1024/1024,2)   as "GB Done",
	   round((totalwork*param.value) /1024/1024/1024,2) as "GB Total",
	   round( ((sofar*param.value)/1024/1024/1024) / (elapsed_seconds/60) , 2) as "GB per Min"
from gv$session_longops l, gv$session s, v$parameter param
where l.inst_id = s.inst_id
  and l.sid = s.sid
  and l.serial# = s.serial#
and l.time_remaining > 0
and param.name = 'db_block_size'
and l.message like 'RMAN%'
order by 1, 9;
