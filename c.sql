select * from (
select nvl(s.sql_id, s.prev_sql_id) as sql_id, count(*) as qtde
from gv$session s
where 1=1
and s.type <>'BACKGROUND'
and s.status = 'ACTIVE'
group by nvl(s.sql_id, s.prev_sql_id)
order by 2 desc
)
where rownum <=10;
