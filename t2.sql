
set feedback off
set heading off
set verify off
set sqlformat
set lines 1000
set long 999999999
--select sql_text from dba_hist_sqltext where sql_id='&1' and rownum=1;
select dbms_lob.substr(sql_text,32000,1)  as sql_text from dba_hist_sqltext where sql_id='&1' and rownum=1;
set heading on
set feedback on
