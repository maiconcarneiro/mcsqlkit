-- Author: Maicon Carneiro (dibiei.com)
DECLARE
 vSnapMin number ;           
 vSQL_ID varchar2(200) := '';
 vHashPlan number      := 0;      
 vLoad varchar2(200);
BEGIN

 vSQL_ID := '&1';
 vHashPlan := &2;
 
IF vSQL_ID = '' or vHashPlan = 0 THEN 
 dbms_output.put_line('Provide the SQL ID and Plan Hash Value');
 null;
END IF;

-- get the latest AWR snapshot
select max(snap_id)-1
into vSnapMin
from dba_hist_sqlstat 
where sql_id = vSQL_ID
and plan_hash_value = vHashPlan
and executions_total > 0;

 vLoad := DBMS_SPM.LOAD_PLANS_FROM_AWR( 
  BEGIN_SNAP   => vSnapMin,
  END_SNAP     => vSnapMin+1,
  BASIC_FILTER => 'sql_id=''' || vSQL_ID || ''' and plan_hash_value=''' || vHashPlan || ''' '
);
DBMS_OUTPUT.put_line('Number of plans loaded: ' || vLoad);
END;
/