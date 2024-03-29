set linesize 400
set pages 100
col inst_id format 99
col name format a30
col DATATYPE_STRING format a30
col VALUE_STRING format a30
col LAST_CAPTURED format a30
SELECT INST_ID, CHILD_NUMBER, NAME, DATATYPE_STRING,VALUE_STRING, to_char(LAST_CAPTURED,'dd/mm/yyyy hh24:mi:ss') as LAST_CAPTURED
FROM GV$SQL_BIND_CAPTURE 
WHERE 1=1
AND SQL_ID='&1'
ORDER BY INST_ID, CHILD_NUMBER, NAME;
