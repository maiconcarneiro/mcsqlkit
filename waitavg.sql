/*
 Script para gerar uma matriz com a contagem de waits de um evento de espera
 Sintaxe: SQL>@waitavg '<event name>' <days>  <instance number>
 
 Maicon Carneiro | Salvador-BA, 10/11/2022
*/

set verify off
set feedback off
alter session set nls_date_format='dd/mm Dy';
set sqlformat
set pages 999 lines 400
col snap_date heading "Date" format a10
define COL_NUM_FORMAT='999.99' -- define the format used in numeric columns
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
PROMP Metrica...: Wait AVG Time (ms)
PROMP Evento....: &1
PROMP Qt. Dias..: &2 
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

--PROMP Valoes sao exibidos em multiplos de 1.000 (Ex: 10 = 10.000 / 100 = 100.000 / 1.000 = 1.000.000)
PROMP

with awr as (
select
  trunc(begin_snap) as begin_snap,
  to_char(begin_snap, 'hh24') as hora,
  ( sum(time_waited) / sum(total_waits) )/1000 AS avg_time_ms
from (
   select
     s.snap_id,
     s.begin_interval_time as begin_snap,
     s.end_interval_time as end_snap,
     total_waits-lag(total_waits, 1, total_waits) over
      (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) total_waits,
     time_waited-lag(time_waited, 1, time_waited) over
      (partition by s.startup_time, s.instance_number, stats.event_name order by s.snap_id) time_waited,
     min(s.snap_id) over (partition by s.startup_time, s.instance_number, stats.event_name) min_snap_id
   from (
      select dbid, instance_number, snap_id, event_name, wait_class, total_waits, time_waited_micro as time_waited
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
  ) 
   where snap_id > min_snap_id 
     and nvl(total_waits,1) > 0
GROUP BY 
     trunc(begin_snap),
     to_char(begin_snap, 'hh24')
)
SELECT TRUNC(begin_snap) snap_date,
 max (DECODE (hora, '00', avg_time_ms, 0)) "h0",
 max (DECODE (hora, '01', avg_time_ms, 0)) "h1",
 max (DECODE (hora, '02', avg_time_ms, 0)) "h2",
 max (DECODE (hora, '03', avg_time_ms, 0)) "h3",
 max (DECODE (hora, '04', avg_time_ms, 0)) "h4",
 max (DECODE (hora, '05', avg_time_ms, 0)) "h5",
 max (DECODE (hora, '06', avg_time_ms, 0)) "h6",
 max (DECODE (hora, '07', avg_time_ms, 0)) "h7",
 max (DECODE (hora, '08', avg_time_ms, 0)) "h8",
 max (DECODE (hora, '09', avg_time_ms, 0)) "h9",
 max (DECODE (hora, '10', avg_time_ms, 0)) "h10",
 max (DECODE (hora, '11', avg_time_ms, 0)) "h11",
 max (DECODE (hora, '12', avg_time_ms, 0)) "h12",
 max (DECODE (hora, '13', avg_time_ms, 0)) "h13",
 max (DECODE (hora, '14', avg_time_ms, 0)) "h14",
 max (DECODE (hora, '15', avg_time_ms, 0)) "h15",
 max (DECODE (hora, '16', avg_time_ms, 0)) "h16",
 max (DECODE (hora, '17', avg_time_ms, 0)) "h17",
 max (DECODE (hora, '18', avg_time_ms, 0)) "h18",
 max (DECODE (hora, '19', avg_time_ms, 0)) "h19",
 max (DECODE (hora, '20', avg_time_ms, 0)) "h20",
 max (DECODE (hora, '21', avg_time_ms, 0)) "h21",
 max (DECODE (hora, '22', avg_time_ms, 0)) "h22",
 max (DECODE (hora, '23', avg_time_ms, 0)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;