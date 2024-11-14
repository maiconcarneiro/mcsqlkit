/*
  script: plan_add.sql
  This script create a SQL Plan Baseline for a specific SQL_ID and PHV (Plan Hash Value)

  1) The script will try to create baseline using the Cursor Cache when possible. 
  2) If SQL_ID is not present in the Cursor Cache, the script will use AWR automatically. 
    a) if the Oracle version is 12.2 or higher, the script will perform a direct load using LOAD_PLANS_FROM_AWR
    b) if the Oracle version is 12.1 or lower, the script will perform a indirect load using LOAD_PLANS_FROM_SQLSET

  Syntax:
  @plan_add <SQL_ID> <PHV>


  Maicon Carneiro | dibiei.blog

   Date       Author             | History
 ----------- -------------------- ------------------------------------------------------------------------
 31/12/2023 | Maicon Carneiro    | First version created to support direct load from Cursor Cache and AWR (12.2+)
 13/11/2024 | Maicon Carneiro    | Added support to load from AWR for versions 11.2 and 12.1 using indirect path
*/

SET VERIFY OFF;
SET FEEDBACK OFF;
SET SERVEROUTPUT ON;

DECLARE  
 vSQL_ID varchar2(200) := '';
 vHashPlan number      := 0;    
 vLoad PLS_INTEGER;
 vCheckCursor number;
 vCheckAWR number;
 vOrigem varchar2(20);
 vVersion varchar2(20);
 vSQL varchar2(4000);
 vBasicFilter varchar2(4000);
 vSnapMin number; 
 vSnapMax number; 
 vSource varchar2(20);
 vCount number;
 vSTS_NAME varchar(30) := 'PLAN_FIX_STS_HELPER_' || USER;
 cur sys_refcursor;
BEGIN

 vSQL_ID := '&1';
 vHashPlan := &2;

IF vSQL_ID = '' or vHashPlan = 0 THEN 
 dbms_output.put_line('ERROR: Provide the SQL ID and Plan Hash Value');
 null;
END IF;

  -- get database version
 select version into vVersion from v$instance;
 
  -- check if the current version is supported
  if vVersion < '11.2' then 
   dbms_output.put_line('ERROR: Version ' || vVersion ||' is not supported by this script.');
   return;
  end if;

 -- check if sql_id is present in cursor cache
 select count(*) into vCheckCursor 
   from gv$sql 
  where sql_id = vSQL_ID 
    and plan_hash_value = vHashPlan;

 if vCheckCursor > 0 then 
   vSource := 'CursorCache';
   vLoad := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (SQL_ID => vSQL_ID, PLAN_HASH_VALUE => vHashPlan);
 end if;
  
  if vSource is null then 
  -- get the latest AWR snapshot
  select nvl( max(snap_id)-1 ,0) , nvl( max(snap_id) ,0) into vSnapMin, vSnapMax
   from dba_hist_sqlstat 
  where sql_id = vSQL_ID
    and plan_hash_value = vHashPlan
    and executions_total > 0;
 

  -- using AWR direct load 
  if vSnapMax > 0 and vVersion >= '12.2' then 

   vSource := 'AWR -> SPM';
   vBasicFilter := ' sql_id = ''' || vSQL_ID || ''' and plan_hash_value = ''' ||  vHashPlan || ''' ';

   -- dynamycally create PL/SQL code to cal LOAD_PLANS_FROM_AWR if the version is 12.2 or higher
    vSQL := '
       DECLARE
          vLoad VARCHAR2(20);
       BEGIN
            vLoad := DBMS_SPM.LOAD_PLANS_FROM_AWR( 
                BEGIN_SNAP   => :vSnapMin,
                END_SNAP     => :vSnapMax,
                BASIC_FILTER => :vBasicFilter
            );
            -- return the value for outside
            :vLoad := vLoad;
       END;';

    -- execute the PL/SQL code calling the LOAD_PLANS_FROM_AWR procedure
    execute immediate vSQL using IN vSnapMin, IN vSnapMax, IN vBasicFilter, OUT vLoad;

  end if;
  

  -- using AWR indirect load 
  if vSnapMax > 0 and vVersion < '12.2' then 

   vSource := 'AWR -> STS -> SPM';
   vBasicFilter := ' sql_id = ''' || vSQL_ID || ''' and plan_hash_value = ''' ||  vHashPlan || ''' ';

   -- create the helper STS if not exists
   select count(*) into vCount from dba_sqlset where name = vSTS_NAME;
   if vCount < 1 then 
     dbms_sqltune.create_sqlset(sqlset_name => vSTS_NAME, description => 'Created by plan_fix script');
   end if;

   -- load the plan from AWR to STS
    open cur for
     select value(p) from table(dbms_sqltune.select_workload_repository(begin_snap => vSnapMin, end_snap => vSnapMax, basic_filter => vBasicFilter)) p;
     dbms_sqltune.load_sqlset(vSTS_NAME, cur);
    close cur;
  
    -- import the plan from STS to SPM
    vLoad := DBMS_SPM.LOAD_PLANS_FROM_SQLSET (sqlset_name=> vSTS_NAME, sqlset_owner => USER ,basic_filter => vBasicFilter);

  end if;



 end if;

dbms_output.put_line('');

if vSource is null then
 dbms_output.put_line('WARNING: Plan hash value  ' || vHashPlan || ' not found for SQL_ID ' || vSQL_ID || '');
 return;
end if;

if vLoad > 0 then 
  dbms_output.put_line('INFO: Baseline successfully created!');
 else
  dbms_output.put_line('WARNING: Baseline not created as expected ...');
end if;
dbms_output.put_line('PATH: ' || vSource);

END;
/