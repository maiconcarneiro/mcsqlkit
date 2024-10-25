/*
 Script para gerar uma matriz com a contagem de execucoes do SQL ID por dia e hora
 Sintaxe: SQL>@heacnt <event_name> <Qtd. Dias> <Inst ID> (Onde Inst ID = 0 soma todas as instancias do cluster)
 Exemplo: SQL>@heacnt RF - Broker State Lock  30 1 
 
 Adriano Francisco
*/

set verify off
set feedback off
alter session set nls_date_format='dd/mm Dy';
set sqlformat 
set pages 999 lines 420
col snap_date heading "Date" format a10
col h0  format 99,999,999,999
col h1  format 99,999,999,999
col h2  format 99,999,999,999
col h3  format 99,999,999,999
col h4  format 99,999,999,999
col h5  format 99,999,999,999
col h6  format 99,999,999,999
col h7  format 99,999,999,999
col h8  format 99,999,999,999
col h9  format 99,999,999,999
col h10 format 99,999,999,999
col h11 format 99,999,999,999
col h12 format 99,999,999,999
col h13 format 99,999,999,999
col h14 format 99,999,999,999
col h15 format 99,999,999,999
col h16 format 99,999,999,999
col h17 format 99,999,999,999
col h18 format 99,999,999,999
col h19 format 99,999,999,999
col h20 format 99,999,999,999
col h21 format 99,999,999,999
col h22 format 99,999,999,999
col h23 format 99,999,999,999
set feedback ON

-- obtem o nome da instancia
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: EventQtd
PROMP EventName.: &1
PROMP Qt. Dias..: &2 
PROMP Instance..: &VNODE
PROMP

-- query
with awr as (
  select a.event_name, 
         a.snap_id, 
		 b.begin_interval_time as begin_snap,
	     sum(total_timeouts)                                            as timeouts,
	     sum(time_waited_micro/1000) / greatest(sum(total_timeouts),1) as Elapsed_Time
	from dba_hist_system_event a
	join dba_hist_snapshot b on (a.snap_id = b.snap_id and a.instance_number = b.instance_number)
	where 1=1
	and event_name in ('&1')
	--and executions_delta > 0
	and (&3 = 0 or b.instance_number = &3)
	and b.begin_interval_time >= trunc(sysdate) - &2
	group by a.event_name, a.snap_id, b.begin_interval_time
)
SELECT TRUNC(begin_snap) snap_date,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', timeouts, null)) "h0",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', timeouts, null)) "h1",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', timeouts, null)) "h2",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', timeouts, null)) "h3",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', timeouts, null)) "h4",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', timeouts, null)) "h5",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', timeouts, null)) "h6",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', timeouts, null)) "h7",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', timeouts, null)) "h8",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', timeouts, null)) "h9",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', timeouts, null)) "h10",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', timeouts, null)) "h11",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', timeouts, null)) "h12",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', timeouts, null)) "h13",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', timeouts, null)) "h14",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', timeouts, null)) "h15",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', timeouts, null)) "h16",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', timeouts, null)) "h17",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', timeouts, null)) "h18",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', timeouts, null)) "h19",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', timeouts, null)) "h20",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', timeouts, null)) "h21",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', timeouts, null)) "h22",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', timeouts, null)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;


