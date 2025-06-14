

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



/*
Controls the level of details for the plan. It accepts four values:

BASIC: Displays the minimum information in the plan—the operation ID, the operation name and its option.

TYPICAL: This is the default. Displays the most relevant information in the plan (operation id, name and option, #rows, #bytes and optimizer cost). 
         Pruning, parallel and predicate information are only displayed when applicable. Excludes only PROJECTION, ALIAS and REMOTE SQL information (see below).

SERIAL: Like TYPICAL except that the parallel information is not displayed, even if the plan executes in parallel.
ALL: Maximum user level. Includes information displayed with the TYPICAL level with additional information (PROJECTION, ALIAS 
    and information about REMOTE SQL if the operation is distributed).

For finer control on the display output, the following keywords can be added to the above four standard format options to customize their default behavior. 
Each keyword either represents a logical group of plan table columns (such as PARTITION) or logical additions to the base plan table output (such as PREDICATE). 
Format keywords must be separated by either a comma or a space:

ROWS - if relevant, shows the number of rows estimated by the optimizer
BYTES - if relevant, shows the number of bytes estimated by the optimizer
COST - if relevant, shows optimizer cost information
PARTITION - if relevant, shows partition pruning information
PARALLEL - if relevant, shows PX information (distribution method and table queue information)
PREDICATE - if relevant, shows the predicate section
PROJECTION -if relevant, shows the projection section
ALIAS - if relevant, shows the "Query Block Name / Object Alias" section
REMOTE - if relevant, shows the information for distributed query (for example, remote from serial distribution and remote SQL)
NOTE - if relevant, shows the note section of the explain plan
Format keywords can be prefixed by the sign '-' to exclude the specified information. For example, '-PROJECTION' excludes projection information.
*/