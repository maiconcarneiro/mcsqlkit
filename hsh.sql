-- Author: Maicon Carneiro (dibiei.com)
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';
SET VERIFY OFF
SET PAGES 50
SET LINES 400
col data format a10
col minimo format a10
col maximo format a10
col "(Buffer Gets avg)" format 999,999,999,999.99
col "(Elapsed Time avg ms)" format 999,999,999,999.99
col execs format 999,999,999,999
col "(Disk Reads avg)" format 999,999,999,999.99
col "(Rows Processed avg)" format 999,999,999,999.99
col "(CPU Time avg ms)" format 999,999,999,999.99
col sql_id format a20
select sql_id,
plan_hash_value,
trunc(b.begin_interval_time) data,
to_char(min(b.begin_interval_time),'hh24:mi:ss') as minimo,
to_char(max(b.begin_interval_time),'hh24:mi:ss') as maximo,
sum(executions_delta)                               as "Execs",
round(sum(buffer_gets_delta)       /sum(executions_delta),2) as "(Buffer Gets avg)",
sum(disk_reads_delta)        /sum(executions_delta) as "(Disk Reads avg)",
sum(rows_processed_delta)    /sum(executions_delta) as "(Rows Processed avg)",
sum(cpu_time_delta/1000)     /sum(executions_delta) as "(CPU Time avg ms)",
sum(elapsed_time_delta/1000) /sum(executions_delta) as "(Elapsed Time avg ms)"
from dba_hist_sqlstat a
join dba_hist_snapshot b on (a.snap_id = b.snap_id and a.instance_number = b.instance_number)
where 1=1
and sql_id in ('&1') 
and executions_delta > 0
and b.begin_interval_time >= trunc(sysdate)-&2
and plan_hash_value = &3
group by sql_id, plan_hash_value, trunc(b.begin_interval_time)
order by 3,2;
