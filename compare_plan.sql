VARIABLE v_rep CLOB

BEGIN
  :v_rep := DBMS_XPLAN.COMPARE_PLANS( 
    reference_plan    => awr_object('0rd8md03qz6np', null, null, 4181245179),
    compare_plan_list => plan_object_list( awr_object('0rd8md03qz6np', null, null, 1702681034) ),
    type              => 'TEXT',
    level             => 'TYPICAL', 
    section           => 'ALL');
END;
/

SET PAGESIZE 50000
SET LONG 100000
SET LINESIZE 210
COL report FORMAT a200
SELECT :v_rep REPORT FROM DUAL;