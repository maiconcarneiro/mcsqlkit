/*
 Helper script for list SPM baseline for an SQL_ID using the exact matching signature
 Example: @plan_list <SQL_ID>
 
 Maicon Carneiro | dibiei.blog
*/

PROMP SQL_ID....: &1
SET FEEDBACK OFF
SET VERIFY OFF
SET TERMOUT OFF;
COL exact_matching_signature NEW_VALUE signature_value format 999999999999999999999999999999
select distinct exact_matching_signature 
  from gv$sql 
 where sql_id='&1';

SET TERMOUT ON;

@plan_list2 &signature_value