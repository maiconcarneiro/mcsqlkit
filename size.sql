-- Author: Maicon Carneiro (dibiei.com)
SET LINES 400
SET PAGES 100
COL OWNER FORMAT A30
COL SEGMENT_TYPE FORMAT A20
COL SEGMENT_NAME FORMAT A40
COL MBYTES FORMAT 999,999,999,999.99
SELECT OWNER, SEGMENT_TYPE, SEGMENT_NAME, BYTES/1024/1024 MBYTES
FROM DBA_SEGMENTS
WHERE SEGMENT_NAME = UPPER('&1');