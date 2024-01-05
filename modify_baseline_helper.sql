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
  dbms_output.put_line('ERROR: Nao existe baseline com esse nome.');
  dbms_output.put_line('Use o script "@plan_list <SQL ID>" para listar os planos existentes de um SQL ID.');
  return;
 end if;
 
 -- get current attributes
 select to_char(last_modified,'DD/MM/YYYY HH24:MI:SS'), &3 into vModifiedBefore, vValueBefore 
   from dba_sql_plan_baselines 
  where sql_handle='&1' and plan_name='&2';
 
 -- exit if then change is not required
 if vValueBefore = vValueAfter then
  dbms_output.put_line('WARNING: O baseline nao precisa ser alterado.');
  dbms_output.put_line('O valor atual do atributo corresponde ao que esta sendo informado.');
  return;
 end if;
 
 -- change the baseline attribute if exists
 vChange:= DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
   sql_handle      => '&1',
   plan_name       => '&2',
   attribute_name  => '&3',
   attribute_value => '&4');
   
   if vChange > 0 then 
    dbms_output.put_line('INFO: Baseline alterado com sucesso.' || chr(13) );
	dbms_output.put_line('SQL Handle.........: &1');
	dbms_output.put_line('Plan Name..........: &2');
	dbms_output.put_line('Ultima Modificacao.: ' || vModifiedBefore);
	dbms_output.put_line('Atributo alterado..: &3');
	dbms_output.put_line('Valor anterior.....: ' || vValueBefore);
	dbms_output.put_line('Valor atual........: &4');
   else
    dbms_output.put_line('WARNING: Nenhum baseline foi alterado.');
   end if;
END;
/

SET FEEDBACK ON;