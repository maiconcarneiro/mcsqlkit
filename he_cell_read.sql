set verify off
set feedback off
alter session set nls_date_format='dd/mm/yyyy';
set sqlformat
set lines 400
set pages 50
col begin_snap  heading "Date"    format a12
col event_name  heading "Event"    format a50
col wait_class  heading "Class"    format a15

col total_waits heading "Waits"   format 999,999,999,999
col avg_hard heading "Hard Disk (ms)" format 999,999.9999
col avg_flash heading "Flash Cache (ms)" format 999,999.9999
col avg_pmem heading "PMEM (ms)" format 999,999,999.9999
col avg_rdma heading "RDMA (ms)" format 999,999,999.9999
col waits_hard heading "Hard Disk (waits)" format 999,999,999,999
col waits_flash heading "Flash Cache (watis)" format 999,999,999,999
col waits_pmem heading "PMEM (waits)" format 999,999,999,999
col waits_rdma heading "RDMA (waits)" format 999,999,999,999

select begin_snap,  
  sum(case when event_name = 'cell single block physical read'              then total_waits else 0 end) as waits_hard,
  sum(case when event_name = 'cell single block physical read: flash cache' then total_waits else 0 end) as waits_flash,
  sum(case when event_name = 'cell single block physical read: RDMA'        then total_waits else 0 end) as waits_rdma,
  sum(case when event_name = 'cell single block physical read: pmem cache'  then total_waits else 0 end) as waits_pmem,
  sum(case when event_name = 'cell single block physical read'              then avg_time_ms else 0 end) as avg_hard,
  sum(case when event_name = 'cell single block physical read: flash cache' then avg_time_ms else 0 end) as avg_flash,
  sum(case when event_name = 'cell single block physical read: RDMA'        then avg_time_ms else 0 end) as avg_rdma,
  sum(case when event_name = 'cell single block physical read: pmem cache'  then avg_time_ms else 0 end) as avg_pmem
from (
select
  trunc(begin_snap) as begin_snap,
  event_name,
  wait_class,
  SUM(total_waits) AS total_waits,
  AVG((time_waited/total_waits)*1000) AS avg_time_ms
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
 select dbid, instance_number, snap_id, event_name, wait_class, total_waits, (time_waited_micro/1000000) time_waited
  from dba_hist_system_event
  where event_name like 'cell single block physical read%' -- filtro especifico
) stats, dba_hist_snapshot s
 where stats.instance_number=s.instance_number
  and stats.snap_id=s.snap_id
  and stats.dbid=s.dbid
  and s.dbid=(select dbid from v$database)
  and s.begin_interval_time >= trunc(sysdate) - &1
order by snap_id
) where snap_id > min_snap_id 
        and nvl(total_waits,1) > 0
GROUP BY trunc(begin_snap),
         event_name,
         wait_class
)
group by begin_snap
order by 1;

set feedback on
