-- Author: Maicon Carneiro (dibiei.com)
undef SQLID
set pages 4000
select * from table(dbms_xplan.display_awr(sql_id => '&1', plan_hash_value => '&2'));
