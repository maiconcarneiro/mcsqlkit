column NODE new_value vNODE 
column CNAME new_value vCNAME 
COLUMN DBID NEW_VALUE _DBID
COLUMN CON_DBID NEW_VALUE _CON_DBID
COLUMN CON_NAME NEW_VALUE _CON_NAME
COLUMN CON_NAME_COLOR NEW_VALUE _CON_NAME_COLOR
COLUMN CONN_TYOE_MSG_INFO NEW_VALUE _CONN_TYOE_MSG_INFO
select dbid,
       &_CON_DBID_COL as con_dbid,
       sys_context('USERENV','DB_NAME') as CON_NAME,
       'blue' CON_NAME_COLOR,
       'INFO: Connected in the PDB' as CONN_TYOE_MSG_INFO,
        instance_name AS NODE,
        sys_context('USERENV','DB_NAME') as CNAME 
from v$database, v$instance;