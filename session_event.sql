set lines 400
set pages 50
col wait_class format a20
col event format a40
col total_waits heading 'Total Waits' format 999,999,999,999,999
col time_waited heading 'Time Waited (ms)' format 999,999,999,999,999
col average_wait heading 'AVG Time (ms)' format 999,999,999.99
col pct_total heading '% of Total' format 999.99

PROMP
PROMP Session Info:
set feedback off;
select inst_id, sid, serial#, program, module, machine, username, osuser
from gv$session
where inst_id = &1 
  and sid = &2
;

PROMP
PROMP Session Event:
set feedback on;
with session_event as (
select wait_class, 
       event, 
       total_waits, 
       time_waited, 
       average_wait
from GV$SESSION_EVENT 
where 1=1
  and inst_id = &1
  and sid = &2
  and wait_class <> 'Idle'
)
select x.*, 
       round(x.time_waited / (select sum(time_waited) from session_event) * 100,2) as pct_total
from session_event x
order by time_waited desc;