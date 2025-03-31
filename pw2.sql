

/*
 Script to query metrics from AWR for an specific SQL ID 
 Syntax...: @pw2 <SQL_ID> <PLAN_HASH_VALUE>
 Example..: @pw a6gfw65g1ggum 837656283
   
 Author: Maicon Carneiro | dibiei.blog

 Reference:
  https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_XPLAN.html#GUID-D416125C-FED5-4704-A371-B5EECFCE1429
*/

set pages 4000
select * 
from table (DBMS_XPLAN.DISPLAY_WORKLOAD_REPOSITORY
  (sql_id           => '&1'
   ,plan_hash_value => '&2'
   ,dbid            => (select dbid from v$database)
   ,con_dbid        => (select dbid from v$containers)
   ,format          => 'ALL ALLSTATS LAST +OUTLINE +NOTE +PEEKED_BINDS +PROJECTION +ALIAS +COST +BYTES +PARALLEL +PARTITION +REMOTE +ADAPTIVE'
   ,awr_location    => (CASE WHEN SYS_CONTEXT('USERENV','CON_ID') <=1 THEN 'AWR_ROOT' ELSE 'AWR_PDB' END) /* AWR_ROOT or AWR_PDB */
  )
 );
