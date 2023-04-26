-- Author: Maicon Carneiro (dibiei.com)
set verify off
set lin 1000
col event format a40 trunc
select * from (
select s.sql_id, s.event, count(*) as qtde
from gv$session s
join gv$sql b on s.sql_id = b.sql_id and s.inst_id = b.inst_id and s.sql_child_number = b.child_number
where 1=1
and s.type <>'BACKGROUND'
and s.status = 'ACTIVE'
and s.sql_id='&1'
and b.plan_hash_value=&2
--and s.program not like 'sqlplus%'
group by s.sql_id, s.event
order by 1,3 desc
);
--where rownum <=10;
