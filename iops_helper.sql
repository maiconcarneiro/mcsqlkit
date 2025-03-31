/*
 Script to query IO metrcis from at database level using AWR
 Originally from mig360 (Alex Zaballa @ enkitec)

 Maicon Carneiro: Adapted to group by DATE and allow change the aggregation function dynamically.
*/

def AGGR_FUNC='&4'

set feedback off
set sqlformat
set verify off
set lines 400
set pages 50
col begin_time         heading "Date"                             format a15
col instance_number    heading "Inst ID"                          format 999
col snap_id            heading "Snap ID"                          format 999999
col inicio             heading 'Begin'                            format a5
col fim                heading 'End'                              format a5
col Phys_IOPS_Read     heading 'Physical IOPS|Read (&AGGR_FUNC)'  format 999,999,999,999.99
col Phys_IOPS_Write    heading 'Physical IOPS|Write (&AGGR_FUNC)' format 999,999,999,999.99
col Phys_IOPS_Tot      heading 'Physical IOPS|Total (&AGGR_FUNC)' format 999,999,999,999.99
col Phys_IO_MBps_Read  heading 'Physical MBPS|Read (&AGGR_FUNC)'  format 999,999,999,999.99
col Phys_IO_MBps_Write heading 'Physical MBPS|Write (&AGGR_FUNC)' format 999,999,999,999.99
col Phys_IO_Tot_MBps   heading 'Physical MBPS|Total (&AGGR_FUNC)' format 999,999,999,999.99

-- get instance name
column NODE new_value VNODE 
column CNAME new_value VCNAME 
SET termout off
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SELECT sys_context('USERENV','CON_NAME') as CNAME FROM dual;
SET termout ON

-- report sumamry
PROMP
PROMP Metrica...: Physical IOPS and MBPS History from AWR
PROMP Days......: &2
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP Aggregate.: &AGGR_FUNC
PROMP

alter session set nls_date_format='dd/mm/yyyy Dy';
set feedback on;

PROMP 
PROMP Physical IOPS: Physical Read Total IO Requests Per Sec + Physical Write Total IO Requests Per Sec + Redo Writes Per Sec
PROMP Physical MPPS: Physical Read Total Bytes Per Sec       + Physical Write Total Bytes Per Sec       + Redo Generated Per Sec
PROMP

select trunc(&1) as &1, 
       to_char(min(begin_time),'hh24:mi') inicio, 
       to_char(max(end_time),'hh24:mi') fim,
round( &AGGR_FUNC(case metric_name when 'Physical Read Total IO Requests Per Sec' then maxval end),2) as Phys_IOPS_Read,
round( &AGGR_FUNC(case metric_name when 'Physical Write Total IO Requests Per Sec' then maxval end) +
       &AGGR_FUNC(case metric_name when 'Redo Writes Per Sec' then maxval end)
,2) as Phys_IOPS_Write,
round(&AGGR_FUNC(case metric_name when 'Physical Read Total IO Requests Per Sec' then maxval end) +
      &AGGR_FUNC(case metric_name when 'Physical Write Total IO Requests Per Sec' then maxval end) +
      &AGGR_FUNC(case metric_name when 'Redo Writes Per Sec' then maxval end)
   ,2) Phys_IOPS_Tot,
round( &AGGR_FUNC(case metric_name when 'Physical Read Total Bytes Per Sec' then maxval end)/1024/1024 ,2) as Phys_IO_MBps_Read,
round( &AGGR_FUNC(case metric_name when 'Physical Write Total Bytes Per Sec' then maxval end)/1024/1024 ,2) as Phys_IO_MBps_Write,
round( &AGGR_FUNC(case metric_name when 'Physical Read Total Bytes Per Sec' then maxval end)/1024/1024 +
       &AGGR_FUNC(case metric_name when 'Physical Write Total Bytes Per Sec' then maxval end)/1024/1024 +
       &AGGR_FUNC(case metric_name when 'Redo Generated Per Sec' then maxval end)/1024/1024 
	,2) Phys_IO_Tot_MBps
from dba_hist_sysmetric_summary 
where begin_time >= sysdate-&2
 and (&3 = 0 or instance_number = &3)
 and dbid=(select dbid from v$database) 
group by trunc(&1) 
order by 1;
