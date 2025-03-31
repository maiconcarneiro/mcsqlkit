/*
 script: purge.sql
 This script find all cursors of a specified SQL_ID and force the purge from the Shared Pool in all intances.

 Syntax: @purge <SQL_ID>

 Author: Maicon Carneiro (dibiei.blog)
*/

set feedback off;
set verify off;

PROMP

set serveroutput on;
declare
 vJobName varchar2(200);
 vSQL_ID varchar2(15) := '&1';
 cursor listaCursores is
    select inst_id, sql_id, hash_value, 'begin SYS.DBMS_SHARED_POOL.PURGE ('''||address||','||hash_value||''',''C''); end;' cmd 
      from GV$SQLAREA 
     where SQL_ID = vSQL_ID
  order by inst_id;

begin
  for i in listaCursores loop
  if i.inst_id = sys_context('USERENV','INSTANCE') then 
  -- normal execution for local node
   vJobName := 'LOCAL';
   dbms_output.put_line('INFO: Executing: ' || i.cmd);
   execute immediate i.cmd ;
  else
     -- create a Job to execute in remote node
      vJobName := '"P_' || i.sql_id || '_' || i.hash_value || '_' || i.inst_id || '"';
      dbms_scheduler.create_job 
      (  
        job_name      =>  vJobName,  
        job_type      =>  'PLSQL_BLOCK',  
        job_action    =>  i.cmd,  
        start_date    =>  systimestamp,  
        enabled       =>  FALSE,  
        auto_drop     =>  TRUE,  
        comments      =>  'Purge cursor with SQL ID ' || i.sql_id || ' and Plan Hash Value ' || i.hash_value || ' on instance ' || i.inst_id
       );
      dbms_scheduler.set_attribute (name => vJobName, attribute => 'INSTANCE_ID', value => i.inst_id);
      dbms_scheduler.enable (name => vJobName);
      dbms_output.put_line('INFO: JOB ' || vJobName || u'\000A' || i.cmd || u'\000A' || ' at node ' || i.inst_id);
  end if;
 end loop;
 
 if vJobName is null then
   dbms_output.put_line('WARNING: Cursor not found for SQL_ID ' || vSQL_ID);
 end if;
end;
/

set feedback on;