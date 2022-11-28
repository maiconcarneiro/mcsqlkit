set verify off
select a.sql_id, b.plan_hash_value, count(distinct (to_char(a.sid) || '.' || to_char(a.serial#) || '.' || to_char(a.inst_id))) as sessoes
from gv$session a
join gv$sql b on a.sql_id = b.sql_id and a.inst_id = b.inst_id and a.sql_child_number = b.child_number
where a.type='USER'
and a.sql_id='&1'
group by a.sql_id, b.plan_hash_value;
