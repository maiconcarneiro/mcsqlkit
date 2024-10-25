/*
 Script para consultar lock por objeto
*/

set linesize 400
set pagesize 300
col lock_time_in_minutes format 99,999,999,999.99
col audsid format 99999
col inst_id format 99
col sid format 999999
col serial format 9999
col oracle_user format a20
col os_user format a20
col program format a30 trunc
col module format a30 trunc
col action format a20 trunc
col process format 9999999
col lock_type format a15
col object_owner format a20
col object_name format a30
col object_type format a20

select round( locks.ctime/60, 2 ) lock_time_in_minutes,
--vs.audsid audsid,
locks.inst_id,
locks.sid sid,
--to_char(vs.serial#) serial,
vs.username oracle_user,
vs.osuser os_user,
--vs.program program,
--vs.module module,
--vs.action action,
--vs.process process,
decode(locks.lmode,
       1, NULL,
       2, 'Row Share',
       3, 'Row Exclusive',
       4, 'Share',
       5, 'Share Row Exclusive',
       6, 'Exclusive', 'None') lock_mode_held,
 decode(locks.request,
       1, NULL,
       2, 'Row Share',
       3, 'Row Exclusive',
       4, 'Share',
       5, 'Share Row Exclusive',
       6, 'Exclusive', 'None') lock_mode_requested,
 decode(locks.type,
       'MR', 'Media Recovery',
       'RT', 'Redo Thread',
       'UN', 'User Name',
       'TX', 'Transaction',
       'TM', 'DML',
       'UL', 'PL/SQL User Lock',
       'DX', 'Distributed Xaction',
       'CF', 'Control File',
       'IS', 'Instance State',
       'FS', 'File Set',
       'IR', 'Instance Recovery',
       'ST', 'Disk Space Transaction',
       'TS', 'Temp Segment',
       'IV', 'Library Cache Invalidation',
       'LS', 'Log Start or Log Switch',
       'RW', 'Row Wait',
       'SQ', 'Sequence Number',
       'TE', 'Extend Table',
       'TT', 'Temp Table',
       locks.type) lock_type,
 objs.owner object_owner,
 objs.object_name object_name,
 objs.object_type object_type
from gv$session vs,
     gv$lock locks,
     all_objects objs,
     all_tables tbls
where locks.id1 = objs.object_id
 and vs.sid = locks.sid
 and vs.inst_id = locks.inst_id
 and objs.owner = tbls.owner
 and objs.object_name =  tbls.table_name
 and &1
 order by lock_time_in_minutes desc;
