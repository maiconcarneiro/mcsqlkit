set feedback off
set sqlformat 
set pages 50
set head on
column module format a20
set lines 200

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

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: TOP 20 SQL Com Maior DB Time
PROMP Snapshots.: &1 &2
PROMP Instance..: &VNODE
PROMP


with time_model as (
select sum(value_diff) as time_total from (
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
     sql_id,
	 elapsed,
	 executions,
	 round( elapsed / (select time_total/1e6 from time_model) * 100 ,2) as perc_total,
	 round(elapsed/executions ,4) as elap_avg,
	 round(cpu_time/executions,4) as cpu_avg,
	 cpu_time,
	 round(buffer_gets/executions,4) as buffer_gets_avg,
	 round(disk_reads/executions,4) as disk_read_avg
from (
	select sql_id,     
		   greatest(sum(executions_delta) ,1) as executions,
		   sum(CPU_TIME_DELTA)/1e6     as cpu_time,
		   sum(ELAPSED_TIME_DELTA)/1e6 as elapsed,
		   sum(ROWS_PROCESSED_DELTA)   as rows_processed,
		   sum(iowait_delta)/1000000   as iowait,
		   sum(BUFFER_GETS_DELTA)      as buffer_gets,
		   sum(DISK_READS_DELTA)       as disk_reads
	  from dba_hist_sqlstat h
	 where 1=1 
	   and (&3 = 0 or h.instance_number = &3)
	   and h.snap_id >  &1 -- O TOP 10 no AWR em HTML desconsidera o snapshot 
	   and h.snap_id <= &2 
	   and h.executions_delta > 0
  group by sql_id
  order by elapsed desc
  )
) x where rownum <= 20
/