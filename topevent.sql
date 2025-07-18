-- 30/12/2023 - Maicon Carneiro - Criação do Script para exibir o TOP 20 eventos do AWR
-- 25/04/2024 - Maicon Carneiro - Correção do calculo de "% of Total" e ajuste do begin_snap_id

set feedback off
set sqlformat
set pagesize 40
set verify off
set lines 400
col avg_time heading "Avg wait(ms)" format 999,999.99
col dbtime_percent heading "% DB time" format 99.99
col wait_class heading "Wait Class" format a20
col time_waited heading "Time(s)" format 999,999,999,999
col avg_time heading "Avg Time(ms)" format 999,999.99
col total_waits heading "Waits" format 999,999,999,999,999
col event_name heading "Event Name" format a50

with time_model as (
select sum(value_diff)/1000000 as time_total from (
  select m.snap_id, 
         (value - LAG(value, 1, value) OVER (PARTITION BY instance_number ORDER BY snap_id)) AS value_diff
    from dba_hist_sys_time_model m
   where m.stat_name = 'DB time'
     and m.snap_id between &1 AND &2
	 and (&3 = 0 or m.instance_number = &3)
group by instance_number, snap_id, value
 )
)
select rownum as top,
       x.*
from (
select
  event_name,
  nvl(wait_class,'DB CPU') AS wait_class,
  sum(total_waits) total_waits,
  sum(time_waited) time_waited,
  (sum(time_waited*1000)/sum(total_waits)) as avg_time,
  round( sum(time_waited)/(select time_total from time_model) * 100 ,2) as dbtime_percent
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
       and s.dbid = (&_SUBQUERY_DBID)
       and (&3 = 0 or s.instance_number = &3)
       and s.snap_id >=  &1 -- O TOP 10 Wait Event no AWR em HTML considera o snapshot inicial (diferente do TOP SQL)
       and s.snap_id <= &2 
    ) 
  where snap_id > min_snap_id 
    and nvl(total_waits,1) > 0
	and event_name!='DB time' 
group by event_name, nvl(wait_class,'DB CPU')
order by time_waited desc
) x
where rownum <= 20
;

PROMP