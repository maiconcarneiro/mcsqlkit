PROMP

set feedback off;
set sqlformat
set linesize 300
col inst_id heading "Inst | ID" format 99
col sql_id format a18
col last_load_time heading 'Last| Load time' format a20
col child heading "#" format 99
col get_plan heading 'Explain' format a7 
col plan_hash_value heading "Plan | Hash Value" format 999999999999
col sql_profile format a30
col sql_plan_baseline format a30
col sql_patch format a30
col signature format 999999999999999999999
col is_bind_sensitive heading "Is|Bind|Sens"
col is_bind_aware heading "Is|Bind|Aware"

def _LAST_SQL_ID=&1;

col parsing_schema_name new_value _SQL_PARSING_SCHEMA_NAME
col module new_value _SQL_MODULE
col exact_matching_signature new_value _SIGNATURE
set termout off;
select parsing_schema_name, module, to_char(exact_matching_signature) as exact_matching_signature 
  from gv$sql 
 where sql_id='&_LAST_SQL_ID' 
   and rownum=1;
set termout on;


PROMP
PROMP SQL Id............: &_LAST_SQL_ID
PROMP Exact  Signature..: &_SIGNATURE
PROMP Schema Name.......: &_SQL_PARSING_SCHEMA_NAME
PROMP Module............: &_SQL_MODULE
PROMP
PROMP # = Child Number

select inst_id, 
       --sql_id, 
	   plan_hash_value, 
	   --child_number as child, 
	   '@chp ' || child_number as get_plan,
	   last_load_time, 
	   sql_profile, 
	   sql_plan_baseline, 
	   sql_patch, 
	   --exact_matching_signature as signature,
	   is_bind_sensitive,
	   is_bind_aware 
from   gv$sql 
where  sql_id='&_LAST_SQL_ID';

set feedback on;
PROMP
