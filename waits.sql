/*
 Script para gerar uma matriz com a contagem de waits de um evento de espera
 Sintaxe: SQL>@waits <dias> '<nome do evento>'
 
 Maicon Carneiro | Salvador-BA, 10/11/2022
*/

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
column CNAME new_value VCNAME 
SET termout off
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SELECT sys_context('USERENV','CON_NAME') as CNAME FROM dual;
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: Waits Count
PROMP Evento....: &1
PROMP Qt. Dias..: &2 
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

PROMP Valores sao exibidos em multiplos de 1.000 (Ex: 10 = 10.000 / 100 = 100.000 / 1.000 = 1.000.000)
PROMP

with awr as (
select
  begin_snap,
  SUM(total_waits)/1000 AS total_waits
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
  --and s.dbid=(select dbid from v$database) /* removido para CDB */
  and s.begin_interval_time >= trunc(sysdate) - &2
  and (&3 = 0 or s.instance_number = &3) 
order by snap_id
) where snap_id > min_snap_id 
    and nvl(total_waits,1) > 0
GROUP BY begin_snap
)
SELECT TRUNC(begin_snap) snap_date,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', total_waits, null)) "h0",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', total_waits, null)) "h1",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', total_waits, null)) "h2",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', total_waits, null)) "h3",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', total_waits, null)) "h4",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', total_waits, null)) "h5",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', total_waits, null)) "h6",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', total_waits, null)) "h7",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', total_waits, null)) "h8",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', total_waits, null)) "h9",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', total_waits, null)) "h10",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', total_waits, null)) "h11",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', total_waits, null)) "h12",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', total_waits, null)) "h13",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', total_waits, null)) "h14",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', total_waits, null)) "h15",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', total_waits, null)) "h16",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', total_waits, null)) "h17",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', total_waits, null)) "h18",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', total_waits, null)) "h19",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', total_waits, null)) "h20",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', total_waits, null)) "h21",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', total_waits, null)) "h22",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', total_waits, null)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;