set long 1000;
set longchunksize 1000
set pagesize 10000
set lines 1000
set heading off
SELECT DBMS_SQLTUNE.SCRIPT_TUNING_TASK(owner_name=>USER, task_name=> '&1') AS script FROM dual;
set heading on;