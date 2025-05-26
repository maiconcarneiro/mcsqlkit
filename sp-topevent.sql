-- 30/12/2023 - Maicon Carneiro - Criação do Script para exibir o TOP 20 eventos do AWR
-- 25/04/2024 - Maicon Carneiro - Correção do calculo de "% of Total" e ajuste do begin_snap_id
-- 23/05/2023 - Maicon Carneiro - Script "sp-topevent" criado com base no "topevent" e adaptado para usar STATSPACK

set feedback off
set sqlformat
set pagesize 40
set verify off
col avg_time heading "Avg wait(ms)" format 999,999.99
col dbtime_percent heading "% DB time" format 99.99
col wait_class heading "Wait Class" format a20
col time_waited heading "Time(s)" format 999,999,999,999.99
col avg_time heading "Avg Time(ms)" format 999,999.99
col total_waits heading "Waits" format 999,999,999,999,999
col event_name heading "Event Name" format a40

-- get the instance name
@_query_dbid
@_get_interval_snap-sp &1 &2

-- report summary
PROMP
PROMP Report....: Top Foreground Wait Events (STATSPACK)
PROMP Snaps.....: &1 &2 (&_START_DATE to &_END_DATE)
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

with time_model as (
 select sum(value_diff)/1000000 as time_total from (
    select s.snap_id, 
           (value - LAG(value, 1, value) OVER (PARTITION BY s.startup_time, s.instance_number ORDER BY s.snap_id)) AS value_diff
    from STATS$SNAPSHOT s
    join STATS$SYS_TIME_MODEL m on (s.snap_id = m.snap_id and s.dbid = m.dbid and s.instance_number = m.instance_number)
    join STATS$TIME_MODEL_STATNAME n on (m.stat_id=n.stat_id)
    where 1=1
    and n.stat_name = 'DB time'
    and s.snap_id between &1 and &2
	and (&3 = 0 or s.instance_number = &3)
    group by s.snap_id, s.startup_time, s.instance_number, value
  )
)
select rownum as top,
       x.*
from (
select
  event_name,
  nvl(wait_class,'DB CPU') AS wait_class,
  sum(total_waits) as total_waits,
  sum(time_waited) as time_waited,
  round(sum(time_waited*1000)/sum(total_waits) ,4) as avg_time
 ,round( sum(time_waited)/(select time_total from time_model) * 100 ,4) as dbtime_percent
from (
     select
       s.instance_number inst_id,
       s.snap_id,
       LAG(s.snap_time, 1, null) OVER (PARTITION BY s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id) as begin_snap,
       s.snap_time as end_snap,
       event_name,
       wait_class,
       total_waits-lag(total_waits, 1, total_waits) over
        (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) total_waits,
       time_waited-lag(time_waited, 1, time_waited) over
        (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) time_waited,
       min(s.snap_id) over (partition by s.startup_time, s.instance_number, stats.event_name) min_snap_id
     from (
          select dbid, instance_number, snap_id, e.event as event_name, wait_class, total_waits_fg as total_waits, time_waited_micro_fg/1000000 time_waited
            from STATS$SYSTEM_EVENT e
            join V$EVENT_NAME n on (e.event_id = n.event_id)
           where n.wait_class not in ('Idle', 'System I/O')
       union all
          select dbid, instance_number, snap_id, stat_name as event_name, null wait_class, null total_waits, value/1000000 time_waited
            from STATS$SYS_TIME_MODEL m
            join STATS$TIME_MODEL_STATNAME n on (m.stat_id=n.stat_id)
           where n.stat_name in ('DB CPU', 'DB time')
         ) stats, STATS$SNAPSHOT s
      where stats.instance_number=s.instance_number
       and stats.snap_id=s.snap_id
       and stats.dbid=s.dbid
       and s.dbid = (&_SUBQUERY_DBID)
       and (&3 = 0 or s.instance_number = &3)
       and s.snap_id >= &1
       and s.snap_id <= &2
    ) 
  where 1=1
    and snap_id > min_snap_id 
    and nvl(total_waits,1) > 0
	and event_name!='DB time' 
group by event_name, nvl(wait_class,'DB CPU')
order by time_waited desc
) x
where rownum <= 20
;

PROMP