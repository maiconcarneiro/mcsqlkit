set lines 200
set pages 50
col class format 9999
col statistic# format 99999
col name format a80
select class, statistic#, name 
from v$statname
where name like lower('%&1%')
order by name;