set feedback off;
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
set feedback on;
SELECT dbid, 
       snap_id,
       min(SNAP_TIME) as end_snap
 FROM STATS$SNAPSHOT
 WHERE SNAP_TIME >= sysdate - &1/24
GROUP BY dbid, 
         snap_id
ORDER BY 1,2;
