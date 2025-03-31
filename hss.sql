SET FEEDBACK OFF
SET SQLFORMAT
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';
SET VERIFY OFF
SET PAGES 50
SET LINES 400
SET FEEDBACK ON

col con_id         HEADING "Con|ID"                format 999
col first          HEADING "First|Seen"             format a15
col last           HEADING "Last|Seen"             format a15
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
@_query_dbid

-- resumo do relatorio
PROMP
PROMP Metric....: Summary for all Plan Hash Value in AWR
PROMP SQL ID....: &1
PROMP Qt. Days..: AWR Retention
PROMP Instance..: &VNODE
PROMP

with phv_list as (
 SELECT p.sql_id, p.plan_hash_value, x.adaptive_plan
 FROM dba_hist_sql_plan p,
      XMLTABLE('/other_xml/info[@type="adaptive_plan"]' 
               PASSING XMLTYPE(p.other_xml) 
               COLUMNS adaptive_plan VARCHAR2(10) PATH 'text()') x
 WHERE p.other_xml IS NOT NULL
 and sql_id = '&1'
)
select a.plan_hash_value                                                               as plan_hash_value,
       max(p.adaptive_plan)                                                            as adaptive_plan,
       to_char(min(b.begin_interval_time),'dd/mm/yy hh24:mi')                          as first,
       to_char(max(b.end_interval_time),'dd/mm/yy hh24:mi')                            as last,
       sum(executions_delta)                                                           as Execs,
       sum(rows_processed_delta)                   / greatest(sum(executions_delta),1) as rows_processed,
       sum(disk_reads_delta)                       / greatest(sum(executions_delta),1) as Disk_Reads,
       sum(iowait_delta/1000)                      / greatest(sum(executions_delta),1) as iowait_delta,
       sum(buffer_gets_delta)                      / greatest(sum(executions_delta),1) as Buffer_Gets,
       sum(cpu_time_delta/1000)                    / greatest(sum(executions_delta),1) as CPU_Time,
       sum(elapsed_time_delta/1000)                / greatest(sum(executions_delta),1) as Elapsed_Time
from dba_hist_sqlstat a
join dba_hist_snapshot b on (a.dbid = b.dbid and a.snap_id = b.snap_id and a.instance_number = b.instance_number)
left join phv_list p on a.sql_id = p.sql_id and a.plan_hash_value = p.plan_hash_value
where 1=1
and a.sql_id in ('&1')
and executions_delta > 0
and b.dbid = (&_SUBQUERY_DBID)
group by a.plan_hash_value
order by Elapsed_Time;
