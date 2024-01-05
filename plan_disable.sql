/*
 Maicon Carneiro - 31/12/2023
 script: plan_disable.sql
 Syntax: @plan_disable <Plan Baseline Name>
 
 obtem o SQL_HANDLE do PLAN_NAME e chama o script modify_baseline_helper
*/

SET TERMOUT OFF
column sql_handle new_value f_handle
column plan_name new_value f_plan
select sql_handle, plan_name from dba_sql_plan_baselines where plan_name='&1';
SET TERMOUT ON;

@modify_baseline_helper &f_handle &f_plan ENABLED NO