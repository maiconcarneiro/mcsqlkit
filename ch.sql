set linesize 300
col sql_id format a20
col child_number format 999999
col sql_profile format a30
col sql_plan_baseline format a30
select sql_id, child_number, sql_profile, sql_plan_baseline
from   gv$sql 
where  sql_id='&1';
