column NODE new_value VNODE
column CNAME new_value VCNAME
column SUBQUERY_DBID new_value _SUBQUERY_DBID
column DB_NAME       new_value _DBNAME
SET TERMOUT OFF
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE,
       MAX(CASE WHEN VERSION < '12.1' 
            THEN  sys_context('USERENV','DB_NAME')
            ELSE  sys_context('USERENV','CON_NAME')
       END) AS CNAME,
       MAX('SELECT DBID FROM V$DATABASE') AS SUBQUERY_DBID
FROM GV$INSTANCE;

SET termout ON


/*
 19/03/2025 - backup
        MAX(CASE WHEN VERSION < '12.1' 
            THEN 'SELECT DBID FROM V$DATABASE' 
            ELSE 'SELECT DBID FROM V$CONTAINERS WHERE CON_ID = SYS_CONTEXT(''USERENV'',''CON_ID'')'
       END) AS SUBQUERY_DBID
*/