set feedback off
set sqlformat 
set pages 50
set head on

set linesize 400

col module format a20
col sql_id format a13
col elapsed heading "Elapsed Time(s)" format 999,999,999.99
col cpu_time heading "CPU Time(s)" format 999,999,999.99
col executions heading "Executions" format 999,999,999,999
col rows1 heading "Rows" format 999,999,999.99
col io_wait heading "IO Wait" format 999,999,999.99
col elap_avg heading "Elap avg (s)" format 999,999.99
col perc_total heading "% of CPU|DB Time" format 999.99
col accum_value heading '% Accum | of total' format 999.99
col cpu_avg heading "CPU avg (s)" format 999,999.99
col buffer_gets_avg heading "Gets avg" format 999,999,999.99
col top heading "#" format 999
col sql_text format A50

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: TOP 20 SQL Com Maior Tempo de CPU
PROMP Snapshots.: &1 &2
PROMP Instance..: &VNODE
PROMP


with time_model as (
select sum(cputime) as cpu_time_total from (
  select m.snap_id, 
         (value - LAG(value, 1, value) OVER (PARTITION BY instance_number ORDER BY snap_id)) AS cputime
    from dba_hist_sys_time_model m
   where m.stat_name = 'DB CPU'
     and m.snap_id between &1 AND &2
	 and (&3 = 0 or m.instance_number = &3)
group by instance_number, snap_id, value
 )
)
select rownum as top, 
       x.sql_id,
       executions,
	   cpu_time,   
	   perc_total,
	   sum (perc_total) over ( order by rownum ) accum_value,
	   cpu_avg,
	   elapsed,
	   elap_avg,
	   buffer_gets_avg,
	   sql_text
from (
select 
     sql_id,
	 cpu_time,
	 executions,
	 round( cpu_time / (select cpu_time_total/1e6 from time_model) * 100 ,2) as perc_total,
	 round(cpu_time/executions,4) as cpu_avg,
	 elapsed,
	 round(elapsed/executions ,4) as elap_avg,
     buffer_gets,
	 buffer_gets/executions as buffer_gets_avg
	 ,translate(sql_text, chr(10) || chr(13) || chr(09), ' ') as sql_text
from (
	select h.sql_id,     
		   greatest(sum(executions_delta) ,1) as executions,
		   sum(CPU_TIME_DELTA)/1e6     as cpu_time,
		   sum(ELAPSED_TIME_DELTA)/1e6 as elapsed,
		   sum(ROWS_PROCESSED_DELTA)   as rows_processed,
		   sum(iowait_delta)/1000000   as iowait,
		   sum(BUFFER_GETS_DELTA)      as buffer_gets,
		   sum(DISK_READS_DELTA)       as disk_reads
		   , dbms_lob.substr(t.sql_text,50,1) as sql_text
	  from dba_hist_sqlstat h
 left join dba_hist_sqltext t on (h.dbid = t.dbid and h.sql_id = t.sql_id)
	 where 1=1 
	   and (&3 = 0 or h.instance_number = &3)
	   and h.snap_id >  &1 -- O TOP 10 no AWR em HTML desconsidera o snapshot 
	   and h.snap_id <= &2 
	   and h.executions_delta > 0
	   and t.command_type not in (47)
  group by h.sql_id, dbms_lob.substr(t.sql_text,50,1)
  order by cpu_time desc
  )
) x where rownum <= 20;

PROMP