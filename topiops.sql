set verify off
set lines 400
col servidor format a30
col Phys_IOPS_Read format 999,999,999,999.99
col Phys_IO_Tot_MBps format 999,999,999,999.99
col Phys_IOPS_Write format 999,999,999,999.99
col Phys_IOPS_Tot format 999,999,999,999.99
col Phys_IO_MBps_Read format 999,999,999,999.99
col Phys_IO_MBps_Write format 999,999,999,999.99
col Phys_IO_MBps_Total format 999,999,999,999.99
col inicio format a20
col fim format a20
alter session set nls_date_format='dd/mm/yyyy hh24:mi';
PROMPT ###############################################################################################
PROMPT #                      TOP 10 IOPS e THROUGHPUT do AWR
PROMPT ###############################################################################################
select instance_name as instance, host_name as Servidor, sysdate as "Data da coleta:" from gv$instance;
select min(begin_time) MAIS_ANTIGO , max(end_time) MAIS_RECENTE from dba_hist_sysmetric_summary;
--alter session set nls_date_format='dd/mm/yyyy';
PROMPT
PROMPT ********************************** TOP 30 IOPS **************************************************
select * from (
select min(begin_time) inicio, max(end_time) fim,
round( sum(case metric_name when 'Physical Read Total Bytes Per Sec' then maxval end)/1024/1024 +
       sum(case metric_name when 'Physical Write Total Bytes Per Sec' then maxval end)/1024/1024 +
       sum(case metric_name when 'Redo Generated Per Sec' then maxval end)/1024/1024 
	,2) Phys_IO_Tot_MBps,
round(sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then maxval end),2) as Phys_IOPS_Read,
round( sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then maxval end) +
       sum(case metric_name when 'Redo Writes Per Sec' then maxval end)
   ,2) Phys_IOPS_Write,
round(sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then maxval end) +
      sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then maxval end) +
      sum(case metric_name when 'Redo Writes Per Sec' then maxval end)
   ,2) Phys_IOPS_Tot
from dba_hist_sysmetric_summary
where begin_time >= trunc(sysdate)-&1
group by snap_id
order by Phys_IOPS_Tot desc
) where rownum <= 30;


PROMPT
PROMPT ********************************** TOP 30 THROUGHPUT *********************************************
select * from (
select min(begin_time) inicio, max(end_time) fim,
round( sum(case metric_name when 'Physical Read Total Bytes Per Sec' then maxval end)/1024/1024 ,2) as Phys_IO_MBps_Read,
round( sum(case metric_name when 'Physical Write Total Bytes Per Sec' then maxval end)/1024/1024 ,2) as Phys_IO_MBps_Write,
round( sum(case metric_name when 'Physical Read Total Bytes Per Sec' then maxval end)/1024/1024 +
       sum(case metric_name when 'Physical Write Total Bytes Per Sec' then maxval end)/1024/1024 +
       sum(case metric_name when 'Redo Generated Per Sec' then maxval end)/1024/1024 
	,2) Phys_IO_MBps_Total
from dba_hist_sysmetric_summary
where begin_time >= trunc(sysdate)-&1
group by snap_id
order by Phys_IO_MBps_Total desc
) where rownum <= 30;
