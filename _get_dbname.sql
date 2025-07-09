
select dbid,
       &_CON_DBID_COL as con_dbid,
       sys_context('USERENV','CON_NAME') as CON_NAME,

       (case when sys_context('USERENV','CON_ID') = '0' then 'blue' 
             when sys_context('USERENV','CON_ID') = '1' then 'red' 
             else 'green' 
       end) CON_NAME_COLOR,

       (case when sys_context('USERENV','CON_ID') = '0' then 'NO' else 'YES' end) IS_CDB,

       (case when sys_context('USERENV','CON_ID') = '0' 
                then 'INFO: The database is Non-CDB' 
             when sys_context('USERENV','CON_ID') = '1' 
                then 'INFO: Connected in CDB$ROOT' 
             else 'INFO: Connected in PDB'  
       end) CONN_TYPE_MSG_INFO,

        instance_name AS NODE,
        sys_context('USERENV','DB_NAME') as CNAME 

from v$database, v$instance;