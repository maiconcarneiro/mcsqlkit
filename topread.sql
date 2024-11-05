/*
 Maicon Carneiro - 30/12/2023
 script : topread.sql
 sintaxe: @topread <begin snap> <end snap> <inst id>
 exemplo: @topread 141817 141821 1 (inst id = 0 para considerar todo o cluster)
*/

set verify off
set feedback off
set sqlformat 
set pages 50
set head on
column module format a20
set lines 400

col top heading "Ranking" format 999
col sql_id heading "SQL Id" format a20 
col elapsed heading "Elapsed | Time(s)"  format 999,999,999.99
col executions heading "Executions" format 999,999,999
col disk_reads heading "Disk Reads (blocks)" format 999,999,999,999
col perc_total heading "% of|Total" format 999.99
col perc_cpu heading "% CPU" format 999.99
col perc_io heading  "% IO"  format 999.99
col disk_read_avg heading "Reads avg | per Exec" format 999,999,999.99
col sql_text format a50

-- get the instance name
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- report summary
PROMP
PROMP Metrica...: TOP 20 SQL Com Maior "Disk Physical Reads"
PROMP Snapshots.: &1 &2
PROMP Instance..: &VNODE
PROMP

-- calculate the total of Physical Reads from instance.
with time_model as (
select sum(value_diff) as reads_total from (
  select m.snap_id, 
         (value - LAG(value, 1, value) OVER (PARTITION BY instance_number ORDER BY snap_id)) AS value_diff
    from dba_hist_sysstat m
   where m.stat_name = 'physical reads'
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
	 disk_reads,
	 executions,
	 round(disk_reads/executions,4) as disk_read_avg,
	 round( disk_reads / (select reads_total from time_model) * 100 ,2) as perc_total,
	 elapsed,
	 round( cpu_time / elapsed * 100 ,2) as perc_cpu,
	 round( iowait   / elapsed * 100 ,2) as perc_io
	 ,translate(sql_text, chr(10) || chr(13) || chr(09), ' ') as sql_text
from (
	select h.sql_id,     
		   greatest(sum(executions_delta) ,1) as executions,
		   sum(CPU_TIME_DELTA)/1e6     as cpu_time,
		   sum(ELAPSED_TIME_DELTA)/1e6 as elapsed,
		   sum(ROWS_PROCESSED_DELTA)   as rows_processed,
		   sum(iowait_delta)/1000000   as iowait,
		   sum(BUFFER_GETS_DELTA)      as buffer_gets,
		   sum(DISK_READS_DELTA)       as disk_reads,
		   dbms_lob.substr(t.sql_text,50,1) as sql_text
	  from dba_hist_sqlstat h
 left join dba_hist_sqltext t on (h.dbid = t.dbid and h.sql_id = t.sql_id)
	 where 1=1 
	   and (&3 = 0 or h.instance_number = &3)
	   and h.snap_id >  &1 -- O TOP 10 no AWR em HTML desconsidera o snapshot 
	   and h.snap_id <= &2 
	   and h.executions_delta > 0
  group by h.sql_id, dbms_lob.substr(t.sql_text,50,1)
  order by disk_reads desc
  )
) x where rownum <= 20
/

PROMP
PROMP How to Interpret the "SQL ordered by Physical Reads (UnOptimized)" Section in AWR Reports (11.2 onwards) for Smart Flash Cache Database (Doc ID 1466035.1)
PROMP