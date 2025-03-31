set feedback off
set sqlformat
set verify off
set pagesize 1000
set lines 500
col n format 99
col sid format 999999
col serial# format 99999
col machine format a35 trunc
col osuser format a20 trunc
col username format a20 trunc
col program format a40 trunc
col status format a10 trunc
col last_time format a16
col event format a50 trunc
col snap format a12
col module format a20 trunc
col sql_id format a15
col secs format 999,999
set feedback on

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &1 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&1 = 0 or inst_id = &1);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: Sessoes Ativas na GV$SESSION
PROMP Instance..: &VNODE
PROMP

select inst_id n, 
sid, 
serial#, 
machine, 
username,
module, 
sql_id,
to_char(NVL(SQL_EXEC_START,PREV_EXEC_START),'dd/Mon hh24:mi:ss') as last_time, 
(sysdate-SQL_EXEC_START)*24*60*60 secs,
''''|| event || '''' as event
from gv$session s
where 1=1
and type = 'USER'
and status = 'ACTIVE'
and (&1 = 0 or inst_id = &1)
order by s.logon_time;

PROMP