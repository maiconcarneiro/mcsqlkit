/*
 Script para contar sessoes ativas de usuario em diferentes niveos de agrupamento.
 Sintaxe: @count <column_list> <inst_id>
 Exemplos:
  @count sql_id 0
  @count username,module 0
  @count sql_id,event 1
  @count sql_id,event 2
  @count username,osuser,program,module,machine 0

 Maicon Carneiro | dibiei.blog
 Last Updated: 25/10/2024
*/

set lin 1000
col inst_id format 99
col active format 999,999,999
col inactive format 999,999,999
col killed format 999,999,999
col total format 999,999,999
select &1, 
       count(case when s.status = 'ACTIVE' then 1 else null end) as active,
       count(case when s.status = 'INACTIVE' then 1 else null end) as inactive,
       count(case when s.status = 'KILLED' then 1 else null end) as killed,
       count(*) as total
from gv$session s
where 1=1
and s.type <>'BACKGROUND'
and (nvl(&2,0) = 0 or inst_id = &2)
group by &1
order by &1;
