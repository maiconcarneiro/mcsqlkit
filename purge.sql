-- Author: Maicon Carneiro (dibiei.com)
set verify off
undef SQL_ID
select INST_ID, SQL_ID,ADDRESS, HASH_VALUE from GV$SQLAREA where SQL_ID='&1' order by inst_id;
select 'EXEC SYS.DBMS_SHARED_POOL.PURGE ('''||address||','||hash_value||''',''C'');' limpar_memoria from GV$SQLAREA where SQL_ID='&1' order by inst_id;
