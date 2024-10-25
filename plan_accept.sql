/*
 Maicon Carneiro - 18/01/2023
 script: plan_accept.sql
 Syntax: @plan_accept <Plan Baseline Name>
 
 obtem o SQL_HANDLE do PLAN_NAME e executa a procedure "dbms_spm.evolve_sql_plan_baseline" ignorando a etapa de ENVOLVE.
*/

SET TERMOUT OFF
column sql_handle new_value f_handle
column plan_name new_value f_plan
select sql_handle, plan_name from dba_sql_plan_baselines where plan_name='&1';
SET TERMOUT ON;

PROMP
PROMP Este prodcimento pode levar alguns minutos...
PROMP

SET SERVEROUTPUT ON
SET LONG 10000
DECLARE
 report clob;
BEGIN
report := dbms_spm.evolve_sql_plan_baseline (
 '&f_handle',
 '&f_plan',
  VERIFY=>'NO' ,
  COMMIT=>'YES'
  );
DBMS_OUTPUT.PUT_LINE(report);
END;
/