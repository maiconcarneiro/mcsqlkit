/*
 Script para gerar uma matriz com estatisticas do SO capturadas pelo AWR por dia e hora
 Sintaxe: SQL>@osstat_helper <STAT_NAME> <Qtd. Dias> <Inst ID> <Aggregation type>
 Exemplo: SQL>@osstat_helper SYS_TIME 30 1 avg
 
 Maicon Carneiro | Salvador-BA, 01/11/2024
*/

set verify off
set feedback off
alter session set nls_date_format='dd/mm Dy';
set sqlformat 
set pages 999 lines 400
col snap_date heading "Date" format a10
define COL_NUM_FORMAT='99,999' -- define the format used in numeric columns
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

-- query
with awr as (
select snap_id,
       begin_snap,
       value,
	   --round( (value - LAG(value, 1, value) OVER (PARTITION BY startup_time, instance_number ORDER BY snap_id)) ,2) AS value_diff,
       (case when stat_name like '%TIME%' 
              then (value - LAG(value, 1, value) OVER (PARTITION BY startup_time, instance_number ORDER BY snap_id))
             when stat_name like '%BYTES%' 
              then value/1024/1024
             else value 
        end) dbtime_diff
from (
    select m.stat_name,
           min(s.startup_time) as startup_time,
	       s.instance_number,
		   s.snap_id, 
           min(s.begin_interval_time) as begin_snap,
           sum(m.value) as value
    from dba_hist_snapshot s
    join dba_hist_osstat m on (s.snap_id = m.snap_id and s.dbid = m.dbid and s.instance_number = m.instance_number)
    where 1=1
    and m.stat_name = upper('&1')
    and s.begin_interval_time >= trunc(sysdate)-&2
	and (&3 = 0 or s.instance_number = &3)
    group by stat_name, s.snap_id, s.instance_number
 )
)
SELECT TRUNC(begin_snap) snap_date,
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', dbtime_diff, 0)) "h0",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', dbtime_diff, 0)) "h1",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', dbtime_diff, 0)) "h2",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', dbtime_diff, 0)) "h3",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', dbtime_diff, 0)) "h4",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', dbtime_diff, 0)) "h5",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', dbtime_diff, 0)) "h6",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', dbtime_diff, 0)) "h7",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', dbtime_diff, 0)) "h8",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', dbtime_diff, 0)) "h9",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', dbtime_diff, 0)) "h10",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', dbtime_diff, 0)) "h11",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', dbtime_diff, 0)) "h12",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', dbtime_diff, 0)) "h13",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', dbtime_diff, 0)) "h14",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', dbtime_diff, 0)) "h15",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', dbtime_diff, 0)) "h16",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', dbtime_diff, 0)) "h17",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', dbtime_diff, 0)) "h18",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', dbtime_diff, 0)) "h19",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', dbtime_diff, 0)) "h20",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', dbtime_diff, 0)) "h21",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', dbtime_diff, 0)) "h22",
 &4 (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', dbtime_diff, 0)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;