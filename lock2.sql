set linesize 400
col sess format a20
COL serial# FORMAT A15
COL status FORMAT A12
COL MACHINE FORMAT A20 TRUNC
COL LOCKED_OBJECT FORMAT A30
COL USERNAME FORMAT A15
COL SQL_ID FORMAT A13
COL INST_ID FORMAT 99
COL EVENT FORMAT A40
COL SPID FORMAT A10

SELECT /*+ RULE */
DECODE (request, 0, 'Holder: ', ' Waiter: ') || k.sid sess,
ss.username,
k.inst_id,
ss.sql_id,
k.id1,
k.id2,
k.lmode,
k.request,
k.TYPE,
SS.LAST_CALL_ET,SS.SECONDS_IN_WAIT,
--SS.SERIAL#,
--SS.MACHINE,
SS.EVENT,
ss.status,
P.SPID,
CASE
WHEN request > 0
THEN
CHR (BITAND (p1, -16777216) / 16777215)
|| CHR (BITAND (p1, 16711680) / 65535)
ELSE
NULL
END
NOME,
CASE WHEN request > 0 THEN (BITAND (p1, 65535)) ELSE NULL END MODO
FROM GV$LOCK k, gv$session ss, gv$process p
WHERE (k.id1, k.id2, k.TYPE) IN (SELECT ll.id1, ll.id2, ll.TYPE FROM GV$LOCK ll WHERE request > 0)
AND k.sid = ss.sid
AND K.INST_ID = SS.INST_ID
AND ss.paddr = p.addr
AND SS.INST_ID = P.INST_ID
ORDER BY id1, request;