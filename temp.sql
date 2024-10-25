/*
Maicon Carneiro
*/

SET SQLFORMAT

PROMP Situacao da tablespace temp
PROMP ======================================================================================

SET LINES 400
COL TABLESPACE FORMAT A15
COL SIZE_GB FORMAT 999,999,999.99
COL ALLOCATED_GB FORMAT 999,999,999.99
COL FREE_GB FORMAT 999,999,999.99
SELECT TABLESPACE_NAME AS TABLESPACE, 
       TABLESPACE_SIZE/1024/1024/1024 SIZE_GB, 
	   ALLOCATED_SPACE/1024/1024/1024 ALLOCATED_GB, 
	   FREE_SPACE/1024/1024/1024 FREE_GB
FROM DBA_TEMP_FREE_SPACE;


PROMP TOP SQL ID usando TEMP atualmente
PROMP ======================================================================================

SET LINES 400
SET PAGES 100
COL DATA FORMAT A20
COL USERNAME FORMAT A30
COL INST_ID FORMAT 99
COL SQL_ID FORMAT a15
COL temp_size HEADING "Temp Size (MB)" FORMAT 999,999,999,999
SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') AS DATA,
NVL(a.username, '(oracle)') AS username,
a.sql_id,
ROUND( sum((b.blocks*p.value)/1024/1024),2) AS temp_size
FROM gv$session a, gv$sort_usage b, gv$parameter p
WHERE p.name = 'db_block_size' 
AND a.saddr = b.session_addr
AND a.inst_id=b.inst_id 
AND a.inst_id=p.inst_id
group by NVL(a.username, '(oracle)'), a.sql_id, TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')
ORDER BY temp_size desc;


/*
 ??
*/

PROMP Consumo de TEMP por Sessao (GV$SESSION)
PROMP ======================================================================================
SET LINES 9999
SET PAGES 100
COL DATA FORMAT A20
COL USERNAME FORMAT A15
COL INST_ID FORMAT 99
COL SQL_ID FORMAT a15
COL osuser FORMAT A25
COL EVENT FORMAT a30 trunc
COL temp_size HEADING "Temp Size (MB)" FORMAT 999,999,999

break on report on tablespace
compute avg sum label "Total : " of temp_size on report


SELECT 
b.tablespace,
TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') AS DATA,
NVL(a.username, '(oracle)') AS username,
a.osuser,
a.sid,
a.serial#,
a.inst_id,
a.sql_id,
a.status,
a.event,
ROUND( sum((b.blocks*p.value)/1024/1024),2) AS temp_size
FROM gv$session a, gv$sort_usage b, gv$parameter p
WHERE p.name = 'db_block_size' 
AND a.saddr = b.session_addr
AND a.inst_id=b.inst_id 
AND a.inst_id=p.inst_id
group by NVL(a.username, '(oracle)'), 
         SID, a.osuser,
		 b.tablespace, 
		 a.sid,
		 a.inst_id, 
		 a.sql_id,
		 a.serial#, 
		 a.status, 
		 a.event,  
		 TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')
ORDER BY temp_size desc;