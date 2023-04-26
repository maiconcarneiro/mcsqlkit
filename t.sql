-- Author: Maicon Carneiro (dibiei.com)
set feedback off
set heading off
set verify off
set lines 400
set long 999999999
select sql_fulltext from gv$sql where sql_id='&1' and rownum=1;
set heading on
set feedback on
