set sqlprompt "@|blue _USER|@@@|red _CONNECT_IDENTIFIER|@@|blue > |@";
col host_name format a30
col startup_time format a20
col current_date format a20
SELECT INSTANCE_NAME, STATUS, HOST_NAME, DATABASE_ROLE, OPEN_MODE, TO_CHAR(STARTUP_TIME,'DD/MM/YYYY HH24:MI:SS') AS STARTUP_TIME,
TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')  AS CURRENT_DATE
FROM V$INSTANCE, V$DATABASE;
alter session set optimizer_mode=rule;

-- set sqlprompt "@|blue _USER|@@@|red _CON_NAME|@@|blue > |@";