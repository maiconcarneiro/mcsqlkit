set long 10000000;
set longchunksize 1000
set pagesize 10000
set lines 1000
set heading off
select dbms_sqltune.report_tuning_task(task_name=> '&1', OWNER_NAME=> UPPER('&2') ) as recomendacoes from dual;
set heading on;