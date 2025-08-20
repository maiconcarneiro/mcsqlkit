/*
 Script to query metrics from GV$SQL using different combinations of SELECT/GROUP BY and WHERE
 Syntax: @ds_filter <GROUP BY COLUMNS> <FILTER EXPRESSION> <ORDER BY COLUMNS>
  
  Examples:
   @ds_filter plan_hash_value "sql_id='g81cbrq5yamf5' 1
   @ds_filter sql_id,plan_hash_value module='New Orders' 1,2

 Tip: Use double quotes for multiple filter, example:
   @ds_filter sql_id "parsing_schema_name='SOE' and executions>5000" 0 2

 Author: Maicon Carneiro | dibiei.blog
*/

-- resumo do relatorio
PROMP
PROMP Metric....: Statistics from GV$SQL (avg per exec)
PROMP Filter....: &2
PROMP Group By..: &1
PROMP Order By..: &3
PROMP

SET TERMOUT OFF;
SET VERIFY OFF;
set sqlformat
SET TERMOUT ON;


SET PAGES 50
SET LINES 400
col inst_id        HEADING "Inst ID"               format 999
col Data           HEADING "Data"                  format a10
col Inicio         HEADING "Inicio"                format a10
col Final          HEADING "Final"                 format a10
col Buffer_Gets    HEADING "Buffer Gets"           format 999,999,999,999.99
col Elapsed_Time   HEADING "Elapsed|Time (ms)"     format 999,999,999,999.99
col Execs          HEADING "Executions|Count"      format 999,999,999,999
col Disk_Reads     HEADING "Disk Reads"            format 999,999,999,999.99
col direct_reads     HEADING "Direct Reads"        format 999,999,999,999.99
col rows_processed HEADING "Rows|Processed"        format 999,999,999.99
col CPU_Time       HEADING "CPU|Time (ms)"         format 999,999,999,999.99
col io_time        HEADING "IO Wait|Time(ms)"      format 999,999,999,999.99
col app_wait_time  HEADING "Application|Wait Time(ms)" format 999,999,999,999.99
col sql_id         HEADING  "SQL Id"               format a18
select &1,
       sum(executions)                                               as Execs,
       sum(buffer_gets)                / greatest(sum(executions),1) as Buffer_Gets,
       sum(disk_reads)                 / greatest(sum(executions),1) as Disk_Reads,
       sum(direct_reads)               / greatest(sum(executions),1) as direct_reads,
       sum(rows_processed)             / greatest(sum(executions),1) as rows_processed,
       sum(user_io_wait_time/1000)     / greatest(sum(executions),1) as io_time,
       sum(cpu_time/1000)              / greatest(sum(executions),1) as CPU_Time,
       sum(application_wait_time/1000) / greatest(sum(executions),1) as app_wait_time,
       sum(elapsed_time/1000)          / greatest(sum(executions),1) as Elapsed_Time
  from gv$sql
 where &2
group by &1
order by &3;
