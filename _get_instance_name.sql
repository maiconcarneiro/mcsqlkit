-- testing
-- not used in anywhere until March 24, 2026.

column NODE new_value VNODE 
column CNAME new_value VCNAME 
SET termout off
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE FROM GV$INSTANCE WHERE (&1 = 0 or inst_id = &1);
SELECT sys_context('USERENV','CON_NAME') as CNAME FROM dual;
SET termout ON