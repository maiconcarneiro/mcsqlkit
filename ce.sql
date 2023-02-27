-- Author: Maicon Carneiro (dibiei.com)
set lin 1000
col event format a40 trunc
select * from (
select s.sql_id, s.event, count(*) as qtde
from gv$session s
where 1=1
and s.type <>'BACKGROUND'
and s.status = 'ACTIVE'
--and s.program not like 'sqlplus%'
group by s.sql_id, s.event
order by 1,3 desc
);
--where rownum <=10;
