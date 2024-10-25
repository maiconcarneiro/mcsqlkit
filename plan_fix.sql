/*
 Maicon Carneiro - 31/12/2023
 Script: plan_add.sql
 Syntax: @plan_add <SQL ID> <PLAN HASH VALUE>
 
 Cria um baseline no SPM importando o plano do CursorCache, ou do AWR (12cR2+)
*/


PROMP
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
BEGIN

 vSQL_ID := '&1';
 vHashPlan := &2;
 
IF vSQL_ID = '' or vHashPlan = 0 THEN 
 dbms_output.put_line('Provide the SQL ID and Plan Hash Value');
 null;
END IF;

 select count(*) into vCheckCursor 
   from gv$sql 
  where sql_id = vSQL_ID 
    and plan_hash_value = vHashPlan;

 if vCheckCursor > 0 then 
  vLoad := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (SQL_ID => '&1', PLAN_HASH_VALUE => &2);
   if vLoad > 0 then 
    dbms_output.put_line('INFO: Baseline criado com sucesso');
    dbms_output.put_line('Origem: CursorCache');
   else
    dbms_output.put_line('WARNING: Nenhum baseline criado.');
   end if;
  else
  
  -- get the latest AWR snapshot
  select nvl( max(snap_id)-1 ,0) , nvl( max(snap_id) ,0) into vSnapMin, vSnapMax
   from dba_hist_sqlstat 
  where sql_id = vSQL_ID
    and plan_hash_value = vHashPlan
    and executions_total > 0;
 
  if vSnapMin = 0 then 
   dbms_output.put_line('ERROR: Nao encontrado historico no AWR para o SQL_ID e PLAN_HASH_VALUE informado.');
   return;
  end if;
  
   -- get database version
  select version into vVersion  
    from v$instance;
	
  -- exit if this database version don't support LOAD_PLANS_FROM_AWR
  if vVersion < '12.2' then 
   dbms_output.put_line('ERROR: Plano indisponivel no CursorCache e essa versao do Oracle nao suporta import do AWR.');
   dbms_output.put_line('');
   dbms_output.put_line('Tente usar a opcao "Importando Plano de um SQL Tuning Set (STS)", conforme demonstrado no blog post abaixo:');
   dbms_output.put_line('https://dibiei.blog/en/2022/09/26/3-abordagens-diferentes-para-fixar-planos-de-execucao-de-comandos-sql-no-oracle-database/');
   return;
  end if;
  
 -- dynamycally create BasicFilter string with SQL_ID and PLAN_HASH_VALUE
 vBasicFilter := 'sql_id=''''' || vSQL_ID || ''''' and plan_hash_value=''''' || vHashPlan || ''''' ' ;
 vBasicFilter := '''' || vBasicFilter || '''';
 
 -- dynamycally create PL/SQL code to cal LOAD_PLANS_FROM_AWR if the version is 12.2 or higher
 vSQL := '
       DECLARE
        vLoad varchar2(20);
       BEGIN
        vLoad := DBMS_SPM.LOAD_PLANS_FROM_AWR( 
         BEGIN_SNAP   => ' || vSnapMin     ||',
         END_SNAP     => ' || vSnapMax     ||',
         BASIC_FILTER => ' || vBasicFilter ||'
         );
         
        if vLoad > 0 then 
         dbms_output.put_line(''INFO: Baseline criado com sucesso'');
         dbms_output.put_line(''Origem: AWR'');
        else
         dbms_output.put_line(''WARNING: Nenhum baseline criado.'');
        end if;
         
        END;  
      ';
  
  -- execute the PL/SQL code calling the LOAD_PLANS_FROM_AWR procedure
  execute immediate vSQL;
 end if;

END;
/