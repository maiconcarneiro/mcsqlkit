-- Author: Maicon Carneiro (dibiei.com)
SET SQLFORMAT
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGES 50
SET LINES 400
SET FEEDBACK ON
col Inicio         HEADING "First Exec"            format a20
col Final          HEADING "Last Exec"             format a20
col Buffer_Gets    HEADING "Buffer Gets avg"       format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed Time avg ms)" format 999,999,999,999.99
col Execs          HEADING "Execs"                 format 999,999,999,999
col Disk_Reads     HEADING "(Disk Reads avg)"      format 999,999,999,999.99
col rows_processed HEADING "(Rows Processed avg)"  format 999,999,999,999.99
col CPU_Time       HEADING "(CPU Time avg ms)"     format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed ms avg)"      format 999,999,999,999.99
col sql_id         HEADING  "SQL Id"               format a18
col planos         HEADING  "Plans"                format 999

ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD/MM/YYYY HH24:MI:SS';

select * from (
select sql_id,
min(b.begin_interval_time) inicio,
max(b.begin_interval_time) final,
count(distinct(PLAN_HASH_VALUE)) as planos,
sum(executions_delta)                                            as Execs,
sum(buffer_gets_delta)       / greatest(sum(executions_delta),1) as Buffer_Gets,
sum(disk_reads_delta)        / greatest(sum(executions_delta),1) as Disk_Reads,
sum(rows_processed_delta)    / greatest(sum(executions_delta),1) as rows_processed,
sum(cpu_time_delta/1000)     / greatest(sum(executions_delta),1) as CPU_Time,
sum(elapsed_time_delta/1000) / greatest(sum(executions_delta),1) as Elapsed_Time
from dba_hist_sqlstat a
join dba_hist_snapshot b on (a.snap_id = b.snap_id and a.instance_number = b.instance_number)
where 1=1
and executions_delta > 0
group by sql_id
having min(b.begin_interval_time)  >= trunc(sysdate) - &1
order by Execs desc
) where rownum <= &2;
