
set sqlformat
set verify off
set pagesize 50
set lines 300
col STATUS format a25
col hrs format 999.99
col minutes format 999,999.99
col INPUT_TYPE form a15
col start_time format a20
col end_time format a20
col output_gbytes for 9,999,999 heading "OUTPUT|GBYTES"
col input_gbytes for 9,999,999 heading "INPUT|GBYTES"
alter session set NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
select
SESSION_RECID,
SESSION_KEY, 
INPUT_TYPE, STATUS,
to_char(START_TIME,'dd/mm/yyyy hh24:mi') start_time,
to_char(END_TIME,'dd/mm/yyyy hh24:mi')   end_time,
elapsed_seconds/3600 as hrs,
elapsed_seconds/60 as minutes,
(input_bytes/1024/1024/1024) input_gbytes,
(output_bytes/1024/1024/1024) output_gbytes
from V$RMAN_BACKUP_JOB_DETAILS
where START_TIME >= trunc(sysdate) - &2
and INPUT_TYPE like upper('%&1%')
order by session_key;
