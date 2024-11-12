set lines 400
col text_line format a60
with base_plan_table as ( /*+ MATERIALIZE */
select id, parent_id, position, depth, operation, options, object_name
from v$sql_plan 
where 1=1
and sql_id='&1' 
and child_number = &2
order by id
)
select
	id, parent_id, position, depth, level-1 as old_depth,
	rpad(' ',level -1) ||
		operation || ' ' ||
		lower(options) || ' ' ||
		object_name	as text_line
from
	base_plan_table
start with
	id = 0 
connect by 
	parent_id = prior id
order siblings by id, position
;