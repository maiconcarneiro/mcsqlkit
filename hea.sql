set sqlformat
set lines 400
set pages 50
col snap_id     heading "snap1"           format 999999
col snap_id2 heading "snap2" format 999999
col begin_snap  heading "Start time"              format a15
col begin_time  heading "Begin"              format a5
col end_tie  heading "End"              format a5
col event_name  heading "Wait event"            format a50
col wait_class  heading "Wait class"            format a15
col total_waits heading "Waits (qtde)"             format 999,999,999,999
col avg_time_ms heading "Avg time (ms)"     format 999,999,999,999.99

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: Event Wait AVG Time (ms) per snapshot
PROMP Evento....: &1
PROMP Qt. Horas.: &2 
PROMP Instance..: &VNODE
PROMP

select
  snap_id, snap_id+1 as snap_id2,
  to_char( max(begin_snap) , 'dd/mm/yyyy Dy') as begin_snap,
  to_char( max(begin_snap) , 'hh24:mi') as begin_time,
  to_char( max(end_snap) , 'hh24:mi') as end_tie,
  SUM(total_waits) AS total_waits,
  AVG(round((time_waited/total_waits)*1000 ,4)) AS avg_time_ms,
  event_name,
  wait_class
from (
select
  s.snap_id,
  s.begin_interval_time begin_snap,
  s.end_interval_time end_snap,
  event_name,
  wait_class,
  total_waits-lag(total_waits, 1, total_waits) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) total_waits,
  time_waited-lag(time_waited, 1, time_waited) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) time_waited,
  min(s.snap_id) over (partition by s.startup_time, s.instance_number, stats.event_name) min_snap_id
from (
 select dbid, instance_number, snap_id, event_name, wait_class, total_waits, round(time_waited_micro/1000000, 2) time_waited
  from dba_hist_system_event
  where event_name = '&1' -- filtro especifico
) stats, dba_hist_snapshot s
 where stats.instance_number=s.instance_number
  and stats.snap_id=s.snap_id
  and stats.dbid=s.dbid
  and s.begin_interval_time >= sysdate - &2/24
  and (&3 = 0 or s.instance_number = &3) 
order by snap_id
 ) 
  where snap_id > min_snap_id 
    and nvl(total_waits,1) > 0
GROUP BY snap_id,
         event_name,
         wait_class
ORDER BY snap_id;