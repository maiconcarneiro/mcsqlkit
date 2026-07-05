set verify off
set pages 0
set linesize 300
set feedback off
col comando format a250
promp
promp *************** Commands to Kill Sessions Based on Filter &1 *****************************
select 'ALTER SYSTEM KILL SESSION '''||b.SID||','||b.SERIAL#||',@'||b.INST_ID||''' immediate;' as comando
from gv$session b
where type = 'USER'
and &1
;
promp
set feedback on