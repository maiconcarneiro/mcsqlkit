set lines 400
set verify off
col child_number heading "Child #" format 999
col plan_hash_value heading "Plan|Hash Value" format 999999999999
col first_load_time heading "First Load Time" format a20
col is_bind_aware             heading "Is|Bind|Aware" format a10
col is_shareable              heading "|Is|Shareable" format a10
col is_resolved_adaptive_plan heading "Is|Adapative|Resolved" format a10
col is_obsolete               heading "|Is|Obsolete" format a10
col is_reoptimizable          heading "|Is|Reoptimiz" format a10
col is_bind_sensitive         heading "Is|Bind|Sensitive" format a10
col optimizer_cost heading "Optimizer|Cost" format 999,999,999
col optimizer_mode heading "Optimizer|Mode" format a10
col sql_quarantine heading "SQL|Quarantine" format a10
col elapsed_avg heading "Avg|Elapsed|Time (ms)" format 999,999.99
col executions heading "|Executions|Count" format 999,999,999
col non_default_param heading "Non-Default|Optmizer|Param" format 999

with non_default_env as (
 select inst_id, sql_id, child_number, count(*) as param_count
   from gv$sql_optimizer_env
  where sql_id = '&1'
    and isdefault = 'NO'
  group by inst_id, sql_id, child_number
)
select s.child_number,
       s.plan_hash_value, 
       s.first_load_time,
       s.optimizer_mode,
       s.optimizer_cost,
       x.param_count as non_default_param,
       s.is_bind_aware,
       s.is_shareable,
       s.is_bind_sensitive,
       s.is_reoptimizable,
       s.is_resolved_adaptive_plan,
       s.is_obsolete,
       s.sql_quarantine,
       executions as executions,
       round((elapsed_time / 1000) / greatest(executions,1),4) as elapsed_avg
from gv$sql s
left join non_default_env x on (s.sql_id = x.sql_id and s.child_number = x.child_number and s.inst_id = x.inst_id)
where s.sql_id =  '&1'
order by plan_hash_value, child_number;