set feedback off;
set verify off;


PROMP

set serveroutput on;
declare
 vJobName varchar2(200);
 cursor cursor_list is
    select inst_id, sql_id, hash_value, 'SYS.DBMS_SHARED_POOL.PURGE ('''||address||','||hash_value||''',''C'');' cmd 
      from GV$SQLAREA 
     where plan_hash_value = &1 
  order by inst_id;

begin
  for i in cursor_list loop
    -- 11g
	vJobName := '"P_' || i.sql_id || '_' || i.hash_value || '_' || i.inst_id || '"';
    -- create job with auto_drop to run the purge command
    dbms_scheduler.create_job 
    (  
      job_name      =>  vJobName,  
      job_type      =>  'PLSQL_BLOCK',  
      job_action    =>  'begin ' || i.cmd ||' end;',  
      start_date    =>  systimestamp,  
      enabled       =>  FALSE,  
      auto_drop     =>  TRUE,  
      comments      =>  'Purge cursor with SQL ID ' || i.sql_id || ' and Plan Hash Value ' || i.hash_value || ' on instance ' || i.inst_id
     );

    dbms_scheduler.set_attribute (name => vJobName, attribute => 'INSTANCE_ID', value => i.inst_id);
    dbms_scheduler.enable (name => vJobName);

    dbms_output.put_line('JOB: ' || vJobName || u'\000A' || i.cmd || u'\000A');
 end loop;
end;
/

set feedback on;