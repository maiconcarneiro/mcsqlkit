set sqlformat 
set feedback off;
set lines 400
set pages 100
col inst_id format 99
col xidusn format 999999999
col xidslot format 99999
col xidsqn format 999999999
col sid format 99999
col serial# format 99999
col osuser format a20 trunc
col username format a20
col program format a25 trunc
col machine format a50 trunc
col used_ublk format 999,999,999,999
col start_date format a25
col Current_Time format a25
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
select sysdate from dual;
select vs.inst_id, 
       vs.sid,
	   vs.serial#,
       vs.username, 
       vs.program, 
       vs.machine, 
	   vs.osuser, 
       vt.xidusn, 
       vt.xidslot, 
       vt.xidsqn, 
       vt.used_ublk,
       vt.start_date
 from gv$transaction vt, 
      gv$session vs 
where vt.addr = vs.taddr 
order by vt.start_date ;