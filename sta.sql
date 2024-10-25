/*
Maicon Carneiro 04/11/2022
Script para executar o SQL Tune Advisor para um SQL ID automaticamente em Background
Exemplo: SQL> @sta <SQL_ID>
*/
PROMP
SET SERVEROUTPUT ON;
declare
stmt_task VARCHAR2(40);
stmt_sqlid VARCHAR2(40) := '&1';
vJobName VARCHAR2(100);
begin 
 stmt_task := dbms_sqltune.create_tuning_task(sql_id => stmt_sqlid,  time_limit => 86400);
 vJobName := 'STA_' || stmt_task || '_' || stmt_sqlid;
 
   dbms_scheduler.create_job 
   (  
     job_name      =>  vJobName,  
     job_type      =>  'PLSQL_BLOCK',  
     job_action    =>  'begin dbms_sqltune.execute_tuning_task(task_name => '''|| stmt_task ||'''); end;',  
     start_date    =>  systimestamp,  
     enabled       =>  true,  
     auto_drop     =>  true,  
     comments      =>  'Run SQL Tuning Advisor Task ' || stmt_task || ' for SQL ID ' || stmt_sqlid
    );
 
 dbms_output.put_line ('JOB ' || vJobName || ' executing Task ' || stmt_task);
end;
/