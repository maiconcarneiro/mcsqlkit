set linesize 300
col sql_id format a18
col first_load_time format a20
col child_number format 999999
col sql_profile format a30
col sql_plan_baseline format a30
col sql_patch format a30
select inst_id, sql_id, child_number, plan_hash_value, first_load_time, sql_profile, sql_plan_baseline, sql_patch
from   gv$sql 
where  sql_id='&1';
