/*
 Script: asmstats.sql
 Usage: @asmstats.sql

 Maicon Carneiro - 20/10/2024
*/


SET linesize 300
SET pages 50
COL diskgroup    HEADING "Diskgroup Name"   FORMAT a10
COL ID           HEADING "ID"               FORMAT 99
COL disk         HEADING "Disk Name"        FORMAT a40 trunc
COL path         HEADING "Path"             FORMAT a40 trunc
COL reads        HEADING "(Reads)"          FORMAT 999,999,999,999.99
COL writes       HEADING "(Writes)"         FORMAT 999,999,999,999.99
COL read_avg_ms  HEADING "(Read avg ms)"    FORMAT 999,999.99
COL write_avg_ms HEADING "(Write avg ms)"   FORMAT 999,999.99
COL avg_time_ms  HEADING "(Avg Time ms)"    FORMAT 999,999.99
COL mb_per_sec_r HEADING "(MBPS Read)"      FORMAT 999,999,999.99
COL mb_per_sec_w HEADING "(MBPS Write)"     FORMAT 999,999,999.99
COL mb_per_sec   HEADING "(MBPS Total)"     FORMAT 999,999,999,999.99
PROMP
PROMP ASM Stats by Diskgroup:
PROMP
select t2.diskgroup,
	   t2.reads,
       round(t2.read_time/t2.reads*1000,3) AS read_avg_ms,
       t2.writes,
	   round(t2.write_time/t2.writes*1000,3) AS write_avg_ms,
       round((t2.read_time+t2.write_time)/(t2.reads+t2.writes)*1000,3) AS avg_time_ms,
	   round((t2.bytes_read)/1024/1024/(t2.read_time))  AS mb_per_sec_r,   
	   round((t2.bytes_written)/1024/1024/(t2.write_time))  AS mb_per_sec_w,
	   round((t2.bytes_read+t2.bytes_written)/1024/1024/(t2.read_time+t2.write_time))  AS mb_per_sec
 from (
	select g.name as diskgroup,
	       sum(d.write_time) write_time,
		   sum(d.read_time) read_time,
		   sum(d.bytes_read) bytes_read,
		   sum(d.bytes_written) bytes_written,
		   sum(d.writes) writes,
		   sum(d.reads) reads
	  from V$asm_disk d, v$asm_diskgroup g
	 where d.group_number=g.group_number
  group by g.name
) t2;

PROMP
PROMP ASM Stats by Disk:
PROMP
select t3.name as diskgroup,
       t2.disk_number as id,
	   --t2.name as disk,
	   t2.path,
	   t2.reads,
       round(t2.read_time/t2.reads*1000,3) AS read_avg_ms,
       t2.writes,
	   round(t2.write_time/t2.writes*1000,3) AS write_avg_ms,
       round((t2.read_time+t2.write_time)/(t2.reads+t2.writes)*1000,3) AS avg_time_ms,
	   round((t2.bytes_read)/1024/1024/(t2.read_time))  AS mb_per_sec_r,   
	   round((t2.bytes_written)/1024/1024/(t2.write_time))  AS mb_per_sec_w,
	   round((t2.bytes_read+t2.bytes_written)/1024/1024/(t2.read_time+t2.write_time))  AS mb_per_sec
 from V$asm_disk t2, v$asm_diskgroup t3
where t3.group_number=t2.group_number
order by t2.group_number, 
         t2.disk_number;
