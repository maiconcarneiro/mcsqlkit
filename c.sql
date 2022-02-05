select * from (
select s.sql_id, count(*) as qtde
from v$session s
where 1=1
and s.type <>'BACKGROUND'
and s.status = 'ACTIVE'
group by s.sql_id
order by 2 desc
)
where rownum <=10;
