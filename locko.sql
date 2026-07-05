set linesize 400
SET PAGES 50
COL sess FORMAT A20
COL serial# FORMAT A8
COL status FORMAT A12
COL MACHINE FORMAT A20 TRUNC
COL LOCKED_OBJECT FORMAT A30
COL USERNAME FORMAT A15
COL SQL_ADDRESS FORMAT A20
COL SQL_ID FORMAT A18
COL INST_ID FORMAT 99
COL blocker format a10
COL blocking_session heading 'Blocker|Session' format 99999
COL blocking_instance heading 'Blocker|Instance' format 99
COL blocking_session_status heading 'Blocker|Status' format a10
SELECT --DECODE(request, 0, 'Holder: ', '  Waiter: ') || l.sid || ' ' || l.inst_id sess,
       DECODE(s.final_blocking_session,NULL,'','  ') || DECODE (request, 0, 'Holder: ', ' Waiter: ') || s.sid || ' ' || s.inst_id sess,
       s.serial#,
       s.status,
       s.blocking_session || ' ' || s.blocking_instance as blocker,
       s.blocking_session_status,
       do.owner || '.' || do.object_name as locked_object,
       --gv$session.username,
       s.sql_id,
       substr(machine,1,instr(machine,'.')-1) as machine,
	  -- gv$session.sql_hash_value,
	   s.event
  FROM gv$lock l
  join gv$session s
    on l.sid = s.sid
   and l.inst_id = s.inst_id
  join gv$locked_object lo
    on l.SID = lo.SESSION_ID
   and l.inst_id = lo.inst_id
  join dba_objects do
    on lo.OBJECT_ID = do.OBJECT_ID
WHERE (id1, id2, l.type) IN
       (SELECT id1, id2, type FROM gv$lock WHERE request > 0)
ORDER BY id1, request;