set feedback off
set heading off
set verify off
set sqlformat
set lines 1000
set long 999999
col sql_text format a500
select format_sql(sql_text)  as sql_text from dba_hist_sqltext where sql_id='&1' and rownum=1;
set heading on
set feedback on



select format_sql(sql_text)
from dba_hist_sqltext
where sql_id = '&1'
and rownum = 1;