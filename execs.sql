/*
 Script para gerar uma matriz com a contagem de execucoes do SQL ID por dia e hora
 Sintaxe: SQL>@execs <SQL_ID> <Qtd. Dias> <Inst ID> (Onde Inst ID = 0 soma todas as instancias do cluster)
 Exemplo: SQL>@execs @execs c3bpu9sapxhpw 10 1 
 
 Maicon Carneiro | Salvador-BA, 11/11/2022
*/

set verify off
set feedback off
alter session set nls_date_format='dd/mm';
set sqlformat 
set pages 999 lines 400
col snap_date heading "Date" format a7
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
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- resumo do relatorio
PROMP
PROMP Metrica...: Executions
PROMP SQL ID....: &1
PROMP Qt. Dias..: &2 
PROMP Instance..: &VNODE
PROMP

-- query
with awr as (
  select a.sql_id, a.snap_id, b.begin_interval_time as begin_snap,
	     sum(executions_delta)                                            as execs,
	     sum(elapsed_time_delta/1000) / greatest(sum(executions_delta),1) as Elapsed_Time
	from dba_hist_sqlstat a
	join dba_hist_snapshot b on (a.snap_id = b.snap_id and a.instance_number = b.instance_number)
	where 1=1
	and sql_id in ('&1')
	--and executions_delta > 0
	and (&3 = 0 or b.instance_number = &3)
	and b.begin_interval_time >= trunc(sysdate) - &2
	group by a.sql_id, a.snap_id, b.begin_interval_time
)
SELECT TRUNC(begin_snap) snap_date,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', execs, null)) "h0",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', execs, null)) "h1",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', execs, null)) "h2",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', execs, null)) "h3",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', execs, null)) "h4",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', execs, null)) "h5",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', execs, null)) "h6",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', execs, null)) "h7",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', execs, null)) "h8",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', execs, null)) "h9",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', execs, null)) "h10",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', execs, null)) "h11",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', execs, null)) "h12",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', execs, null)) "h13",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', execs, null)) "h14",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', execs, null)) "h15",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', execs, null)) "h16",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', execs, null)) "h17",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', execs, null)) "h18",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', execs, null)) "h19",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', execs, null)) "h20",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', execs, null)) "h21",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', execs, null)) "h22",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', execs, null)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;