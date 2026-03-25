alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
set tab off;
set lines 200
col instance_name format a15
col host_name format a30
select i.inst_id, i.status, d.database_role, d.open_mode, i.instance_name, i.host_name, i.logins, i.startup_time
from gv$instance i 
join gv$database d on i.inst_id=d.inst_id
order by 1;