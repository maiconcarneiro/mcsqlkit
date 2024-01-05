SET LINES 400
SET PAGES 50
COL sess FORMAT A20
COL serial# FORMAT A20
COL status FORMAT A12
COL MACHINE FORMAT A20 TRUNC
COL LOCKED_OBJECT FORMAT A30
COL USERNAME FORMAT A15
COL SQL_ADDRESS FORMAT A20
COL SQL_ID FORMAT A18
SELECT 
       DECODE(request, 0, 'Holder: ', 'Waiter: ') || gv$lock.sid sess,
       gv$session.serial#,
       gv$session.status,
       gv$lock.INST_ID,
       gv$session.sql_id,
       --gv$session.username,
       substr(machine,1,instr(machine,'.')-1) as machine,
       gv$session.BLOCKING_SESSION,
       gv$session.inst_id,
	   gv$session.sql_hash_value,
	   gv$session.event
  FROM gv$lock
  join gv$session
    on gv$lock.sid = gv$session.sid
   and gv$lock.inst_id = gv$session.inst_id
  join gv$locked_object lo
    on gv$lock.SID = lo.SESSION_ID
   and gv$lock.inst_id = lo.inst_id
  join dba_objects do
    on lo.OBJECT_ID = do.OBJECT_ID
WHERE (id1, id2, gv$lock.type) IN
       (SELECT id1, id2, type FROM gv$lock WHERE request > 0)
      and request = 0
ORDER BY id1, request;