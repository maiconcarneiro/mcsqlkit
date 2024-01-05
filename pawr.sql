undef SQLID
set pages 4000
select * from table(dbms_xplan.display_awr(sql_id=>'294umd4hf6kfv',format => '+COST +BYTES'));
