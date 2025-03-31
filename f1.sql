set verify off
set termout off
column NODE new_value vNODE 
column CNAME new_value vCNAME 
SELECT instance_name AS NODE, sys_context('USERENV','DB_NAME') as CNAME  FROM V$INSTANCE;
SET termout ON

set sqlprompt '@|blue _USER|@@@|&_CON_NAME_COLOR &vCNAME|@@|white > |@';