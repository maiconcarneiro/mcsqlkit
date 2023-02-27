-- Author: Maicon Carneiro (dibiei.com)
/*
Maicon Carneiro 24/11/2022
Script para executar o SQL Tune Advisor para um SQL ID automaticamente em Background pegando dados do AWR
Exemplo: SQL> @sta2 <SQL_ID> <begin snap> <end snap>
*/

SET SERVEROUTPUT ON;
declare
stmt_task VARCHAR2(40);
stmt_sqlid VARCHAR2(40) := '&1';
vJobName VARCHAR2(100);
begin 
 stmt_task := dbms_sqltune.create_tuning_task(begin_snap => &2, end_snap=> &3, sql_id => stmt_sqlid);
 vJobName := 'STA_' || stmt_task || '_' || stmt_sqlid || '_awr';
 
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