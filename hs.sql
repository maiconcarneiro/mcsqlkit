SET FEEDBACK OFF
alter session set nls_date_format='dd/mm/yyyy Dy';

SET SQLFORMAT
SET VERIFY OFF
SET PAGES 50
SET LINES 400
SET FEEDBACK ON

col sql_id         HEADING  "SQL Id"               format a18
col Data           HEADING "Data"                  format a15
col Inicio         HEADING "First"                 format a5
col Final          HEADING "Last"                  format a5
col Buffer_Gets    HEADING "(Buffer Gets avg)"     format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed Time avg ms)" format 999,999,999,999.99
col Execs          HEADING "Execs"                 format 999,999,999,999
col Disk_Reads     HEADING "(Disk Reads avg)"      format 999,999,999,999.99
col rows_processed HEADING "(Rows Processed avg)"  format 999,999,999,999.99
col CPU_Time       HEADING "(CPU Time avg ms)"     format 999,999,999,999.99
col Elapsed_Time   HEADING "(Elapsed ms avg)"      format 999,999,999,999.99
col planos         HEADING "PHVs"                  format 999
col writes_mbytes   HEADING "(Writes MBytes)"        format 999,999,999,999

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: Historico do SQL_ID por Data
PROMP SQL ID....: &1
PROMP Qt. Dias..: &2
PROMP Instance..: &VNODE
PROMP

-- query
select sql_id,
 trunc(b.begin_interval_time)                                     as data,
 to_char(min(b.begin_interval_time),'hh24:mi')                    as Inicio,
 to_char(max(b.end_interval_time),'hh24:mi')                      as Final,
 count(distinct(PLAN_HASH_VALUE))                                 as planos,
 sum(executions_delta)                                            as Execs,
 sum(buffer_gets_delta)       / greatest(sum(executions_delta),1) as Buffer_Gets,
 sum(disk_reads_delta)        / greatest(sum(executions_delta),1) as Disk_Reads,
 sum(rows_processed_delta)    / greatest(sum(executions_delta),1) as rows_processed,
 sum(cpu_time_delta/1000)     / greatest(sum(executions_delta),1) as CPU_Time,
 sum(elapsed_time_delta/1000) / greatest(sum(executions_delta),1) as Elapsed_Time
 --,sum(PHYSICAL_WRITE_BYTES_DELTA)/1024/1024 as writes_mbytes
 from dba_hist_sqlstat a
 join dba_hist_snapshot b on (a.snap_id = b.snap_id and a.instance_number = b.instance_number)
where 1=1
  and sql_id in ('&1')
  --and executions_delta > 0
  and b.begin_interval_time >= trunc(sysdate) - &2
  and (&3 = 0 or b.instance_number = &3)
group by sql_id, trunc(b.begin_interval_time)
order by 2;
