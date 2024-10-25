set lin 1000
col inst_id format 99
col host_name format a30
col status format A10
col logins format A10
col startup_time format a20
col active format 999,999,999
col inactive format 999,999,999
col killed format 999,999,999
col total format 999,999,999
select s.inst_id, 
       count(case when s.status = 'ACTIVE' then 1 else null end) as active,
       count(case when s.status = 'INACTIVE' then 1 else null end) as inactive,
       count(case when s.status = 'KILLED' then 1 else null end) as killed,
       count(*) as total
from gv$session s
where 1=1
and s.type <>'BACKGROUND'
and s.status = 'ACTIVE'
group by s.inst_id
order by 1;
