PROMP
PROMP Metric....: Statistics from GV$SQL (avg per exec)
PROMP Filter....: &2
PROMP Group By..: &1
PROMP Order By..: &3
PROMP

SET TERMOUT OFF;
SET VERIFY OFF
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
col direct_reads   HEADING "Direct Reads"        format 999,999,999,999.99
col rows_processed HEADING "Rows|Processed"        format 999,999,999.99
col CPU_Time       HEADING "CPU|Time (ms)"         format 999,999,999,999.99
col io_time        HEADING "IO Wait|Time(ms)"      format 999,999,999,999.99
col sql_id         HEADING  "SQL Id"               format a18
col im_scans       HEADING "IM|Scans"      format 999,999,999,999
col im_mbytes_unc  HEADING "IM Scan (MB) | Uncompressed"      format 999,999,999,999.99
col im_mbytes      HEADING "|IM Scan (MB)"    format 999,999,999,999.99

select plan_hash_value,
       sum(executions)                                      as Execs,
       sum(buffer_gets)             / greatest(sum(executions),1) as buffer_gets,
       -- In-Memory
       sum(im_scans)                                 AS im_scans,
       sum(im_scan_bytes_uncompressed /1024/1024 )   AS im_mbytes_unc,
       sum(im_scan_bytes_inmemory /1024/1024 )       AS im_mbytes,
       sum(cpu_time/1000)           / greatest(sum(executions),1) as CPU_Time,
       sum(user_io_wait_time/1000)  / greatest(sum(executions),1) as io_time,
       sum(elapsed_time/1000)       / greatest(sum(executions),1) as Elapsed_Time
  from gv$sql
 where sql_id = '&1'
group by plan_hash_value
order by plan_hash_value;