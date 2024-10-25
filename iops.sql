set feedback off
set sqlformat
set verify off
set lines 400
set pages 50
col inicio             heading 'Begin'               format a20
col fim                heading 'End'                 format a20
col Phys_IOPS_Read     heading 'Physical IOPS|Read'  format 999,999,999,999.99
col Phys_IOPS_Write    heading 'Physical IOPS|Write' format 999,999,999,999.99
col Phys_IOPS_Tot      heading 'Physical IOPS|Total' format 999,999,999,999.99
col Phys_IO_MBps_Read  heading 'Physical MBPS|Read'  format 999,999,999,999.99
col Phys_IO_MBps_Write heading 'Physical MBPS|Write' format 999,999,999,999.99
col Phys_IO_Tot_MBps   heading 'Physical MBPS|Total' format 999,999,999,999.99

alter session set nls_date_format='dd/mm/yyyy hh24:mi';
set feedback on;

PROMP 
PROMP Physical IOPS: Physical Read Total IO Requests Per Sec + Physical Write Total IO Requests Per Sec + Redo Writes Per Sec
PROMP Physical MPPS: Physical Read Total Bytes Per Sec       + Physical Write Total Bytes Per Sec       + Redo Generated Per Sec
PROMP
select snap_id, min(begin_time) inicio, max(end_time) fim,
round(sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then maxval end),2) as Phys_IOPS_Read,
round( sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then maxval end) +
       sum(case metric_name when 'Redo Writes Per Sec' then maxval end)
,2) as Phys_IOPS_Write,
round(sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then maxval end) +
      sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then maxval end) +
      sum(case metric_name when 'Redo Writes Per Sec' then maxval end)
   ,2) Phys_IOPS_Tot,
round( sum(case metric_name when 'Physical Read Total Bytes Per Sec' then maxval end)/1024/1024 ,2) as Phys_IO_MBps_Read,
round( sum(case metric_name when 'Physical Write Total Bytes Per Sec' then maxval end)/1024/1024 ,2) as Phys_IO_MBps_Write,
round( sum(case metric_name when 'Physical Read Total Bytes Per Sec' then maxval end)/1024/1024 +
       sum(case metric_name when 'Physical Write Total Bytes Per Sec' then maxval end)/1024/1024 +
       sum(case metric_name when 'Redo Generated Per Sec' then maxval end)/1024/1024 
	,2) Phys_IO_Tot_MBps
from dba_hist_sysmetric_summary
where begin_time >= sysdate-&1
group by snap_id
order by snap_id;
