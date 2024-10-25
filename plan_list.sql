PROMP SQL_ID....: &1
SET FEEDBACK OFF
SET VERIFY OFF
SET TERMOUT OFF;
COL exact_matching_signature NEW_VALUE signature_value
select distinct exact_matching_signature 
  from gv$sql 
 where sql_id='&1';

SET TERMOUT ON;

@plan_list2 &signature_value