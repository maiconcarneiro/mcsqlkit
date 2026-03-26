/*
 script: awr-topelap.sql
 author: Maicon Carneiro (dibiei.blog)
*/


-- get instance names
column NODE new_value VNODE 
column CNAME new_value VCNAME 
SET termout off
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SELECT sys_context('USERENV','CON_NAME') as CNAME FROM dual;
SET termout ON

-- report summary
PROMP
PROMP Metricc...: TOP 20 SQL By Elapsed Time
PROMP Snapshots.: &1 &2
PROMP Instance..: &VNODE
PROMP

set feedback off
set sqlformat 
set pages 50
set head on
set linesize 400

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
	   and h.snap_id >  &1 -- based on AWR HTML that do not consider the first snap_id from the interval.
	   and h.snap_id <= &2 
	   and h.executions_delta > 0
  group by h.sql_id, dbms_lob.substr(t.sql_text,50,1)
  order by elapsed desc
  )
) x where rownum <= 20;

PROMP
