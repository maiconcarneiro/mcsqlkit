--set sqlformat ansiconsole
set pagesize 9
set feedback off
set verify off
select
 case wait_rank when 1 then inst_id end "Inst Num",
 case wait_rank when 1 then snap_id end "Snap Id",
 case wait_rank when 1 then begin_snap end "Begin Snap",
 case wait_rank when 1 then end_snap end "End Snap",
 event_name "Event",
 total_waits "Waits",
 time_waited "Time(s)",
 round((time_waited/total_waits)*1000) "Avg wait(ms)",
 round((time_waited/db_time)*100, 2) "% DB time",
 substr(wait_class, 1, 15) "Wait Class"
from (
select
  inst_id,
  snap_id, to_char(begin_snap, 'DD-MM-YY hh24:mi:ss') begin_snap,
  to_char(end_snap, 'hh24:mi:ss') end_snap,
  event_name,
  wait_class,
  total_waits,
  time_waited,
  dense_rank() over (partition by inst_id, snap_id order by time_waited desc)-1 wait_rank,
  max(time_waited) over (partition by inst_id, snap_id) db_time
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
     select dbid, instance_number, snap_id, event_name, wait_class, total_waits_fg total_waits, round(time_waited_micro_fg/1000000, 2) time_waited
       from dba_hist_system_event
      where wait_class not in ('Idle', 'System I/O')
  union all
     select dbid, instance_number, snap_id, stat_name event_name, null wait_class, null total_waits, round(value/1000000, 2) time_waited
       from dba_hist_sys_time_model
      where stat_name in ('DB CPU', 'DB time')
    ) stats, dba_hist_snapshot s
 where stats.instance_number=s.instance_number
  and stats.snap_id=s.snap_id
  and stats.dbid=s.dbid
  and s.dbid=(select dbid from v$database)
  --and s.instance_number=1
  and s.begin_interval_time >= (sysdate - &1)
) where snap_id > min_snap_id 
    and nvl(total_waits,1) > 0
) where event_name!='DB time' 
    and wait_rank <= 5
order by inst_id, snap_id;
