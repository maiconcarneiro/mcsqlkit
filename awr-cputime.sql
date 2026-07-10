/*
 Script to generate a matrix with the instance's DB Time by day and hour
 Syntax: SQL>@dbtime <Qty. Days> <Inst ID> (Where Inst ID = 0 sums all instances in the cluster)
 Example: SQL>@dbtime 30 1
 
 Maicon Carneiro | Salvador-BA, 11/11/2022
*/

set verify off
set feedback off
alter session set nls_date_format='Mon/dd Dy';
set pages 999 lines 400
col snap_date heading "Date" format a10
col h0  format 999,999
col h1  format 999,999
col h2  format 999,999
col h3  format 999,999
col h4  format 999,999
col h5  format 999,999
col h6  format 999,999
col h7  format 999,999
col h8  format 999,999
col h9  format 999,999
col h10 format 999,999
col h11 format 999,999
col h12 format 999,999
col h13 format 999,999
col h14 format 999,999
col h15 format 999,999
col h16 format 999,999
col h17 format 999,999
col h18 format 999,999
col h19 format 999,999
col h20 format 999,999
col h21 format 999,999
col h22 format 999,999
col h23 format 999,999
set feedback ON

-- get instance names
column NODE new_value VNODE 
column CNAME new_value VCNAME 
SET termout off
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE FROM GV$INSTANCE WHERE (&2 = 0 or inst_id = &2);
SELECT sys_context('USERENV','CON_NAME') as CNAME FROM dual;
SET termout ON

-- report summary
PROMP
PROMP Metric....: DB CPU time
PROMP Qt. Days..: &1
PROMP Instance..: &VNODE
PROMP
PROMP Negative values can be displayed in case instance restart between 2 snapshots

-- query
with awr as (
select snap_id,
       begin_snap,
	   round( (value - LAG(value, 1, value) OVER (PARTITION BY startup_time, instance_number ORDER BY snap_id)) /60 ,2) AS dbtime_diff
from (
    select min(s.startup_time) as startup_time,
	       s.instance_number,
	       s.snap_id, 
           min(s.begin_interval_time) as begin_snap,
           sum(m.value)/1000/1000 as value
    from dba_hist_snapshot s
    join dba_hist_sys_time_model m on (s.snap_id = m.snap_id and s.dbid = m.dbid and s.instance_number = m.instance_number)
    where 1=1
    and s.begin_interval_time >= trunc(sysdate)-&1
    and m.stat_name = 'DB CPU'
	and (&2 = 0 or s.instance_number = &2)
    group by s.snap_id, s.instance_number
 )
)
SELECT TRUNC(begin_snap) snap_date,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', dbtime_diff, 0)) "h0",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', dbtime_diff, 0)) "h1",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', dbtime_diff, 0)) "h2",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', dbtime_diff, 0)) "h3",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', dbtime_diff, 0)) "h4",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', dbtime_diff, 0)) "h5",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', dbtime_diff, 0)) "h6",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', dbtime_diff, 0)) "h7",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', dbtime_diff, 0)) "h8",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', dbtime_diff, 0)) "h9",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', dbtime_diff, 0)) "h10",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', dbtime_diff, 0)) "h11",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', dbtime_diff, 0)) "h12",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', dbtime_diff, 0)) "h13",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', dbtime_diff, 0)) "h14",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', dbtime_diff, 0)) "h15",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', dbtime_diff, 0)) "h16",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', dbtime_diff, 0)) "h17",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', dbtime_diff, 0)) "h18",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', dbtime_diff, 0)) "h19",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', dbtime_diff, 0)) "h20",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', dbtime_diff, 0)) "h21",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', dbtime_diff, 0)) "h22",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', dbtime_diff, 0)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;