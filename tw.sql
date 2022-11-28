set heading off
set verify off
set lines 400
set long 999999999
select sql_text from DBA_HIST_SQLTEXT where sql_id='&1' and rownum=1;
set heading on
