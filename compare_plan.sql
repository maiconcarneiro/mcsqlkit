VARIABLE v_rep CLOB
DECLARE
 vDBID number;
 vCON_DBID number;
BEGIN
  select dbid, con_dbid into vDBID, vCON_DBID from v$database;
  
  :v_rep := DBMS_XPLAN.COMPARE_PLANS
  ( 
    reference_plan    => awr_object('&1', vDBID, vCON_DBID, &2),
    compare_plan_list => plan_object_list(awr_object('&1', vDBID, vCON_DBID, &3) ),
    type              => 'TEXT', -- TEXT | HTML | XML
    level             => 'TYPICAL',  -- BASIC | TYPICAL | ALL
    section           => 'ALL'      -- ALL | SUMMARY | FINDINGS | PLANS | INFORMATION | ERRORS
    );
END;
/

SET PAGESIZE 50000
SET LONG 100000
SET LINESIZE 210
COL report FORMAT a200
SELECT :v_rep REPORT FROM DUAL;




