set long 1000000;
set longchunksize 1000
set pagesize 10000
set linesize 1000
set heading off
select dbms_sqltune.report_tuning_task(
    task_name=> UPPER('&1'), 
    OWNER_NAME=> UPPER(USER) 
) as task_output 
from dual;
set heading on;