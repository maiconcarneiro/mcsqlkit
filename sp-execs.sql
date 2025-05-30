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
PROMP Metric....: Executions (STATSPACK)
PROMP SQL ID....: &1
PROMP Days......: &2 
PROMP Instance..: &VNODE
PROMP

-- query
with sp_sql_stats as (
 select h.sql_id,
        s.snap_id, 
        s.instance_number,
        LAG(s.snap_time, 1, null) OVER (PARTITION BY s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id) as begin_interval_time,
        (executions - LAG(executions, 1, 0) OVER (PARTITION BY  s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS executions_delta
    from STATS$SNAPSHOT s
    join STATS$SQL_SUMMARY h on (s.snap_id = h.snap_id and s.dbid = h.dbid and s.instance_number = h.instance_number)
   where 1=1
     and h.sql_id = '&1'
     and s.snap_time >= trunc(sysdate)-&2
     and (&3 = 0 or s.instance_number = &3)
order by s.dbid, s.instance_number, s.snap_id
),
statspack as (
  select sql_id, 
         snap_id, 
         begin_interval_time as begin_snap,
	     sum(executions_delta) as execs
	from sp_sql_stats
	where 1=1
	and executions_delta > 0
group by sql_id, snap_id, begin_interval_time
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
FROM statspack
GROUP BY TRUNC(begin_snap)
order by 1;