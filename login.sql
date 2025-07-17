
@_query_dbid

SET TAB OFF;
SET SQLBLANKLINES ON;
set termout off
set feedback off;

COLUMN VERSION NEW_VALUE _ORA_VERSION
COLUMN VERSION_SUFFIX NEW_VALUE _VERSION_SUFFIX
COLUMN CON_DBID_COL NEW_VALUE _CON_DBID_COL
COLUMN CON_NAME_COL NEW_VALUE _CON_NAME_COL
SELECT VERSION,
       instance_name AS NODE, 
       CASE WHEN VERSION < '12.1' THEN '11g' ELSE '' END as VERSION_SUFFIX,
       CASE WHEN VERSION < '12.1' THEN 'dbid' ELSE 'con_dbid' END AS CON_DBID_COL,
       CASE WHEN VERSION < '12.1' THEN 'DB_NAME' ELSE 'CON_NAME' END AS CON_NAME_COL
  FROM V$INSTANCE;


column NODE new_value vNODE 
column CNAME new_value vCNAME 
COLUMN DBID NEW_VALUE _DBID
COLUMN CON_DBID NEW_VALUE _CON_DBID
COLUMN CON_NAME NEW_VALUE _CON_NAME
COLUMN CON_NAME_COLOR NEW_VALUE _CON_NAME_COLOR
COLUMN CONN_TYPE_MSG_INFO NEW_VALUE _CONN_TYPE_MSG_INFO
@_get_dbname&_VERSION_SUFFIX

/*
begin
  if '&_ORA_VERSION' >= '12.1' then
    
  end if;
end;
*/


/*
COLUMN MSG_AWR_PDB NEW_VALUE _MSG_AWR_PDB
select case when '&_ORA_VERSION' < '12.1' then ''
            when nvl(max(value),'TRUE') = 'FALSE' then 'WARNING: The AWR is disabled in PDB level. See parameter awr_pdb_autoflush_enabled'
            else ''
      end MSG_AWR_PDB
from v$parameter
where name = 'awr_pdb_autoflush_enabled';
*/

COLUMN ora_edition NEW_VALUE _ORA_EDITION
COLUMN repo_type NEW_VALUE _REPO_TYPE
select case when v.banner like '%Enterprise%' or v.banner like '%EE%' then 'EE' else 'SE' end as ora_edition,
       case when (v.banner like '%Enterprise%' or v.banner like '%EE%') and p.value like 'DIAGNOSTIC%' then 'awr' else 'sp' end as repo_type 
from v$version v, v$parameter p
where v.banner like 'Oracle Database%'
  and p.name = 'control_management_pack_access';

set termout on;


@_format_auto
PROMP **********************************************************************
PROMP &&_CONN_TYPE_MSG_INFO 
--PROMP &&_MSG_AWR_PDB
PROMP **********************************************************************

set verify off;
set feedback on;
set termout on;