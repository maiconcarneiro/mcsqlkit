/*
 Script para gerar uma matriz com a contagem de waits de um evento de espera
 Sintaxe: SQL>@waits <dias> '<nome do evento>'
 
 Maicon Carneiro | Salvador-BA, 10/11/2022
*/

set verify off
set feedback off
SET  COLSEP  "|"
alter session set nls_date_format='dd/mm Dy';
set sqlformat
set pages 999 lines 400
col snap_date heading "Date" format a10
define COL_NUM_FORMAT='A8'
col h0  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h1  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h2  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h3  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h4  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h5  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h6  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h7  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h8  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h9  format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h10 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h11 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h12 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h13 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h14 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h15 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h16 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h17 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h18 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h19 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h20 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h21 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h22 format &&COL_NUM_FORMAT JUSTIFY RIGHT
col h23 format &&COL_NUM_FORMAT JUSTIFY RIGHT
set feedback ON


-- resumo do relatorio
PROMP
PROMP Metrica...: Waits Count
PROMP Evento....: &1
PROMP Qt. Dias..: &2 
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

with awr as (
select
  begin_snap,
  SUM(total_waits) AS total_waits
from (
select
  s.instance_number inst_id,
  s.snap_id,
  s.begin_interval_time begin_snap,
  s.end_interval_time end_snap,
  total_waits-lag(total_waits, 1, total_waits) over
   (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) total_waits,
  min(s.snap_id) over (partition by s.startup_time, s.instance_number, stats.event_name) min_snap_id
from (
 select dbid, instance_number, snap_id, event_name, wait_class, total_waits, round(time_waited_micro/1000000, 2) time_waited
  from dba_hist_system_event
  where event_name = '&1' -- filtro especifico
) stats, dba_hist_snapshot s
 where stats.instance_number=s.instance_number
  and stats.snap_id=s.snap_id
  and stats.dbid=s.dbid
  and s.dbid = (&_DBID)
  and s.begin_interval_time >= trunc(sysdate) - &2
  and (&3 = 0 or s.instance_number = &3) 
order by snap_id
) where snap_id > min_snap_id 
    and nvl(total_waits,1) > 0
GROUP BY begin_snap
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
       (case when h0  >= 1000000 then lpad(round(h0 /1000000,2) || 'M',7,'x') else to_char(h0 ,'999,999') end) as h0 ,
       (case when h1  >= 1000000 then lpad(round(h1 /1000000,2) || 'M',7,'x') else to_char(h1 ,'999,999') end) as h1 ,
       (case when h2  >= 1000000 then lpad(round(h2 /1000000,2) || 'M',7,'x') else to_char(h2 ,'999,999') end) as h2 ,
       (case when h3  >= 1000000 then lpad(round(h3 /1000000,2) || 'M',7,'x') else to_char(h3 ,'999,999') end) as h3 ,
       (case when h4  >= 1000000 then lpad(round(h4 /1000000,2) || 'M',7,'x') else to_char(h4 ,'999,999') end) as h4 ,
       (case when h5  >= 1000000 then lpad(round(h5 /1000000,2) || 'M',7,'x') else to_char(h5 ,'999,999') end) as h5 ,
       (case when h6  >= 1000000 then lpad(round(h6 /1000000,2) || 'M',7,'x') else to_char(h6 ,'999,999') end) as h6 ,
       (case when h7  >= 1000000 then lpad(round(h7 /1000000,2) || 'M',7,'x') else to_char(h7 ,'999,999') end) as h7 ,
       (case when h8  >= 1000000 then lpad(round(h8 /1000000,2) || 'M',7,'x') else to_char(h8 ,'999,999') end) as h8 ,
       (case when h9  >= 1000000 then lpad(round(h9 /1000000,2) || 'M',7,'x') else to_char(h9 ,'999,999') end) as h9 ,
       (case when h10 >= 1000000 then lpad(round(h10/1000000,2) || 'M',7,'x') else to_char(h10,'999,999') end) as h10,
       (case when h11 >= 1000000 then lpad(round(h11/1000000,2) || 'M',7,'x') else to_char(h11,'999,999') end) as h11,
       (case when h12 >= 1000000 then lpad(round(h12/1000000,2) || 'M',7,'x') else to_char(h12,'999,999') end) as h12,
       (case when h13 >= 1000000 then lpad(round(h13/1000000,2) || 'M',7,'x') else to_char(h13,'999,999') end) as h13,
       (case when h14 >= 1000000 then lpad(round(h14/1000000,2) || 'M',7,'x') else to_char(h14,'999,999') end) as h14,
       (case when h15 >= 1000000 then lpad(round(h15/1000000,2) || 'M',7,'x') else to_char(h15,'999,999') end) as h15,
       (case when h16 >= 1000000 then lpad(round(h16/1000000,2) || 'M',7,'x') else to_char(h16,'999,999') end) as h16,
       (case when h17 >= 1000000 then lpad(round(h17/1000000,2) || 'M',7,'x') else to_char(h17,'999,999') end) as h17,
       (case when h18 >= 1000000 then lpad(round(h18/1000000,2) || 'M',7,'x') else to_char(h18,'999,999') end) as h18,
       (case when h19 >= 1000000 then lpad(round(h19/1000000,2) || 'M',7,'x') else to_char(h19,'999,999') end) as h19,
       (case when h20 >= 1000000 then lpad(round(h20/1000000,2) || 'M',7,'x') else to_char(h20,'999,999') end) as h20,
       (case when h21 >= 1000000 then lpad(round(h21/1000000,2) || 'M',7,'x') else to_char(h21,'999,999') end) as h21,
       (case when h22 >= 1000000 then lpad(round(h22/1000000,2) || 'M',7,'x') else to_char(h22,'999,999') end) as h22,
       (case when h23 >= 1000000 then lpad(round(h23/1000000,2) || 'M',7,'x') else to_char(h23,'999,999') end) as h23
from matrix;