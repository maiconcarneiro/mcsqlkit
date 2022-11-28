SET FEEDBACK OFF
SET SQLFORMAT
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';
SET VERIFY OFF
SET PAGES 50
SET LINES 400
SET FEEDBACK ON

col Data           HEADING "Data"                  format a10
col Inicio         HEADING "Inicio"                format a10
col Final          HEADING "Final"                 format a10
col Buffer_Gets    HEADING "Buffer Gets avg"       format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed Time avg ms)" format 999,999,999,999.99
col Execs          HEADING "Execs"                 format 999,999,999,999
col Disk_Reads     HEADING "(Disk Reads avg)"      format 999,999,999,999.99
col rows_processed HEADING "(Rows Processed avg)"  format 999,999,999,999.99
col CPU_Time       HEADING "(CPU Time avg ms)"     format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed ms avg)"      format 999,999,999,999.99
col sql_id         HEADING  "SQL Id"               format a20
col offload        HEADING  "(Offload)"            format a10
col io_saved_perc  HEADING  "(IO Saved %)"         format 999,999.99

select sql_id,
trunc(b.begin_interval_time) data,
to_char(min(b.begin_interval_time),'hh24:mi:ss')    as Inicio,
to_char(max(b.end_interval_time),'hh24:mi:ss')      as Final,
count(distinct(PLAN_HASH_VALUE)) as planos,
sum(executions_delta)                                            as Execs,
sum(buffer_gets_delta)       / greatest(sum(executions_delta),1) as Buffer_Gets,
sum(disk_reads_delta)        / greatest(sum(executions_delta),1) as Disk_Reads,
sum(rows_processed_delta)    / greatest(sum(executions_delta),1) as rows_processed,
sum(cpu_time_delta/1000)     / greatest(sum(executions_delta),1) as CPU_Time,
sum(elapsed_time_delta/1000) / greatest(sum(executions_delta),1) as Elapsed_Time,
       decode(sum(IO_OFFLOAD_ELIG_BYTES_DELTA), 0, 'No', 'Yes')  offload,
       decode(sum(IO_OFFLOAD_ELIG_BYTES_DELTA), 0, 0, 100 *(sum(IO_OFFLOAD_ELIG_BYTES_DELTA) - sum(IO_INTERCONNECT_BYTES_DELTA)) 
         / decode(sum(IO_OFFLOAD_ELIG_BYTES_DELTA),0, 1, sum(IO_OFFLOAD_ELIG_BYTES_DELTA))
        ) io_saved_perc
from dba_hist_sqlstat a
join dba_hist_snapshot b on (a.snap_id = b.snap_id and a.instance_number = b.instance_number)
where 1=1
and sql_id in ('&1')
and executions_delta > 0
and b.begin_interval_time >= trunc(sysdate) - &2
group by sql_id, trunc(b.begin_interval_time)
order by 2;
