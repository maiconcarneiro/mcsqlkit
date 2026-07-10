/*

 getawr.sql v1.0
 Script to generate AWR report on the Client side (SQL*PLUS or SQLcl)
 Can be used to generate an HTML report for the Local Instance, any instance in the Cluster, or Global

 Date       | Author             | Modification
 ----------- -------------------- ------------------------------------------------------------------------
 08/04/2022 | Maicon Carneiro    | Created the script
 
*/

SET VERIFY OFF
SET FEEDBACK OFF

set linesize 1000
SET PAGES 50

-- user input for instance and number of days to list snaps
VARIABLE INSTID NUMBER;
VARIABLE NUM_DAYS NUMBER;

PROMPT Enter 0 to generate a Global AWR (RAC) or the specific Instance number (default = local instance)
ACCEPT user_INSTID   CHAR PROMPT 'Inst ID: '
ACCEPT user_NUM_DAYS NUMBER PROMPT 'Number of Days: '


BEGIN
 IF '&user_INSTID' = '' THEN
    :INSTID := SYS_CONTEXT ('USERENV', 'INSTANCE');
   ELSE
    :INSTID := '&user_INSTID';
 END IF;
 IF &user_NUM_DAYS > 0 THEN
   :NUM_DAYS := &user_NUM_DAYS;
  ELSE
   :NUM_DAYS := 1;
 END IF;
END;
/

COL INST_ID FORMAT A10
COL SNAP_TIME FORMAT A20
-- list the snaps
SELECT DISTINCT DECODE(:INSTID,0,'GLOBAL',INSTANCE_NUMBER) INST_ID, 
       TO_CHAR(END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI')  SNAP_TIME,
 	   SNAP_ID
FROM DBA_HIST_SNAPSHOT
WHERE END_INTERVAL_TIME >= TRUNC(sysdate+1) - :NUM_DAYS
  AND END_INTERVAL_TIME <= sysdate
  AND (INSTANCE_NUMBER = :INSTID OR :INSTID = 0)
ORDER BY SNAP_ID;

ACCEPT SNAP_BEGIN NUMBER PROMPT 'SNAP Begin: '
ACCEPT SNAP_END   NUMBER PROMPT 'SNAP End: '


-- variables that define the report type and the .html file name
column FUNCTION_NAME new_value FNAME          
column INSTANCE_NAME new_value INSTNAME FORMAT A30
column HOST_NAME     new_value HOSTNAME FORMAT A40
column INSTANCES     new_value LISTA_INSTANCES 

SET TERMOUT OFF
SELECT LISTAGG(inst_id, ',') WITHIN GROUP (ORDER BY inst_id) INSTANCES,
       DECODE(:INSTID,0,'AWR_GLOBAL_REPORT_HTML','AWR_REPORT_HTML') AS FUNCTION_NAME
FROM GV$INSTANCE;
SET TERMOUT ON

SELECT DECODE(:INSTID,0, D.NAME, I.INSTANCE_NAME) AS INSTANCE_NAME,
       DECODE(:INSTID,0,'GLOBAL', substr(HOST_NAME || '.', 1, instr(HOST_NAME ||'.', '.' ) -1)  ) AS HOST_NAME
  FROM GV$INSTANCE I, V$DATABASE D
 WHERE (I.INST_ID = :INSTID OR :INSTID = 0)
   AND ROWNUM = 1;

-- start of AWR generation
SET TERMOUT OFF
SET HEADING OFF
SPOOL &INSTNAME-&HOSTNAME-&SNAP_BEGIN-&SNAP_END-.html

SELECT OUTPUT FROM TABLE(DBMS_WORKLOAD_REPOSITORY.&FNAME (
  l_dbid     => (SELECT DBID FROM V$DATABASE),
  l_inst_num => DECODE(:INSTID,0,'&LISTA_INSTANCES',:INSTID),
  l_bid      => &SNAP_BEGIN,
  l_eid      => &SNAP_END
  ));

SPOOL OFF;


SET HEADING ON
SET TERMOUT ON
SET FEEDBACK ON

PROMPT Report created: &INSTNAME-&HOSTNAME-&SNAP_BEGIN-&SNAP_END-.html
