set feedback off
set sqlformat
SET VERIFY OFF
SET PAGES 50
SET LINES 400
def NUMBER_FORMAT='999,999,999,999.99'
def NUMBER_FORMAT_INT='999,999,999,999'
col Data           HEADING "Data"                  format a10
col Inicio         HEADING "Inicio"                format a10
col Final          HEADING "Final"                 format a10
col Execs          HEADING "Execs"                 format &NUMBER_FORMAT_INT
col Buffer_Gets    HEADING "(Buffer Gets avg)"     format &NUMBER_FORMAT
col Elapsed_Time   HEADING "(Elapsed Time avg ms)" format &NUMBER_FORMAT
col Disk_Reads     HEADING "(Disk Reads avg)"      format &NUMBER_FORMAT
col rows_processed HEADING "(Rows Processed avg)"  format &NUMBER_FORMAT
col CPU_Time       HEADING "(CPU Time avg ms)"     format &NUMBER_FORMAT
col Elapsed_Time   HEADING "(Elapsed avg ms)"      format &NUMBER_FORMAT
col sql_id         HEADING  "SQL Id"               format a20


ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD/MM/YYYY';
set feedback on

-- obtem o nome da instancia
column NODE new_value VNODE 
column CNAME new_value VCNAME 
SET termout off
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SELECT sys_context('USERENV','CON_NAME') as CNAME FROM dual;
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: Historico do SQL_ID por Snapshot
PROMP SQL ID....: &1
PROMP Qt. Dias..: &2
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

select sql_id,
       plan_hash_value,
       a.snap_id,
       min(b.begin_interval_time)                                       as Data,
       to_char(min(b.begin_interval_time),'hh24:mi:ss')                 as Inicio,
       to_char(max(b.end_interval_time),'hh24:mi:ss')                   as Final,
       sum(executions_delta)                                            as Execs,
       sum(buffer_gets_delta)       / greatest(sum(executions_delta),1) as Buffer_Gets,
       sum(disk_reads_delta)        / greatest(sum(executions_delta),1) as Disk_Reads,
       sum(rows_processed_delta)    / greatest(sum(executions_delta),1) as rows_processed,
       sum(cpu_time_delta/1000)     / greatest(sum(executions_delta),1) as CPU_Time,
       sum(elapsed_time_delta/1000) / greatest(sum(executions_delta),1) as Elapsed_Time
from dba_hist_sqlstat a
join dba_hist_snapshot b on (a.dbid = b.dbid and a.snap_id = b.snap_id and a.instance_number = b.instance_number)
where 1=1
and sql_id in ('&1')
--and executions_delta > 0
and b.begin_interval_time >= sysdate - &2
and (&3 = 0 or b.instance_number = &3)
group by sql_id, plan_hash_value, a.snap_id
order by snap_id, plan_hash_value;
