set feedback off;


VAR sql_text CLOB;
EXEC :sql_text := NULL;

var vSQLID varchar2(13);
exec :vSQLID := '&1';

BEGIN
  IF (:sql_text IS NULL OR NVL(DBMS_LOB.GETLENGTH(:sql_text), 0) = 0) THEN
    DBMS_OUTPUT.PUT_LINE('getting sql_text from awr');
    SELECT REPLACE(sql_text, CHR(00), ' ')
      INTO :sql_text
      FROM dba_hist_sqltext
     WHERE 1=1
       AND dbid = (&_SUBQUERY_DBID)
       AND sql_id = :vSQLID
       AND sql_text IS NOT NULL
       AND ROWNUM = 1;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('getting sql_text from awr: '||SQLERRM);
    :sql_text := NULL;
END;
/



-- 1. Set formatting to avoid truncation
SET LONG 1000000         -- Allows long CLOBs
SET LONGCHUNKSIZE 1000000
SET LINESIZE 32767       -- Max linesize
SET PAGESIZE 0           -- No page breaks or headings
SET TRIMSPOOL ON         -- Remove trailing spaces
SET TRIMOUT ON

spool &1..sql
SELECT :sql_text as sql_text FROM DUAL;
spool off;