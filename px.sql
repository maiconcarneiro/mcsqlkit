set linesize 300
set pagesize 100
col machine format a20 trunc
col program format a30 trunc
col osuser format a20
col username format a20
col sql_id format a20
SELECT P.QCSID,  
       S.MACHINE,
       S.PROGRAM,
       S.OSUSER,
       S.USERNAME,
       S.SQL_ID,
       P.INST_ID,
       P.SID,
       P.SERVER_GROUP, 
       P.SERVER_SET, 
       P.DEGREE, 
       P.REQ_DEGREE
FROM GV$PX_SESSION P
JOIN GV$SESSION S ON P.INST_ID=S.INST_ID AND P.QCSID = S.SID
ORDER BY QCSID, QCINST_ID, SERVER_GROUP, SERVER_SET;