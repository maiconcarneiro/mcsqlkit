set lines 400
set pages 50
col inst_id format 999
col sid format 99999
col block_gets format 999,999,999,999,999
col consistent_gets format 999,999,999,999,999
col physical_reads format 999,999,999,999,999
col block_changes format 999,999,999,999,999
col consistent_changes format 999,999,999,999,999
select * 
 from GV$SESS_IO
where 1=1
  and inst_id = &1
  and sid = &2
