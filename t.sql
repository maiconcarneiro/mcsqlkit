set lin 1000
col sql_text format a500
select sql_text from v$sql where sql_id='&1';
