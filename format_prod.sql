-- Author: Maicon Carneiro (dibiei.com)
set sqlprompt "@|blue _USER|@@@|red _CONNECT_IDENTIFIER|@@|blue > |@";
SELECT INSTANCE_NAME, STATUS, HOST_NAME, DATABASE_ROLE, OPEN_MODE, TO_CHAR(STARTUP_TIME,'DD/MM/YYYY HH24:MI:SS') AS STARTUP_TIME FROM V$INSTANCE, V$DATABASE;
alter session set optimizer_mode=rule;
