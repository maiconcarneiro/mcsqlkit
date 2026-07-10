/*
 Script to generate a matrix with OS statistics captured by AWR per day and hour
 Syntax: SQL>@osstat <STAT_NAME> <Number of Days> <Inst ID> (Where Inst ID = 0 sums all cluster instances)
 Example: SQL>@osstat SYS_TIME 30 1
 
 Maicon Carneiro | Salvador-BA, 01/11/2024
*/

ACCEPT vOP CHAR PROMPT 'Aggregation type (avg|sum|max|min) [avg]: ' DEFAULT 'avg'

-- get the report info
column NODE new_value VNODE 
column OPERATION new_value vOPERATION 
column SNAME new_value vSNAME
SET termout off
SELECT CASE WHEN &2 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE,
       --CASE WHEN upper('&1') LIKE '%TIME%' THEN 'sum' ELSE 'avg' END AS OPERATION, 
       upper('&1') as SNAME
  FROM GV$INSTANCE 
 WHERE (&3 = 0 or inst_id = &3);

SET termout ON


-- report summary
PROMP
PROMP Metric....: OS statistics captured in AWR (&1)
PROMP Num. Days.: &2
PROMP Instance..: &VNODE
PROMP Type......: &vOP 
PROMP 
PROMP

-- run the script
@osstat_helper &vSNAME &2 &3 &vOP 