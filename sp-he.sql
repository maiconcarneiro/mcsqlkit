set verify off
set feedback off
alter session set nls_date_format='dd/mm/yyyy';
set sqlformat
set lines 400
set pages 50
col begin_snap     heading "Date"              format a10
col event_name     heading "Event"             format a30 trunc
col wait_class     heading "Class"             format a15
col bg_avg_time_ms heading "BG Avg time (ms)"  format 999,999,999,999.99
col fg_avg_time_ms heading "FG Avg time (ms)"  format 999,999,999,999.99
col avg_time_ms    heading "Avg time (ms)"     format 999,999,999,999.99
col total_waits_bg heading "BG Waits"          format 999,999,999,999
col total_waits_fg heading "FG Waits"          format 999,999,999,999
col total_waits    heading "Total Waits"       format 999,999,999,999
col min_wait_ms    heading "Min Time (ms)"     format 999,999.9999
col max_wait_ms    heading "Max Time (ms)"     format 999,999,999.9999
col x              heading "|"                 format a1

-- obtem o nome da instancia
@_query_dbid
def _DATE_FILTER=&2
@_get_interval

-- resumo do relatorio
PROMP
PROMP Metric....: History of Event wais per day (STATSPACK)
PROMP Event.....: &1
PROMP Days......: &2 (&_START_DATE_TRUNC to &_END_DATE)
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

set feedback on

select
  trunc(begin_snap) as begin_snap,
  event_name,
  wait_class,
  '|' as x,
  SUM(total_waits - total_waits_fg) AS total_waits_bg,
  round(AVG( (time_waited - time_waited_fg) /  greatest((total_waits - total_waits_fg),1) ),2) as bg_avg_time_ms,
  '|' as x,
  SUM(total_waits_fg) AS total_waits_fg,
  AVG(round((time_waited_fg / greatest(total_waits_fg,1))*1000 ,4)) AS fg_avg_time_ms,
  '|' as x,
  SUM(total_waits) AS total_waits,
  AVG(round((time_waited / total_waits)*1000 ,4)) AS avg_time_ms,
  MIN((time_waited/total_waits)*1000) AS min_wait_ms,
  MAX((time_waited/total_waits)*1000) AS max_wait_ms,
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
  where e.event = '&1'
) stats, STATS$SNAPSHOT s
 where stats.instance_number=s.instance_number
  and stats.snap_id=s.snap_id
  and stats.dbid=s.dbid
  and s.dbid = (&_SUBQUERY_DBID)
  and s.snap_time >= trunc(sysdate) - &2
  and (&3 = 0 or s.instance_number = &3) 
  --and s.snap_id between 31 and 67 -- test
order by snap_id
) where snap_id > min_snap_id 
        and nvl(total_waits,1) > 0
GROUP BY trunc(begin_snap),
         event_name,
         wait_class
ORDER BY 1;

