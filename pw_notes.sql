set lines 400
col sql_id format a15
col plan_hash_value HEADING "Plan|Hash Value"  format 99999999999999
col adaptive_plan  HEADING "Is|Adaptive?" format a10
SELECT p.sql_id, p.plan_hash_value, x.adaptive_plan
FROM dba_hist_sql_plan p,
     XMLTABLE('/other_xml/info[@type="adaptive_plan"]' 
              PASSING XMLTYPE(p.other_xml) 
              COLUMNS adaptive_plan VARCHAR2(10) PATH 'text()') x
WHERE p.other_xml IS NOT NULL
and sql_id = '&1';