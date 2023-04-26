-- Author: Maicon Carneiro (dibiei.com)

SET SQLFORMAT

PROMP Situacao da tablespace temp

SET LINES 400
COL TABLESPACE_NAME FORMAT A30
COL SIZE_GB FORMAT 999,999,999.99
COL ALLOCATED_GB FORMAT 999,999,999.99
COL FREE_GB FORMAT 999,999,999.99
SELECT TABLESPACE_NAME, 
       TABLESPACE_SIZE/1024/1024/1024 SIZE_GB, 
	   ALLOCATED_SPACE/1024/1024/1024 ALLOCATED_GB, 
	   FREE_SPACE/1024/1024/1024 FREE_GB
FROM DBA_TEMP_FREE_SPACE;


PROMP TOP SQL ID usando TEMP atualmente

SET LINES 400
SET PAGES 100
COL DATA FORMAT A20
COL USERNAME FORMAT A30
COL INST_ID FORMAT 99
COL SQL_ID FORMAT a15
COL temp_size HEADING "Temp Size (MB)" FORMAT 999,999,999,999
SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') AS DATA,
NVL(a.username, '(oracle)') AS username,
a.inst_id,
a.sql_id,
ROUND( sum((b.blocks*p.value)/1024/1024),2) AS temp_size
FROM gv$session a, gv$sort_usage b, gv$parameter p
WHERE p.name = 'db_block_size' 
AND a.saddr = b.session_addr
AND a.inst_id=b.inst_id 
AND a.inst_id=p.inst_id
group by NVL(a.username, '(oracle)'), a.inst_id, a.sql_id, TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')
ORDER BY temp_size desc;