set feedback off
set sqlformat
set lines 400
set pages 50
col snap_id        heading "snap1"             format 999999
col snap_id2       heading "snap2"             format 999999
col begin_snap     heading "Start time"        format a15
col begin_time     heading "Begin"             format a5
col end_tie        heading "End"               format a5
col event_name     heading "Wait event"        format a50
col wait_class     heading "Wait class"        format a15
col bg_avg_time_ms heading "BG Avg time (ms)"  format 999,999,999,999.99
col fg_avg_time_ms heading "FG Avg time (ms)"  format 999,999,999,999.99
col avg_time_ms    heading "Avg time (ms)"     format 999,999,999,999.99
col total_waits_bg heading "BG Waits"          format 999,999,999,999
col total_waits_fg heading "FG Waits"          format 999,999,999,999
col total_waits    heading "Total Waits"       format 999,999,999,999
col x              heading ""                  format a1

-- obtem o nome da instancia
@_query_dbid
def _DATE_FILTER=&2/24
@_get_interval

-- resumo do relatorio
PROMP
PROMP Metric....: Event Waits per snapshot (STATSPACK)
PROMP Event.....: &1
PROMP Hours.....: &2  (&_START_DATE to &_END_DATE)
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

set feedback on;

select
  --event_name,
  --wait_class,
  snap_id, snap_id+1 as snap_id2,
  to_char( max(begin_snap) , 'dd/mm/yyyy Dy') as begin_snap,
  to_char( max(begin_snap) , 'hh24:mi') as begin_time,
  to_char( max(end_snap) , 'hh24:mi') as end_tie,
  SUM(total_waits - total_waits_fg) AS total_waits_bg,
  round(AVG( (time_waited - time_waited_fg) /  greatest((total_waits - total_waits_fg),1) ),2) as bg_avg_time_ms,
  '|' as x,
  SUM(total_waits_fg) AS total_waits_fg,
  AVG(round((time_waited_fg / greatest(total_waits_fg,1))*1000 ,4)) AS fg_avg_time_ms,
  '|' as x,
  SUM(total_waits) AS total_waits,
  AVG(round((time_waited / total_waits)*1000 ,4)) AS avg_time_ms,
  '|' as x
from (
select
  s.instance_number inst_id,
  s.snap_id,
  LAG(s.snap_time, 1, null) OVER (PARTITION BY s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id) as begin_snap,
  s.snap_time end_snap,
  event_name,
  wait_class,
  total_waits_fg-lag(total_waits_fg, 1, total_waits_fg) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) total_waits_fg,
  total_waits-lag(total_waits, 1, total_waits) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) total_waits,
  time_waited_fg-lag(time_waited_fg, 1, time_waited_fg) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) time_waited_fg,
  time_waited-lag(time_waited, 1, time_waited) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) time_waited,
  min(s.snap_id) over (partition by s.startup_time, s.instance_number, stats.event_name) min_snap_id
from (
 select dbid, 
        instance_number, 
        snap_id, 
        e.event as event_name, 
        n.wait_class, 
        total_waits_fg, 
        total_waits,
        (time_waited_micro_fg/1000000) as time_waited_fg,
        (time_waited_micro/1000000) as time_waited
  from STATS$SYSTEM_EVENT e
  join V$EVENT_NAME n on (e.event_id = n.event_id)
  where e.event = '&1' -- filtro especifico
) stats, STATS$SNAPSHOT s
 where stats.instance_number=s.instance_number
  and stats.snap_id=s.snap_id
  and stats.dbid=s.dbid
  and s.dbid = (&_SUBQUERY_DBID)
  and s.snap_time >= sysdate - &2/24
  and (&3 = 0 or s.instance_number = &3) 
order by snap_id
 ) 
  where snap_id > min_snap_id 
    and nvl(total_waits,1) > 0
GROUP BY snap_id,
         event_name,
         wait_class
ORDER BY snap_id;