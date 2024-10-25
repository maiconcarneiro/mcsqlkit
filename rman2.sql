
set sqlformat
set pagesize 60
set lines 9999
SET WRAP ON
col STATUS format a25
col hrs format 999.99
col INPUT_TYPE format a15
col start_time format a20
col end_time format a20
col output_sec format a10 heading "OUTPUT|GB|SEC"
col input_sec for a10 heading "INPUT|GB|SEC"
col bkp_size for a10 heading "BKP SIZE"
col compression_ratio for 99.99 heading "Compression|Ratio"
alter session set NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
select
SESSION_RECID,
SESSION_KEY,
INPUT_TYPE,
STATUS,
to_char(START_TIME,'dd/mm/yyyy hh24:mi') start_time,
to_char(END_TIME,'dd/mm/yyyy hh24:mi')   end_time,
elapsed_seconds/3600 as hrs,
(INPUT_BYTES_PER_SEC_DISPLAY) input_sec,
(OUTPUT_BYTES_PER_SEC_DISPLAY) output_sec,
OUTPUT_BYTES_DISPLAY BKP_SIZE,
compression_ratio
from V$RMAN_BACKUP_JOB_DETAILS
where START_TIME >= trunc(sysdate) - &2
and INPUT_TYPE like upper('%&1%')
order by session_key asc;





--set sqlformat
--set verify off
--set pagesize 50
--set lines 300
--col STATUS format a25
--col hrs format 999.99
--col minutes format 999,999.99
--col INPUT_TYPE form a15
--col start_time format a20
--col end_time format a20
--col output_gbytes for 9,999,999 heading "OUTPUT|GBYTES"
--col input_gbytes for 9,999,999 heading "INPUT|GBYTES"
--alter session set NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
--select
--SESSION_RECID,
--SESSION_KEY, 
--INPUT_TYPE, STATUS,
--to_char(START_TIME,'dd/mm/yyyy hh24:mi') start_time,
--to_char(END_TIME,'dd/mm/yyyy hh24:mi')   end_time,
--elapsed_seconds/3600 as hrs,
--elapsed_seconds/60 as minutes,
--(input_bytes/1024/1024/1024) input_gbytes,
--(output_bytes/1024/1024/1024) output_gbytes
--from V$RMAN_BACKUP_JOB_DETAILS
--where START_TIME >= trunc(sysdate) - &2
--and INPUT_TYPE like upper('%&1%')
--order by session_key;