set verify off
set termout off

ALTER SESSION SET CONTAINER = &1;

column NODE new_value vNODE 
column CNAME new_value vCNAME 
SELECT instance_name AS NODE, sys_context('USERENV','CON_NAME') as CNAME  FROM V$INSTANCE;
SET termout ON

set sqlprompt "@|blue _USER|@@@|red &vCNAME|@@|blue > |@";
PROMP
