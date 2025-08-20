/*
 Script para gerar uma matriz com a contagem de waits de um evento de espera
 Script: sp-waits.sql
 Generates a matrix with event waits per hour using STATSPACK metrics
 Syntax: SQL>@sp-waits '<event name>' <days> <instance number>
 
 Maicon Carneiro | Salvador-BA, 23/05/2025
*/

set feedback off
SET  COLSEP  "|"
alter session set nls_date_format='dd/mm Dy';
set sqlformat
set pages 999 lines 400
col snap_date heading "Date" format a10
define COL_NUM_FORMAT='a8' -- define the format used in numeric columns
col h0  format &&COL_NUM_FORMAT
col h1  format &&COL_NUM_FORMAT
col h2  format &&COL_NUM_FORMAT
col h3  format &&COL_NUM_FORMAT
col h4  format &&COL_NUM_FORMAT
col h5  format &&COL_NUM_FORMAT
col h6  format &&COL_NUM_FORMAT
col h7  format &&COL_NUM_FORMAT
col h8  format &&COL_NUM_FORMAT
col h9  format &&COL_NUM_FORMAT
col h10 format &&COL_NUM_FORMAT
col h11 format &&COL_NUM_FORMAT
col h12 format &&COL_NUM_FORMAT
col h13 format &&COL_NUM_FORMAT
col h14 format &&COL_NUM_FORMAT
col h15 format &&COL_NUM_FORMAT
col h16 format &&COL_NUM_FORMAT
col h17 format &&COL_NUM_FORMAT
col h18 format &&COL_NUM_FORMAT
col h19 format &&COL_NUM_FORMAT
col h20 format &&COL_NUM_FORMAT
col h21 format &&COL_NUM_FORMAT
col h22 format &&COL_NUM_FORMAT
col h23 format &&COL_NUM_FORMAT
set feedback ON


-- report summary
PROMP
PROMP Report....: History Event Waits per hour (STATSPACK)
PROMP Event,....: &1
PROMP Days......: D-&2 
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP


with awr as (
select
  begin_snap,
  event_name,
  wait_class,
  '|' as x,
  SUM(total_waits - total_waits_fg) AS total_waits_bg,
  round(AVG( (time_waited - time_waited_fg) /  greatest((total_waits - total_waits_fg),1) ),2) as bg_avg_time_ms,
  '|' as x,
  SUM(total_waits_fg) AS total_waits_fg,
  AVG(round((time_waited_fg / greatest(total_waits_fg,1))*1000 ,4)) AS fg_avg_time_ms,
  '|' as x,
  SUM(total_waits) AS total_waits,
  AVG(round((time_waited / total_waits)*1000 ,4)) AS avg_time_ms,
  MIN((time_waited/total_waits)*1000) AS min_wait_ms,
  MAX((time_waited/total_waits)*1000) AS max_wait_ms,
  '|' as x
from (
select
  s.instance_number inst_id,
  s.snap_id,
  LAG(s.snap_time, 1, null) OVER (PARTITION BY s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id) as begin_snap,
  s.snap_time end_snap,
  event_name,
  wait_class,
  total_waits_fg-lag(total_waits_fg, 1, total_waits_fg) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) total_waits_fg,
  total_waits-lag(total_waits, 1, total_waits) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) total_waits,
  time_waited_fg-lag(time_waited_fg, 1, time_waited_fg) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) time_waited_fg,
  time_waited-lag(time_waited, 1, time_waited) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) time_waited,
  min(s.snap_id) over (partition by s.startup_time, s.instance_number, stats.event_name) min_snap_id
from (
 select dbid, 
        instance_number, 
        snap_id, 
        e.event as event_name, 
        n.wait_class, 
        total_waits_fg, 
        total_waits,
        (time_waited_micro_fg/1000000) as time_waited_fg,
        (time_waited_micro/1000000) as time_waited
  from STATS$SYSTEM_EVENT e
  join V$EVENT_NAME n on (e.event_id = n.event_id)
  where e.event = '&1'
) stats, STATS$SNAPSHOT s
 where stats.instance_number=s.instance_number
  and stats.snap_id=s.snap_id
  and stats.dbid=s.dbid
  and s.dbid = (&_SUBQUERY_DBID)
  and s.snap_time >= trunc(sysdate) - &2
  and (&3 = 0 or s.instance_number = &3) 
order by snap_id
) where snap_id > min_snap_id 
    and nvl(total_waits,1) > 0
GROUP BY begin_snap,
         event_name,
         wait_class
),
matrix as (
SELECT TRUNC(begin_snap) snap_date,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', total_waits, null)) h0,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', total_waits, null)) h1,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', total_waits, null)) h2,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', total_waits, null)) h3,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', total_waits, null)) h4,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', total_waits, null)) h5,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', total_waits, null)) h6,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', total_waits, null)) h7,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', total_waits, null)) h8,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', total_waits, null)) h9,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', total_waits, null)) h10,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', total_waits, null)) h11,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', total_waits, null)) h12,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', total_waits, null)) h13,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', total_waits, null)) h14,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', total_waits, null)) h15,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', total_waits, null)) h16,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', total_waits, null)) h17,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', total_waits, null)) h18,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', total_waits, null)) h19,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', total_waits, null)) h20,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', total_waits, null)) h21,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', total_waits, null)) h22,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', total_waits, null)) h23
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1
)
select snap_date,
       (case when h0  >= 1000000 then '*' || round(h0 /1000000,1) || 'M*' else to_char(h0 ,'999,999') end) as h0 ,
       (case when h1  >= 1000000 then '*' || round(h1 /1000000,1) || 'M*' else to_char(h1 ,'999,999') end) as h1 ,
       (case when h2  >= 1000000 then '*' || round(h2 /1000000,1) || 'M*' else to_char(h2 ,'999,999') end) as h2 ,
       (case when h3  >= 1000000 then '*' || round(h3 /1000000,1) || 'M*' else to_char(h3 ,'999,999') end) as h3 ,
       (case when h4  >= 1000000 then '*' || round(h4 /1000000,1) || 'M*' else to_char(h4 ,'999,999') end) as h4 ,
       (case when h5  >= 1000000 then '*' || round(h5 /1000000,1) || 'M*' else to_char(h5 ,'999,999') end) as h5 ,
       (case when h6  >= 1000000 then '*' || round(h6 /1000000,1) || 'M*' else to_char(h6 ,'999,999') end) as h6 ,
       (case when h7  >= 1000000 then '*' || round(h7 /1000000,1) || 'M*' else to_char(h7 ,'999,999') end) as h7 ,
       (case when h8  >= 1000000 then '*' || round(h8 /1000000,1) || 'M*' else to_char(h8 ,'999,999') end) as h8 ,
       (case when h9  >= 1000000 then '*' || round(h9 /1000000,1) || 'M*' else to_char(h9 ,'999,999') end) as h9 ,
       (case when h10 >= 1000000 then '*' || round(h10/1000000,1) || 'M*' else to_char(h10,'999,999') end) as h10,
       (case when h11 >= 1000000 then '*' || round(h11/1000000,1) || 'M*' else to_char(h11,'999,999') end) as h11,
       (case when h12 >= 1000000 then '*' || round(h12/1000000,1) || 'M*' else to_char(h12,'999,999') end) as h12,
       (case when h13 >= 1000000 then '*' || round(h13/1000000,1) || 'M*' else to_char(h13,'999,999') end) as h13,
       (case when h14 >= 1000000 then '*' || round(h14/1000000,1) || 'M*' else to_char(h14,'999,999') end) as h14,
       (case when h15 >= 1000000 then '*' || round(h15/1000000,1) || 'M*' else to_char(h15,'999,999') end) as h15,
       (case when h16 >= 1000000 then '*' || round(h16/1000000,1) || 'M*' else to_char(h16,'999,999') end) as h16,
       (case when h17 >= 1000000 then '*' || round(h17/1000000,1) || 'M*' else to_char(h17,'999,999') end) as h17,
       (case when h18 >= 1000000 then '*' || round(h18/1000000,1) || 'M*' else to_char(h18,'999,999') end) as h18,
       (case when h19 >= 1000000 then '*' || round(h19/1000000,1) || 'M*' else to_char(h19,'999,999') end) as h19,
       (case when h20 >= 1000000 then '*' || round(h20/1000000,1) || 'M*' else to_char(h20,'999,999') end) as h20,
       (case when h21 >= 1000000 then '*' || round(h21/1000000,1) || 'M*' else to_char(h21,'999,999') end) as h21,
       (case when h22 >= 1000000 then '*' || round(h22/1000000,1) || 'M*' else to_char(h22,'999,999') end) as h22,
       (case when h23 >= 1000000 then '*' || round(h23/1000000,1) || 'M*' else to_char(h23,'999,999') end) as h23
from matrix;

SET  COLSEP  " ";