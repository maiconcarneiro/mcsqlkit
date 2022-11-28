@ch.sql &1

def SPA_sqlset = 'SQLSET_OCI';
set serveroutput on
declare
l_num_plans PLS_INTEGER;
begin
l_num_plans := DBMS_SPM.LOAD_PLANS_FROM_SQLSET (sqlset_name=> '&SPA_sqlset',sqlset_owner=>'SYS' ,basic_filter=>'sql_id=''&1'' and plan_hash_value=&2');
DBMS_OUTPUT.put_line('Number of plans loaded: ' || l_num_plans);
end;
/

@purge &1
