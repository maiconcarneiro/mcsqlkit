/*
 getawr2.sql v1.0
 Script para gerar relatorio AWR do lado do Client (SQL*PLUS ou SQLcl) em modo silent
 Pode ser usado para gerar report em HTML para a Intance Local, qualquer instance do Cluster ou Global
 Exemplo: @getawr2 104782 104786 0
 
 Data       | Autor              | Modificacao
 ----------- -------------------- ------------------------------------------------------------------------
 08/04/2022 | Maicon Carneiro    | Cricao do script
 23/04/2022 | Maicon Carneiro    | Adaptacao do script para executar em modo SILENT quando ja se tem os snaps
*/

SET VERIFY OFF
SET FEEDBACK OFF

SET LINES 1000
SET PAGES 50

-- entrada do usuario para instance e qtde. dias para listar snaps
VARIABLE INSTID NUMBER;

BEGIN
   :INSTID := '&3';
END;
/

-- variaveis que definem o tipo de relatorio e a definicao do nome do arquivo .html
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

-- inicio da geracao do AWR
SET TERMOUT OFF
SET HEADING OFF
SPOOL &INSTNAME-&HOSTNAME-&1-&2-.html

SELECT OUTPUT FROM TABLE(DBMS_WORKLOAD_REPOSITORY.&FNAME (
  l_dbid     => (SELECT DBID FROM V$DATABASE),
  l_inst_num => DECODE(:INSTID,0,'&LISTA_INSTANCES',:INSTID),
  l_bid      => &1,
  l_eid      => &2
  ));

SPOOL OFF;


SET HEADING ON
SET TERMOUT ON
SET FEEDBACK ON

PROMPT Relatorio gerado: &INSTNAME-&HOSTNAME-&1-&2-.html
