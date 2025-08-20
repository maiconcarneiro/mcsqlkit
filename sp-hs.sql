/*
 Script to query metrics from STATSPACK for an specific SQL ID
 Syntax: @sp-hs <SQL_ID> <QT. DAYS> <INST ID>
  
  Examples:
   @sp-hs 29qp10usqkqh0 30 0
   @sp-hs 29qp10usqkqh0 15 1

 Author: Maicon Carneiro | dibiei.blog
*/
SET FEEDBACK OFF
alter session set nls_date_format='dd/mm/yyyy Dy';

SET SQLFORMAT
SET VERIFY OFF
SET PAGES 50
SET LINES 400
SET FEEDBACK ON

col sql_id         HEADING "SQL Id"                format a18
col Data           HEADING "Data"                  format a15
col Inicio         HEADING "First"                 format a5
col Final          HEADING "Last"                  format a5
col Buffer_Gets    HEADING "(Buffer Gets avg)"     format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed Time avg ms)" format 999,999,999,999.99
col Execs          HEADING "Execs"                 format 999,999,999,999
col Disk_Reads     HEADING "(Disk Reads avg)"      format 999,999,999,999.99
col rows_processed HEADING "(Rows Processed avg)"  format 999,999,999,999.99
col CPU_Time       HEADING "(CPU Time avg ms)"     format 999,999,999,999.99
col app_wait_time  HEADING "Application Time (ms)" format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed ms avg)"      format 999,999,999,999.99
col planos         HEADING "PHVs"                  format 999
col writes_mbytes   HEADING "(Writes MBytes)"      format 999,999,999,999

-- obtem o nome da instancia
column NODE new_value VNODE 
column CNAME new_value VCNAME 
SET termout off
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SELECT sys_context('USERENV','CON_NAME') as CNAME FROM dual;
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metric....: History of SQL ID per day (STATSPACK)
PROMP SQL ID....: &1
PROMP Days......: &2
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

-- query
with sp_sql_stat as (
 select h.sql_id,
        s.instance_number,
        s.snap_id, 
        LAG(s.snap_time, 1, null) OVER (PARTITION BY s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id) as begin_interval_time,
        s.snap_time as end_interval_time,
        executions,
        (executions - LAG(executions, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS executions_delta,
        fetches,
        (fetches - LAG(fetches, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS fetches_delta,
        buffer_gets,
        (buffer_gets - LAG(buffer_gets, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS buffer_gets_delta,
        disk_reads,
        (disk_reads - LAG(disk_reads, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS disk_reads_delta,
        rows_processed,
        (rows_processed - LAG(rows_processed, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS rows_processed_delta,
        cpu_time,
        (cpu_time - LAG(cpu_time, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS cpu_time_delta,
        elapsed_time,
        (elapsed_time - LAG(elapsed_time, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS elapsed_time_delta,
        user_io_wait_time,
        (user_io_wait_time - LAG(user_io_wait_time, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS user_io_wait_time_delta,
        application_wait_time,
        (application_wait_time - LAG(application_wait_time, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS application_wait_time_delta,
        parse_calls,
        (parse_calls - LAG(parse_calls, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS parse_calls_delta
    from STATS$SNAPSHOT s
    join STATS$SQL_SUMMARY h on (s.snap_id = h.snap_id and s.dbid = h.dbid and s.instance_number = h.instance_number)
   where 1=1
     and h.sql_id = '&1'
     and s.snap_time >= trunc(sysdate)-&2
     and (&3 = 0 or s.instance_number = &3)
order by s.dbid, s.instance_number, s.snap_id
)
select sql_id,
       trunc(begin_interval_time)                                       as data,
       to_char(min(begin_interval_time),'hh24:mi')                      as Inicio,
       to_char(max(end_interval_time),'hh24:mi')                        as Final,
       sum(executions_delta)                                            as Execs,
       sum(buffer_gets_delta)                / greatest(sum(executions_delta),1) as Buffer_Gets,
       sum(disk_reads_delta)                 / greatest(sum(executions_delta),1) as Disk_Reads,
       sum(rows_processed_delta)             / greatest(sum(executions_delta),1) as rows_processed,
       sum(cpu_time_delta/1000)              / greatest(sum(executions_delta),1) as CPU_Time,
       sum(application_wait_time_delta/1000) / greatest(sum(executions_delta),1) as app_wait_time,
       sum(elapsed_time_delta/1000)          / greatest(sum(executions_delta),1) as Elapsed_Time
  from sp_sql_stat
 where 1=1
   and executions_delta > 0
   and begin_interval_time is not null
group by sql_id, trunc(begin_interval_time)
order by 2;