alter session set nls_timestamp_format='dd/mm/yyyy hh24:mi:ss';
SELECT dbid, snap_id,
       min(BEGIN_INTERVAL_TIME) BEGIN_INTERVAL_TIME,
       min(END_INTERVAL_TIME)  END_INTERVAL_TIME
  FROM DBA_HIST_SNAPSHOT
 WHERE END_INTERVAL_TIME >= (sysdate - &1)
 GROUP BY  dbid, snap_id
 ORDER By dbid, snap_id;