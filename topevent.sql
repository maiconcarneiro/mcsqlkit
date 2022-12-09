set sqlformat
set pagesize 10
set feedback off
set verify off
col avg_time heading "Avg wait(ms)" format 999,999.99
col dbtime_percent heading "% DB time" format 999.99
col wait_class heading "Wait Class" format a20
col time_waited heading "Time(s)" format 999,999,999,999
col total_waits heading "Waits" format 999,999,999,999,999
col event_name heading "Event Name" format a60
select
 wait_class,
 event_name,
 total_waits,
 time_waited,
 (time_waited/total_waits)*1000 avg_time,
 round((time_waited/db_time)*100, 2) dbtime_percent
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
          select dbid, instance_number, snap_id, event_name, wait_class, total_waits_fg total_waits, time_waited_micro_fg/1000000 time_waited
            from dba_hist_system_event
           where wait_class not in ('Idle', 'System I/O')
       union all
          select dbid, instance_number, snap_id, stat_name event_name, null wait_class, null total_waits, value/1000000 time_waited
            from dba_hist_sys_time_model
           where stat_name in ('DB CPU', 'DB time')
         ) stats, dba_hist_snapshot s
      where stats.instance_number=s.instance_number
       and stats.snap_id=s.snap_id
       and stats.dbid=s.dbid
       and s.dbid=(select dbid from v$database)
       and (&3 = 0 or s.instance_number = &3)
       and s.snap_id >  &1 -- O TOP 10 no AWR em HTML desconsidera o snapshot 
       and s.snap_id <= &2 
    ) 
  where snap_id > min_snap_id 
    and nvl(total_waits,1) > 0
  ) 
  where event_name!='DB time' 
    and wait_rank <= 10
order by inst_id, snap_id;
