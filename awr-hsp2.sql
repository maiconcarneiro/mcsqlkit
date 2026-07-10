/*
 sctipt: awr-hsp.sql
 author: Maicon Carneiro (dibiei.blog)
*/


column NODE new_value VNODE 
column CNAME new_value VCNAME 
SET termout off
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SELECT sys_context('USERENV','CON_NAME') as CNAME FROM dual;
SET termout ON

PROMP
PROMP Metric....: History of SQL per Date and Plan Hash Value (AWR)
PROMP SQL ID....: &1
PROMP Qt. Days..: &2
PROMP Instance..: &VNODE
PROMP

SET FEEDBACK OFF
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';
SET VERIFY OFF
SET PAGES 50
set linesize 400
SET FEEDBACK ON

col con_id         HEADING "Con|ID"                format 999
col report_date    HEADING "Date"                  format a10
col min_time       HEADING "Min|hh:mi"             format a6
col max_time       HEADING "Max|hh:mi"             format a6
col Buffer_Gets    HEADING "Buffer Gets"     format 999,999,999,999.99
col Elapsed_Time   HEADING "Elapsed | Time (ms)" format 999,999,999,999.99
col Execs          HEADING "Execs"                 format 999,999,999,999
col Disk_Reads     HEADING "Disk Reads"      format 999,999,999,999.99
col io_mbytes      HEADING "IO MBPS"         format 999,999,999,999.99
col rows_processed HEADING "Rows"  format 999,999,999,999.99
col iowait_delta   HEADING "IO Wait (ms)"      format 999,999,999,999.99
col CPU_Time       HEADING "CPU Time (ms)"     format 999,999,999,999.99
col sql_id         HEADING  "SQL Id"               format a18
col plan_hash_value HEADING "Plan|Hash Value"      format 99999999999999

select plan_hash_value                                                                 as plan_hash_value,
       trunc(b.begin_interval_time)                                                    as report_date,
       to_char(min(b.begin_interval_time),'hh24:mi')                                   as min_time,
       to_char(max(b.end_interval_time),'hh24:mi')                                     as max_time,
       --sum(executions_delta)                                                           as Execs,
       sum(rows_processed_delta)                   / greatest(sum(executions_delta),1) as rows_processed,
       sum(disk_reads_delta)                       / greatest(sum(executions_delta),1) as Disk_Reads,
       sum(io_interconnect_bytes_delta/1024/1024)  / greatest(sum(executions_delta),1) as io_mbytes,
       sum(iowait_delta/1000)                      / greatest(sum(executions_delta),1) as iowait_delta,
       sum(buffer_gets_delta)                      / greatest(sum(executions_delta),1) as Buffer_Gets,
       sum(cpu_time_delta/1000)                    / greatest(sum(executions_delta),1) as CPU_Time,
       sum(elapsed_time_delta/1000)                / greatest(sum(executions_delta),1) as Elapsed_Time,
       sum(io_offload_elig_bytes_delta) - sum(io_interconnect_bytes_delta) as io_offload_bytes,
       decode(io_offload_elig_bytes_delta, 0, 0, 100 *(io_offload_elig_bytes_delta - io_interconnect_bytes) 
         / decode(io_offload_elig_bytes_delta,0, 1, io_offload_elig_bytes_delta)
        ) io_saved_perc,
from dba_hist_sqlstat a
join dba_hist_snapshot b on (a.dbid = b.dbid and a.snap_id = b.snap_id and a.instance_number = b.instance_number)
where 1=1
and sql_id in ('dscrhpdxkfj5c')
-- and executions_delta > 0
--and b.begin_interval_time >= trunc(sysdate) - &2
and (&3 = 0 or b.instance_number = &3)
--and b.dbid = (&_SUBQUERY_DBID)
group by trunc(b.begin_interval_time), plan_hash_value
order by report_date, plan_hash_value;

col begin_time format a20
col io_offload_elig_mbytes format 999,999,999,999.99
col app_wait_time format 999,999,999,999.99
select a.snap_id, 
       to_char(b.begin_interval_time,'yyyy-mm-dd hh24:mi') as begin_time,
       --b.begin_interval_time,
       --plan_hash_value, 
       --(rows_processed_delta)                   / greatest((executions_delta),1) as rows_processed,
       (disk_reads_delta)                       / greatest((executions_delta),1) as Disk_Reads,
       (io_interconnect_bytes_delta/1024/1024)  / greatest((executions_delta),1) as io_mbytes,
       (iowait_delta/1000)                      / greatest((executions_delta),1) as iowait_delta,
       (buffer_gets_delta)                      / greatest((executions_delta),1) as Buffer_Gets,
       (cpu_time_delta/1000)                    / greatest((executions_delta),1) as CPU_Time,
       (apwait_delta/1000)                      / greatest((executions_delta),1) as app_wait_time,
       (elapsed_time_delta/1000)                / greatest((executions_delta),1) as Elapsed_Time,
       io_interconnect_bytes_delta/1024/1024 as io_mbytes,
       io_offload_elig_bytes_delta/1024/1024 as io_offload_elig_mbytes
from dba_hist_sqlstat a
join dba_hist_snapshot b on (a.dbid = b.dbid and a.snap_id = b.snap_id and a.instance_number = b.instance_number)
where sql_id = 'dscrhpdxkfj5c'
order by a.snap_id, plan_hash_value;