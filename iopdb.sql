set feedback off
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI'; 
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD/MM/YYYY HH24:MI'; 
SET lines 400
SET PAGES 30
COLUMN pdb_name FORMAT A10
COLUMN begin_time FORMAT A20
COLUMN end_time FORMAT A20
col iops format 999,999,999.99
col iombps format 999,999,999.99
col iops_throttle_exempt format 999,999,999.99
col iombps_throttle_exempt format 999,999,999.99
col avg_io_throttle format 999,999,999.99
set feedback on
SELECT r.con_id,
       p.pdb_name,
       r.begin_time,
       r.end_time,
       r.iops,
       r.iombps,
       r.iops_throttle_exempt,
       r.iombps_throttle_exempt,
       r.avg_io_throttle 
FROM   v$rsrcpdbmetric_history r,
       cdb_pdbs p
WHERE  r.con_id = p.con_id
AND    p.pdb_name = upper('&1')
ORDER BY pdb_name, r.begin_time;