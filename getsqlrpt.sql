/*
DBMS_WORKLOAD_REPOSITORY.AWR_SQL_REPORT_HTML(
   l_dbid       IN    NUMBER,
   l_inst_num   IN    NUMBER,
   l_bid        IN    NUMBER,
   l_eid        IN    NUMBER,
   l_sqlid      IN    VARCHAR2,
   l_options    IN    NUMBER DEFAULT 0)
 RETURN awrrpt_html_type_table PIPELINED;
 */


SET VERIFY OFF
SET FEEDBACK OFF
SET TERMOUT OFF
SET HEADING OFF
set linesize 8000;

SPOOL sql_report.html

SELECT OUTPUT 
  FROM TABLE(DBMS_WORKLOAD_REPOSITORY.AWR_SQL_REPORT_HTML (
    l_dbid     => (SELECT DBID FROM V$DATABASE),
    l_con_dbid => (SELECT CON_DBID FROM V$DATABASE),
    l_inst_num => '1',
    l_bid      => &1,
    l_eid      => &2,
    l_sqlid    => '&3'
   )
  );

SPOOL OFF;

SET HEADING ON
SET TERMOUT ON
SET FEEDBACK ON