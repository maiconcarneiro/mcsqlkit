SET SERVEROUTPUT ON
DECLARE
 vLoad varchar2(200);
BEGIN
 vLoad := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (SQL_ID => '&1', PLAN_HASH_VALUE => &2);
 DBMS_OUTPUT.put_line('Number of plans loaded: ' || vLoad);
END;
/