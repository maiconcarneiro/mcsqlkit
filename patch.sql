-- Author: Maicon Carneiro (dibiei.com)
SET VERIFY OFF
SET SERVEROUTPUT ON
DECLARE
 l_sql_text CLOB;
BEGIN
 -- get address, hash_value and sql text
 SELECT sql_fulltext
 INTO l_sql_text
 FROM gv$sqlarea
 WHERE sql_id = '&1'
 AND rownum=1;

 -- create sql patch
 SYS.DBMS_SQLDIAG_INTERNAL.I_CREATE_PATCH (
	 sql_text => l_sql_text,
	 hint_text => 'PARALLEL(32)',
	 name => 'Duble_Parallel_&1',
	 description => 'Parallel_&1',
	 category => 'DEFAULT',
	 validate => TRUE
 );

DBMS_OUTPUT.PUT_LINE('Patch criado: ' || 'Duble_Parallel_&1' );

END;
/
