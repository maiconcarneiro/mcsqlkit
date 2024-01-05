set lin 1000
col inst_id format 99
col qtde format 999,999,999s
select s.inst_id, count(*) as qtde
from gv$session s
where 1=1
and s.type <>'BACKGROUND'
and s.status = 'ACTIVE'
group by s.inst_id
order by 1;
