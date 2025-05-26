set feedback off
set sqlformat 
set pages 50
set head on
column module format a20
set lines 400

col elapsed heading "Elapsed Time(s)" format 999,999,999.99
col cpu_time heading "CPU Time(s)" format 999,999,999.99
col executions heading "Executions" format 999,999,999,999
col rows1 heading "Rows" format 999,999,999.99
col io_wait heading "IO Wait" format 999,999,999.99
col elap_avg heading "Elap avg (s)" format 999,999.99
col perc_total heading "% of Total" format 999.99
col cpu_avg heading "CPU avg (s)" format 999,999.99
col buffer_gets_avg heading "Gets avg" format 999,999,999.99
col top heading "Ranking" format 999
col disk_read_avg heading "Disk Read avg" format 999,999,999.99
col sql_text format a50

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: TOP 20 SQL Com Maior DB Time (STATSPACK)
PROMP Snapshots.: &1 &2
PROMP Instance..: &VNODE
PROMP


with time_model as (
 select sum(value_diff) as time_total from (
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
),
sp_sql_stat as (
 select h.sql_id,
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
     and h.snap_id >= &1
	   and h.snap_id <= &2
     and (&3 = 0 or s.instance_number = &3)
order by s.dbid, s.instance_number, s.snap_id
)
select rownum as top, 
       x.* 
from (
select 
   sql_id,
	 elapsed,
	 executions,
	 round( elapsed / (select time_total/1e6 from time_model) * 100 ,2) as perc_total,
	 round(elapsed/executions ,4) as elap_avg,
	 round(cpu_time/executions,4) as cpu_avg,
	 cpu_time,
	 round(buffer_gets/executions,4) as buffer_gets_avg,
	 round(disk_reads/executions,4) as disk_read_avg
	 --,translate(sql_text, chr(10) || chr(13) || chr(09), ' ') as sql_text
from (
	select h.sql_id,     
		   greatest(sum(executions_delta) ,1) as executions,
		   sum(CPU_TIME_DELTA)/1e6     as cpu_time,
		   sum(ELAPSED_TIME_DELTA)/1e6 as elapsed,
		   sum(ROWS_PROCESSED_DELTA)   as rows_processed,
		   sum(iowait_delta)/1000000   as iowait,
		   sum(BUFFER_GETS_DELTA)      as buffer_gets,
		   sum(DISK_READS_DELTA)       as disk_reads
		  -- , dbms_lob.substr(t.text_subset,50,1) as sql_text
	  from sp_sql_stat h
      --join STATS$SQLTEXT t on (h.sql_id = t.sql_id)
	 where 1=1 
	   and executions_delta > 0
    --and begin_interval_time is not null
  group by h.sql_id
           --,dbms_lob.substr(t.text_subset,50,1)
  order by elapsed desc
  )
) x where rownum <= 20;

PROMP
