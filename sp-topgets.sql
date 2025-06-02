set feedback off
set sqlformat 
set pages 50
set head on
column module format a20
set lines 400

col elapsed heading "Elapsed Time(s)" format 999,999,999.99
col cpu_time heading "CPU Time(s)" format 999,999,999.99
col executions heading "Executions" format 999,999,999,999
col buffer_gets heading "Buffer Gets" format 999,999,999,999
col io_wait heading "IO Wait" format 999,999,999.99
col elap_avg heading "Elap avg (s)" format 999,999.99
col perc_total heading "% of Total" format 999.99
col cpu_avg heading "CPU avg (s)" format 999,999.99
col buffer_gets_avg heading "Gets avg|(per exec)" format 999,999,999.99
col top heading "Ranking" format 999
col perc_total heading "% of|Total Reads" format 999.99
col perc_cpu heading "% running|in CPU" format 999.99
col perc_io heading  "% waiting|for IO"  format 999.99
col sql_text format a50

-- get instance name
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- report summary
PROMP
PROMP Report....: TOP 20 SQL ordered by Gets (STATSPACK)
PROMP Snapshots.: &1 &2
PROMP Instance..: &VNODE
PROMP


with time_model as (
select sum(value_diff) as value_total from (
  select m.snap_id, 
         (value - LAG(value, 1, value) OVER (PARTITION BY m.name, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS value_diff
    from STATS$SNAPSHOT s
    join STATS$SYSSTAT m on (s.snap_id = m.snap_id and s.dbid = m.dbid and s.instance_number = m.instance_number)
   where m.name = 'session logical reads' -- (db block gets + consistent gets)
     and m.snap_id between &1 AND &2      
	 and (&3 = 0 or m.instance_number = &3)
 )
),
sp_sql_stat as (
 select h.sql_id,
        h.old_hash_value,
        s.instance_number,
        s.snap_id, 
        LAG(s.snap_time, 1, null) OVER (PARTITION BY h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id) as begin_interval_time,
        s.snap_time as end_interval_time,
        executions,
        (executions - LAG(executions, 1, null) OVER (PARTITION BY h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS executions_delta,
        fetches,
        (fetches - LAG(fetches, 1, null) OVER (PARTITION BY  h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS fetches_delta,
        buffer_gets,
        (buffer_gets - LAG(buffer_gets, 1, null) OVER (PARTITION BY  h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS buffer_gets_delta,
        disk_reads,
        (disk_reads - LAG(disk_reads, 1, null) OVER (PARTITION BY  h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS disk_reads_delta,
        rows_processed,
        (rows_processed - LAG(rows_processed, 1, null) OVER (PARTITION BY  h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS rows_processed_delta,
        cpu_time,
        (cpu_time - LAG(cpu_time, 1, null) OVER (PARTITION BY  h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS cpu_time_delta,
        elapsed_time,
        (elapsed_time - LAG(elapsed_time, 1, null) OVER (PARTITION BY  h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS elapsed_time_delta,
        user_io_wait_time,
        (user_io_wait_time - LAG(user_io_wait_time, 1, null) OVER (PARTITION BY  h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS iowait_delta,
        application_wait_time,
        (application_wait_time - LAG(application_wait_time, 1, null) OVER (PARTITION BY  h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS application_wait_time_delta,
        parse_calls,
        (parse_calls - LAG(parse_calls, 1, null) OVER (PARTITION BY  h.sql_id, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS parse_calls_delta
    from STATS$SNAPSHOT s
    join STATS$SQL_SUMMARY h on (s.snap_id = h.snap_id and s.dbid = h.dbid and s.instance_number = h.instance_number)
   where 1=1
     and h.snap_id between &1 and &2 
     and (&3 = 0 or s.instance_number = &3)
order by s.dbid, s.instance_number, s.snap_id
)
select rownum as top, 
       x.* 
from (
select sql_id,
       buffer_gets,
       executions,
       round(buffer_gets/executions,4) as buffer_gets_avg,
       round( buffer_gets / (select value_total from time_model) * 100 ,2) as perc_total,
       elapsed,
       round(elapsed/executions ,4) as elap_avg,
       round( cpu_time / elapsed * 100 ,2) as perc_cpu,
	round( iowait   / elapsed * 100 ,2) as perc_io,
       cpu_time,
       round(cpu_time/executions,4) as cpu_avg,
       old_hash_value
from (
	select h.sql_id, h.old_hash_value,  
		greatest(sum(executions_delta) ,1) as executions,
		sum(CPU_TIME_DELTA)/1e6            as cpu_time,
		sum(ELAPSED_TIME_DELTA)/1e6        as elapsed,
		sum(ROWS_PROCESSED_DELTA)          as rows_processed,
		sum(iowait_delta)/1000000          as iowait,
		sum(BUFFER_GETS_DELTA)             as buffer_gets,
		sum(DISK_READS_DELTA)              as disk_reads
	  from sp_sql_stat h       
	 where executions_delta > 0
  group by h.sql_id, old_hash_value
  order by buffer_gets desc
  )
) x where rownum <= 20;

PROMP
