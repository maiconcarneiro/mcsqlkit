set lines 400
col dbid format 99999999999999
col snap_id format 9999999
col begin_interval_time format a20
col end_interval_time format a20
set feedback off;
alter session set nls_timestamp_format='dd/mm/yyyy hh24:mi:ss';
set feedback on;
SELECT dbid, snap_id,
       min(BEGIN_INTERVAL_TIME) BEGIN_INTERVAL_TIME,
       min(END_INTERVAL_TIME)  END_INTERVAL_TIME
  FROM DBA_HIST_SNAPSHOT
 WHERE END_INTERVAL_TIME >= (sysdate - &1)
   AND DBID = (select dbid from v$database)
 GROUP BY  dbid, snap_id
 ORDER By dbid, snap_id;