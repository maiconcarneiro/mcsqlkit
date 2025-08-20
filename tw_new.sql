set feedback off
set heading off
set verify off


VAR v_sql_text CLOB;
DECLARE 
 vResult CLOB;
BEGIN
 select sql_text into vResult from dba_hist_sqltext where sql_id='&1' and rownum=1;
 :v_sql_text := vResult;
END;
/

spool sqltext_&1..sql
set long 1000000 longchunksize 1000000 linesize 200 head off feedback off echo off
PRINT :v_sql_text
spool off;

set heading on
set feedback on