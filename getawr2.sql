/*
 getawr2.sql v1.2
 Script to generate AWR report on client side using SQL*PLUS or SQLcl
 Can be used to generate report at Instance Level ou Global level (RAC)

  Syntax: @getawr2 <begin snap> <end snap> (inst_id)    <<== where inst_id=0 is RAC/GLOBAL report
 Example: @getawr2 104782 104786 0
 
 Data       | Autor              | Modificacao
 ----------- -------------------- ------------------------------------------------------------------------
 08/04/2022 | Maicon Carneiro    | Script getawr.sql created
 23/04/2022 | Maicon Carneiro    | Adapted to work un silent mode
 06/11/2024 | Maicon Carneiro    | Support for Multitenant architecture
*/

SET VERIFY OFF
SET FEEDBACK OFF

SET LINES 1000
SET PAGES 50

VARIABLE INSTID NUMBER;
BEGIN
   :INSTID := '&3';
END;
/

-- variable to define the report type and output file name in .html
column FUNCTION_NAME new_value FNAME          
column INSTANCE_NAME new_value INSTNAME FORMAT A30
column INSTANCES     new_value LISTA_INSTANCES 
column SUBQUERY_DBID new_value DBID_QUERY
column DB_NAME       new_value _DBNAME
SET TERMOUT OFF
SELECT LISTAGG(inst_id, ',') WITHIN GROUP (ORDER BY inst_id) INSTANCES,
       DECODE(:INSTID,0,'AWR_GLOBAL_REPORT_HTML','AWR_REPORT_HTML') AS FUNCTION_NAME,
       MAX(CASE WHEN VERSION < '12.1' 
            THEN 'SELECT DBID FROM V$DATABASE' 
            ELSE 'SELECT CON_DBID FROM V$DATABASE'
       END) AS SUBQUERY_DBID
FROM GV$INSTANCE;

SELECT DECODE(:INSTID,0,'GLOBAL', I.INSTANCE_NAME) AS INSTANCE_NAME,
       sys_context('USERENV','DB_NAME') AS DB_NAME
  FROM GV$INSTANCE I, V$DATABASE D
 WHERE (I.INST_ID = :INSTID OR :INSTID = 0)
   AND ROWNUM = 1;


DEF REPORT_NAME=&_DBNAME-&1-&2-&INSTNAME..html

SET TERMOUT ON
PROMP
PROMP DB Name.......: &_DBNAME
PROMP AWR Snapshots.: &1 &2
PROMP Instance Name.: &INSTNAME 
PROMP
PROMP Generating AWR report ...

SET TERMOUT OFF
SET HEADING OFF
SPOOL &REPORT_NAME


SELECT OUTPUT FROM TABLE(DBMS_WORKLOAD_REPOSITORY.&FNAME (
  l_dbid     => (&DBID_QUERY),
  l_inst_num => DECODE(:INSTID,0,'&LISTA_INSTANCES',:INSTID),
  l_bid      => &1,
  l_eid      => &2
  ));

SPOOL OFF;


SET HEADING ON
SET TERMOUT ON
SET FEEDBACK ON

PROMPT Report created: &REPORT_NAME
PROMP
