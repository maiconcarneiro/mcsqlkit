set feedback off;
set verify off;


PROMP

set serveroutput on;
declare
 vJobName varchar2(200);
 cursor listaCursores is
    select inst_id, sql_id, hash_value, 'SYS.DBMS_SHARED_POOL.PURGE ('''||address||','||hash_value||''',''C'');' cmd 
      from GV$SQLAREA 
     where SQL_ID = '&1' 
  order by inst_id;

begin
  for i in listaCursores loop
    -- 11g
	vJobName := '"P_' || i.sql_id || '_' || i.hash_value || '_' || i.inst_id || '"';
    -- cria job com auto_drop para executar o comando de purge
    dbms_scheduler.create_job 
    (  
      job_name      =>  vJobName,  
      job_type      =>  'PLSQL_BLOCK',  
      job_action    =>  'begin ' || i.cmd ||' end;',  
      start_date    =>  systimestamp,  
      enabled       =>  FALSE,  
      auto_drop     =>  TRUE,  
      comments      =>  'Limpa cursor com SQL ID ' || i.sql_id || ' e Plan Hash Value ' || i.hash_value || ' na instance ' || i.inst_id
     );

    dbms_scheduler.set_attribute (name => vJobName, attribute => 'INSTANCE_ID', value => i.inst_id);
    dbms_scheduler.enable (name => vJobName);

    dbms_output.put_line('JOB: ' || vJobName || u'\000A' || i.cmd || u'\000A');
 end loop;
end;
/

set feedback on;