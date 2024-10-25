set lines 400
set pages 1000
col exec_name  format a15
col sql_id format a18
col plan_hash_value format 999999999999999
col elapsed_time format 999,999,999,999.99
col cpu_time format 999,999,999,999.99
col buffer_gets format 999,999,999,999.99
col user_io_time format 999,999,999,999.99
col disk_reads format 999,999,999,999.99
col optimizer_cost format 999,999,999,999.99
col direct_writes format 999,999,999,999.99
col io_interconnect_bytes format 999,999,999,999.99
SELECT
    execution_name as exec_name,
    sql_id,
    plan_hash_value,
    elapsed_time,
    cpu_time,
    buffer_gets,
    user_io_time,
    disk_reads,
    optimizer_cost, 
    direct_writes,
    io_interconnect_bytes
FROM dba_advisor_sqlstats
WHERE execution_name = '&1'
ORDER BY execution_name, sql_id, plan_hash_value;