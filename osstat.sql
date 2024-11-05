/*
 Script para gerar uma matriz com estatisticas do SO capturadas pelo AWR por dia e hora
 Sintaxe: SQL>@osstat <STAT_NAME> <Qtd. Dias> <Inst ID> (Onde Inst ID = 0 soma todas as instancias do cluster)
 Exemplo: SQL>@osstat SYS_TIME 30 1 
 
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
PROMP Metrica...: Estatisticas de OS capturadas no AWR (&1)
PROMP Qt. Dias..: &2
PROMP Instance..: &VNODE
PROMP Type......: &vOP 
PROMP 
PROMP

-- run the script
@osstat_helper &vSNAME &2 &3 &vOP 