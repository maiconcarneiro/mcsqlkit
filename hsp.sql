SET FEEDBACK OFF
SET SQLFORMAT
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';
SET VERIFY OFF
SET PAGES 50
SET LINES 400
SET FEEDBACK ON

col con_id         HEADING "Con|ID"                format 999
col Data           HEADING "Data"                  format a10
col menor          HEADING "Min|hh:mi"             format a6
col maior          HEADING "Max|hh:mi"             format a6
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
-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: Historico do SQL_ID por Data e Plan Hash Value
PROMP SQL ID....: &1
PROMP Qt. Dias..: &2
PROMP Instance..: &VNODE
PROMP

select plan_hash_value                                                                 as plan_hash_value,
       trunc(b.begin_interval_time)                                                    as data,
       to_char(min(b.begin_interval_time),'hh24:mi')                                   as menor,
       to_char(max(b.end_interval_time),'hh24:mi')                                     as maior,
       sum(executions_delta)                                                           as Execs,
       sum(rows_processed_delta)                   / greatest(sum(executions_delta),1) as rows_processed,
       sum(disk_reads_delta)                       / greatest(sum(executions_delta),1) as Disk_Reads,
       sum(io_interconnect_bytes_delta/1024/1024)  / greatest(sum(executions_delta),1) as io_mbytes,
       sum(iowait_delta/1000)                      / greatest(sum(executions_delta),1) as iowait_delta,
       sum(buffer_gets_delta)                      / greatest(sum(executions_delta),1) as Buffer_Gets,
       sum(cpu_time_delta/1000)                    / greatest(sum(executions_delta),1) as CPU_Time,
       sum(elapsed_time_delta/1000)                / greatest(sum(executions_delta),1) as Elapsed_Time
from dba_hist_sqlstat a
join dba_hist_snapshot b on (a.dbid = b.dbid and a.snap_id = b.snap_id and a.instance_number = b.instance_number)
where 1=1
and sql_id in ('&1')
--and executions_delta > 0
and b.begin_interval_time >= trunc(sysdate) - &2
and (&3 = 0 or b.instance_number = &3)
group by trunc(b.begin_interval_time), plan_hash_value
order by data, plan_hash_value;
