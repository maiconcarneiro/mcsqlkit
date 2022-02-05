SET verify OFF
undef SQL_ID
select SQL_ID,ADDRESS, HASH_VALUE from V$SQLAREA where SQL_ID='&&SQL_ID';
select 'exec DBMS_SHARED_POOL.PURGE ('''||address||','||hash_value||''',''C'');' limpar_memoria from V$SQLAREA where SQL_ID='&&SQL_ID';
