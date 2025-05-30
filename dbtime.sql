/*
 Script para gerar uma matriz com o DB Time da instancia por dia e hora
 Sintaxe: SQL>@dbtime <Qtd. Dias> <Inst ID> (Onde Inst ID = 0 soma todas as instancias do cluster)
 Exemplo: SQL>@dbtime 30 1 
 
 Maicon Carneiro | Salvador-BA, 11/11/2022
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

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &2 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&2 = 0 or inst_id = &2);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: DB Time
PROMP Qt. Dias..: &1
PROMP Instance..: &VNODE
PROMP
PROMP Valores negativos aparecem em casos de restart da instancia
PROMP

-- query
with awr as (
select snap_id,
       begin_snap,
       --round( (value - LAG(value, 1, value) OVER (ORDER BY snap_id)) /60 ,2) AS dbtime_diff
	   round( (value - LAG(value, 1, value) OVER (PARTITION BY startup_time, instance_number ORDER BY snap_id)) /1e6/60 ,2) AS dbtime_diff
from (
    select min(s.startup_time) as startup_time,
	       s.instance_number,
		   s.snap_id, 
           min(s.begin_interval_time) as begin_snap,
           sum(m.value) as value
    from dba_hist_snapshot s
    join dba_hist_sys_time_model m on (s.snap_id = m.snap_id and s.dbid = m.dbid and s.instance_number = m.instance_number)
    where 1=1
    and m.stat_name = 'DB time'
    and s.begin_interval_time >= trunc(sysdate)-&1
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