/*

 getawr.sql v1.0
 Script para gerar relatorio AWR do lado do Client (SQL*PLUS ou SQLcl)
 Pode ser usado para gerar report em HTML para a Intance Local, qualquer instance do Cluster ou Global
 
 Data       | Autor              | Modificacao
 ----------- -------------------- ------------------------------------------------------------------------
 08/04/2022 | Maicon Carneiro    | Cricao do script
 
*/

SET VERIFY OFF
SET FEEDBACK OFF

SET LINES 1000
SET PAGES 50

-- entrada do usuario para instance e qtde. dias para listar snaps
VARIABLE INSTID NUMBER;
VARIABLE QTDIAS NUMBER;

PROMPT Informe 0 para gerar um AWR Global (RAC) ou o Nº da Instance especifica (default = instance local)
ACCEPT user_INSTID   CHAR PROMPT 'Inst ID: '
ACCEPT user_QTDIAS NUMBER PROMPT 'Qtde. Dias: '


BEGIN
 IF '&user_INSTID' = '' THEN
    :INSTID := SYS_CONTEXT ('USERENV', 'INSTANCE');
   ELSE
    :INSTID := '&user_INSTID';
 END IF;
 IF &user_QTDIAS > 0 THEN
   :QTDIAS := &user_QTDIAS;
  ELSE
   :QTDIAS := 1;
 END IF;
END;
/

COL INST_ID FORMAT A10
COL SNAP_TIME FORMAT A20
-- lista os snaps
SELECT DISTINCT DECODE(:INSTID,0,'GLOBAL',INSTANCE_NUMBER) INST_ID, 
       TO_CHAR(END_INTERVAL_TIME,'DD/MM/YYYY HH24:MI')  SNAP_TIME,
 	   SNAP_ID
FROM DBA_HIST_SNAPSHOT
WHERE END_INTERVAL_TIME >= TRUNC(sysdate+1) - :QTDIAS
  AND END_INTERVAL_TIME <= sysdate
  AND (INSTANCE_NUMBER = :INSTID OR :INSTID = 0)
ORDER BY SNAP_ID;

ACCEPT SNAP_INICIAL NUMBER PROMPT 'SNAP Inicial: '
ACCEPT SNAP_FINAL   NUMBER PROMPT 'SNAP Final: '


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
SPOOL &INSTNAME-&HOSTNAME-&SNAP_INICIAL-&SNAP_FINAL-.html

SELECT OUTPUT FROM TABLE(DBMS_WORKLOAD_REPOSITORY.&FNAME (
  l_dbid     => (SELECT DBID FROM V$DATABASE),
  l_inst_num => DECODE(:INSTID,0,'&LISTA_INSTANCES',:INSTID),
  l_bid      => &SNAP_INICIAL,
  l_eid      => &SNAP_FINAL
  ));

SPOOL OFF;


SET HEADING ON
SET TERMOUT ON
SET FEEDBACK ON

PROMPT Relatorio gerado: &INSTNAME-&HOSTNAME-&SNAP_INICIAL-&SNAP_FINAL-.html
