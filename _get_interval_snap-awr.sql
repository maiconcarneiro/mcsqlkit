column START_DATE new_value _START_DATE
column END_DATE   new_value _END_DATE
SET TERMOUT OFF
SELECT TO_CHAR(min(begin_interval_time), 'DD/MM/YYYY HH24:MI') AS START_DATE, 
       TO_CHAR(max(begin_interval_time) ,'DD/MM/YYYY HH24:MI') AS END_DATE 
FROM dba_hist_snapshot
WHERE SNAP_ID IN (&1, &2);
SET termout ON