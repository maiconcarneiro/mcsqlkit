SET HEAD OFF;
SET LIN 1000
SET PAGESIZE 10000
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(SQL_ID=>'&1', CURSOR_CHILD_NO=>&2, FORMAT=>'allstats last  +cost -outline -predicate -projection -alias'));

SET HEAD ON;