-- Author: Maicon Carneiro (dibiei.com)
select module, count(*) as qtde
from v$session s
where 1=1
and s.type <>'BACKGROUND'
and s.status = 'ACTIVE'
group by s.module
order by 2 desc;
