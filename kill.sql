set verify off
set pages 0
set linesize 300
col comando format a250
promp *************** Comandos de Kill para o Filtro &1 *****************************
promp
select 'ALTER SYSTEM KILL SESSION '''||b.SID||','||b.SERIAL#||',@'||b.INST_ID||''' immediate;' as comando
from gv$session b
where type = 'USER'
and &1
;
