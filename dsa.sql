PROMP
PROMP Metric....: Statistics from GV$SQL grouped by SQL_ID and PHV (avg per exec)
PROMP SQL ID....: &1
PROMP


SET VERIFY OFF
SET PAGES 50
set linesize 400
col report_date    HEADING "Date"                  format a10
col start_time     HEADING "Start"                 format a10
col end_time       HEADING "End"                   format a10
col Buffer_Gets    HEADING "Buffer Gets|per exec"      format 999,999,999,999.99
col Elapsed_Time   HEADING "Elapsed Time |per exec" format 999,999,999,999.99
col Execs          HEADING "Executions|Count"                 format 999,999,999,999
col Disk_Reads     HEADING "Disk Reads|per exec"      format 999,999,999,999.99
col rows_processed HEADING "Rows|processed|per exec"              format 999,999,999,999.99
col CPU_Time       HEADING "CPU Time|per exec"       format 999,999,999,999.99
col io_time        HEADING "IO Time|per exec"        format 999,999,999.99
col app_wait_time  HEADING "App Time|per exec"       format 999,999,999.99
col sql_id         HEADING  "SQL Id"               format a18
col avg_px         HEADING  "(AVG Px)"             format a20
col offload        HEADING  "Smart|Scan|Used?"       format a10
col io_saved_perc  HEADING  "% IO Saved|Smart Scan"   format 999,999.99
col child_number   HEADING  "Child"                format 999
col inst_id        HEADING  "Inst"                 format 99 
col plan_hash_value HEADING "Plan|Hash Value"                  format 999999999999
select sql_id,
       plan_hash_value, 
       child_number,
       inst_id,
       (executions)                                                                     Execs,
       (buffer_gets)            / (case when executions = 0 then 1 else executions end) Buffer_Gets,
       (disk_reads)             / (case when executions = 0 then 1 else executions end) Disk_Reads,
       (rows_processed)         / (case when executions = 0 then 1 else executions end) rows_processed,
       (user_io_wait_time/1000) / (case when executions = 0 then 1 else executions end) io_time,
       (cpu_time/1000)          / (case when executions = 0 then 1 else executions end) CPU_Time,
       (elapsed_time/1000)      / (case when executions = 0 then 1 else executions end) Elapsed_Time,
       (application_wait_time/1000) / greatest((executions),1) as app_wait_time,
       decode(io_cell_offload_eligible_bytes, 0, 0, 100 *(io_cell_offload_eligible_bytes - io_interconnect_bytes) 
         / decode(io_cell_offload_eligible_bytes,0, 1, io_cell_offload_eligible_bytes)
        ) io_saved_perc,
       decode(io_cell_offload_eligible_bytes, 0, 'No', 'Yes')  offload
from gv$sql
where sql_id in ('&1')
order by child_number, inst_id;
