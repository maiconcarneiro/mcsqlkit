/*
 Maicon Carneiro - 31/12/2023
 Script: modify_baseline_helper.sql 
 Syntax: @modify_baseline_helper <SQL Handle> <Plan Name> <Attr Name> <Attr Value>
 
 This script change some SPM Plan attribute using ALTER_SQL_PLAN_BASELINE procedure.
*/
PROMP 
SET FEEDBACK OFF;
SET SERVEROUTPUT ON;
DECLARE
 vChange VARCHAR2(200);
 vQT number;
 vModifiedBefore varchar2(20);
 vModifiedAfter date;
 vValueBefore varchar2(64);
 vValueAfter varchar2(64) := '&4';
 vSqlHandle varchar2(64) := null;
BEGIN
 
 -- verify if the specified SQL Handle and Plan Name existis.
 select count(*) into vQT from dba_sql_plan_baselines where sql_handle='&1' and plan_name='&2';
 
 -- exit if the baseline don't exists.
 if vQT = 0 then 
  dbms_output.put_line('ERROR: No baseline exists with that name.');
  dbms_output.put_line('Use the script "@plan_list <SQL ID>" to list the existing plans for a SQL ID.');
  return;
 end if;
 
 -- get current attributes
 select to_char(last_modified,'YYYY-MM-DD HH24:MI:SS'), &3 into vModifiedBefore, vValueBefore 
   from dba_sql_plan_baselines 
  where sql_handle='&1' and plan_name='&2';
 
 -- exit if then change is not required
 if vValueBefore = vValueAfter then
  dbms_output.put_line('WARNING: The baseline does not need to be changed.');
  dbms_output.put_line('The current attribute value matches the one being provided.');
  return;
 end if;
 
 -- change the baseline attribute if exists
 vChange:= DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
   sql_handle      => '&1',
   plan_name       => '&2',
   attribute_name  => '&3',
   attribute_value => '&4');
   
   if vChange > 0 then 
    dbms_output.put_line('INFO: Baseline successfully changed.' || chr(13) );
	dbms_output.put_line('SQL Handle.........: &1');
	dbms_output.put_line('Plan Name..........: &2');
	dbms_output.put_line('Last Modified......: ' || vModifiedBefore);
	dbms_output.put_line('Attribute Changed..: &3');
	dbms_output.put_line('Previous Value.....: ' || vValueBefore);
	dbms_output.put_line('Current Value......: &4');
   else
    dbms_output.put_line('WARNING: No baseline was changed.');
   end if;
END;
/

SET FEEDBACK ON;