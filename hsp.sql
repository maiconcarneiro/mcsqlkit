SET FEEDBACK OFF
SET SQLFORMAT
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';
SET VERIFY OFF
SET PAGES 50
SET LINES 400
SET FEEDBACK ON

col Data           HEADING "Data"                  format a10
col menor          HEADING "Min"                   format a10
col maior          HEADING "Max"                   format a10
col Buffer_Gets    HEADING "(Buffer Gets avg)"     format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed Time avg ms)" format 999,999,999,999.99
col Execs          HEADING "Execs"                 format 999,999,999,999
col Disk_Reads     HEADING "(Disk Reads avg)"      format 999,999,999,999.99
col rows_processed HEADING "(Rows Processed avg)"  format 999,999,999,999.99
col CPU_Time       HEADING "(CPU Time avg ms)"     format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed ms avg)"      format 999,999,999,999.99
col sql_id         HEADING  "SQL Id"               format a20

select sql_id, plan_hash_value,
trunc(b.begin_interval_time) data,
to_char(min(b.begin_interval_time),'hh24:mi:ss')    as menor,
to_char(max(b.end_interval_time),'hh24:mi:ss')      as maior,
sum(executions_delta)                                            as Execs,
sum(buffer_gets_delta)       / greatest(sum(executions_delta),1) as Buffer_Gets,
sum(disk_reads_delta)        / greatest(sum(executions_delta),1) as Disk_Reads,
sum(rows_processed_delta)    / greatest(sum(executions_delta),1) as rows_processed,
sum(cpu_time_delta/1000)     / greatest(sum(executions_delta),1) as CPU_Time,
sum(elapsed_time_delta/1000) / greatest(sum(executions_delta),1) as Elapsed_Time
from dba_hist_sqlstat a
join dba_hist_snapshot b on (a.snap_id = b.snap_id and a.instance_number = b.instance_number)
where 1=1
and sql_id in ('&1')
and executions_delta > 0
and b.begin_interval_time >= trunc(sysdate) - &2
group by sql_id, trunc(b.begin_interval_time), plan_hash_value
order by data, plan_hash_value;
