SET SERVEROUTPUT ON;
DECLARE
  vSQL varchar2(4000);
  CURSOR sessions
  IS
    SELECT inst_id, sid, serial#
    FROM gv$session
    WHERE sql_id='&1'
    AND type   <> 'BACKGROUND';
BEGIN
  FOR c1 IN sessions
  LOOP
    vSQL := 'alter system kill session'''||c1.sid||','||c1.serial# ||',@' || c1.inst_id || ''' immediate';
	dbms_output.put_line(vSQL);
	BEGIN
	  EXECUTE IMMEDIATE vSQL;
	 EXCEPTION WHEN OTHERS THEN 
	  NULL;
	END;
  END LOOP;
END;
/