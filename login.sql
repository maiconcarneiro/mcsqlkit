
SET SQLBLANKLINES ON
set termout off;

COLUMN INSTANCE_VERSION NEW_VALUE _ORA_VERSION
COLUMN VERSION_SUFFIX NEW_VALUE _VERSION_SUFFIX
COLUMN CON_DBID_COL NEW_VALUE _CON_DBID_COL
COLUMN CON_NAME_COL NEW_VALUE _CON_NAME_COL
SELECT VERSION,
       instance_name AS NODE, 
       CASE WHEN VERSION < '12.1' THEN '11g' ELSE '' END as VERSION_SUFFIX,
       CASE WHEN VERSION < '12.1' THEN 'dbid' ELSE 'con_dbid' END AS CON_DBID_COL,
       CASE WHEN VERSION < '12.1' THEN 'DB_NAME' ELSE 'CON_NAME' END AS CON_NAME_COL
  FROM V$INSTANCE;


COLUMN DBID NEW_VALUE _DBID
COLUMN CON_DBID NEW_VALUE _CON_DBID
COLUMN CON_NAME NEW_VALUE _CON_NAME
COLUMN CON_NAME_COLOR NEW_VALUE _CON_NAME_COLOR
COLUMN CONN_TYOE_MSG_INFO NEW_VALUE _CONN_TYOE_MSG_INFO
select dbid,
       &_CON_DBID_COL as con_dbid,
       sys_context('USERENV','&_CON_NAME_COL') as CON_NAME,
       case when sys_context('USERENV','&_CON_NAME_COL') = 'CDB$ROOT' then 'red' else 'green' end CON_NAME_COLOR,
       case when sys_context('USERENV','&_CON_NAME_COL') = 'CDB$ROOT' 
            then 'WARNING: Connected in the CDB$ROOT'
            else 'INFO: Connected in the PDB'
        end CONN_TYOE_MSG_INFO
from v$database;

COLUMN MSG_AWR_PDB NEW_VALUE _MSG_AWR_PDB
select case when nvl(max(value),'TRUE') = 'FALSE' 
            then 'WARNING: The AWR is disabled in PDB level. See parameter awr_pdb_autoflush_enabled'
            else ''
      end MSG_AWR_PDB
from v$parameter
where name = 'awr_pdb_autoflush_enabled';

set termout on;


-- format sqlcl
PROMP
@f1
PROMP &_CONN_TYOE_MSG_INFO 
PROMP &_MSG_AWR_PDB
PROMP

set sqlformat
set verify off