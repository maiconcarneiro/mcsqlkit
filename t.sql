set feedback off
set heading off
set verify off
set lines 400
set long 999999
col sql_fulltext format a400
select sql_fulltext from gv$sql where sql_id='&1' and rownum=1;
set heading on
set feedback on
promp 