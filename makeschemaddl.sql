SET ECHO OFF;
SET FEEDBACK OFF;
SET HEAD OFF;
SET LONG 5000000;
SET LINESIZE 120;
SET PAGESIZE 0;
SET VER OFF;
COL TXT FOR A120;

SPOOL schema_ddl_&&Username..sql
PROMPT SPOOL schema_ddl_&&Username..log

EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);


select (case 
        when ((select count(*)
               from   dba_users
               where  username = '&&Username') > 0)
        then  dbms_metadata.get_ddl ('USER', '&&Username') 
        else  to_clob ('   -- Note: User not found!')
        end ) AS TXT from dual 
UNION ALL
select (case 
        when ((select count(*)
               from   dba_ts_quotas
               where  username = '&&Username') > 0)
        then  dbms_metadata.get_granted_ddl( 'TABLESPACE_QUOTA', '&&Username') 
        else  to_clob ('   -- Note: No TS Quotas found!')
        end ) AS TXT from dual 
UNION ALL
select (case 
        when ((select count(*)
               from   dba_role_privs
               where  grantee = '&&Username') > 0)
        then  dbms_metadata.get_granted_ddl ('ROLE_GRANT', '&&Username') 
        else  to_clob ('   -- Note: No granted Roles found!')
        end ) AS TXT from dual 
UNION ALL
select (case 
        when ((select count(*)
               from   dba_sys_privs
               where  grantee = '&&Username') > 0)
        then  dbms_metadata.get_granted_ddl ('SYSTEM_GRANT', '&&Username') 
        else  to_clob ('   -- Note: No System Privileges found!')
        end ) AS TXT from dual 
UNION ALL
select (case 
        when ((select count(*)
               from   dba_tab_privs
               where  grantee = '&&Username') > 0)
        then  dbms_metadata.get_granted_ddl ('OBJECT_GRANT', '&&Username') 
        else  to_clob ('   -- Note: No Object Privileges found!')
        end ) AS TXT from dual 
/
PROMPT SPOOL OFF


SPOOL OFF
unDEFINE Username
SET ECHO ON;
SET FEEDBACK ON;
SET HEAD ON;
SET VER ON;