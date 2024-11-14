/*
  script: sta.sql
  This script can create a SQL Tuning Advisor task and run it in background using Oracle Schduler

  The script will try to create the task using the Cursor Cache when possible. 
  If SQL_ID is not present in the Cursor Cache, the script will use AWR automatically.

  Syntax:
  @sta <SQL_ID>


  Maicon Carneiro | dibiei.blog

   Date       Author             | History
 ----------- -------------------- ------------------------------------------------------------------------
 04/11/2022 | Maicon Carneiro    | Script sta.sql created supporting Cursor Cache only
 24/04/2022 | Maicon Carneiro    | Script sta2.sql created supporting AWR only and requiring snapshots to be passed in parameters
 13/11/2024 | Maicon Carneiro    | Script sta.sql enhaced to include the AWR funcionality in dynamic way.

*/

PROMP
SET SERVEROUTPUT ON;
declare
vTASK VARCHAR2(40);
vTimeLimit number := 86400;
vSQL_ID VARCHAR2(40) := '&1';
vJobName VARCHAR2(100);
vCount number := 0;
vSource varchar2(20);
vMaxSnap number;
begin 

  -- try to get sql_text of the sql_id from CursorCache
  select count(*) into vCount from gv$sql where sql_id = vSQL_ID and rownum=1;
  if vCount > 0 then 
   vSource := 'Cursor Cahce';
   vTASK := dbms_sqltune.create_tuning_task(sql_id => vSQL_ID, time_limit => vTimeLimit);
  end if;
  
  -- if no present in CursorCache, try to get sql_text of the sql_id from AWR
  if vSource is null then
   select count(*) into vCount from dba_hist_sqltext where sql_id = vSQL_ID and rownum=1;
   if vCount > 0 then 
    vSource := 'AWR';
    select max(snap_id) into vMaxSnap from dba_hist_sqlstat where sql_id=vSQL_ID;
    vTASK := dbms_sqltune.create_tuning_task(begin_snap => vMaxSnap-1, end_snap=> vMaxSnap, sql_id => vSQL_ID, time_limit => vTimeLimit);
   end if;
  end if;

  vJobName := 'STA_' || vTASK || '_' || vSQL_ID;
 
   dbms_scheduler.create_job 
   (  
     job_name      =>  vJobName,  
     job_type      =>  'PLSQL_BLOCK',  
     job_action    =>  'begin dbms_sqltune.execute_tuning_task(task_name => '''|| vTASK ||'''); end;',  
     start_date    =>  systimestamp,  
     enabled       =>  true,  
     auto_drop     =>  true,  
     comments      =>  'Run SQL Tuning Advisor Task ' || vTASK || ' for SQL ID ' || vSQL_ID
    );
 
 dbms_output.put_line ('JOB ' || vJobName || ' executing Task ' || vTASK || ' using ' || vSource);
end;
/