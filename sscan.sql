set sqlformat
set verify off
col mbytes format 999,999,999,999.99
select s.name, m.value/1024/1024 mbytes
from gv$sesstat m, v$sysstat s 
where m.statistic#=s.statistic# 
and (s.name like '%physical IO%' or s.name like '%optimized%' or s.name like 'physical%total bytes')
and m.sid = &1
and m.inst_id = &2;
