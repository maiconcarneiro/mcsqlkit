set sqlformat
set lines 400
set pages 50
col snap_id     heading "Snap Id"           format 999999
col begin_snap  heading "Data"              format a20
col event_name  heading "Evento"            format a50
col wait_class  heading "Classe"            format a15
col total_waits heading "Qtde. Waits"       format 999,999,999,999
col avg_time_ms heading "Tempo Médio (ms)"  format 999,999,999,999.99
select
  snap_id,
  inst_id,
  to_char(begin_snap,'dd/mm/yyyy hh24:mi:ss') as begin_snap,
  event_name,
  wait_class,
  SUM(total_waits) AS total_waits,
  AVG(round((time_waited/total_waits)*1000)) AS avg_time_ms
from (
select
  s.instance_number inst_id,
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
  where event_name = '&2' -- filtro especifico
) stats, dba_hist_snapshot s
 where stats.instance_number=s.instance_number
  and stats.snap_id=s.snap_id
  and stats.dbid=s.dbid
  and s.begin_interval_time >= sysdate - &1/24
order by snap_id
) where snap_id > min_snap_id 
        and nvl(total_waits,1) > 0
GROUP BY snap_id,
         inst_id,
         begin_snap,
         event_name,
         wait_class
ORDER BY snap_id, inst_id;