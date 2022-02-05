set verify off
set lin 1000
select sql_id, 
	   plan_hash_value,
       sum(executions) exec,
       sum(buffer_gets)/sum(executions) buff_avg,
	   sum(disk_reads)/sum(executions) disk_avg,
       sum(rows_processed)/sum(executions) linh_avg,
	   sum(cpu_time/1000)/sum(executions) cpu_avg,
	   sum(elapsed_time/1000)/sum(executions) elap_avg
from gv$sql
where sql_id in ('&1')
group by sql_id, plan_hash_value
order by 1;
