set verify off
set feedback off
alter session set nls_date_format='dd/mm';
set sqlformat 
set pages 999 lines 400
col snap_date heading "Date" format a7
col h0  format &&_COL_NUM_FORMAT
col h1  format &&_COL_NUM_FORMAT
col h2  format &&_COL_NUM_FORMAT
col h3  format &&_COL_NUM_FORMAT
col h4  format &&_COL_NUM_FORMAT
col h5  format &&_COL_NUM_FORMAT
col h6  format &&_COL_NUM_FORMAT
col h7  format &&_COL_NUM_FORMAT
col h8  format &&_COL_NUM_FORMAT
col h9  format &&_COL_NUM_FORMAT
col h10 format &&_COL_NUM_FORMAT
col h11 format &&_COL_NUM_FORMAT
col h12 format &&_COL_NUM_FORMAT
col h13 format &&_COL_NUM_FORMAT
col h14 format &&_COL_NUM_FORMAT
col h15 format &&_COL_NUM_FORMAT
col h16 format &&_COL_NUM_FORMAT
col h17 format &&_COL_NUM_FORMAT
col h18 format &&_COL_NUM_FORMAT
col h19 format &&_COL_NUM_FORMAT
col h20 format &&_COL_NUM_FORMAT
col h21 format &&_COL_NUM_FORMAT
col h22 format &&_COL_NUM_FORMAT
col h23 format &&_COL_NUM_FORMAT
set feedback ON

-- obtem o nome da instancia
@_query_dbid

-- resumo do relatorio
PROMP
PROMP Metric....: PGA Workarea Pass/Multipass Counts History in AWR
PROMP Count Type: &_PGA_PASS_HELPER_COLUMN
PROMP Qt. Days..: &2 
PROMP Instance..: &VNODE
PROMP

-- query
with awr as (
  select trunc(b.begin_interval_time) as begin_snap,
         to_char(b.begin_interval_time, 'hh24') as hora,
         round(sum(&_PGA_PASS_HELPER_COLUMN) / sum(total_executions) * 100,4) as value_pct,
         sum(&_PGA_PASS_HELPER_COLUMN)/greatest(&_DIVISOR,1) as value 
  from dba_hist_sql_workarea_hstgrm a
  join dba_hist_snapshot b on (a.snap_id = b.snap_id and a.instance_number = b.instance_number and a.dbid = b.dbid)
  where 1=1
    and (&2 = 0 or b.instance_number = &2)
    and b.begin_interval_time >= trunc(sysdate) - &1
  group by trunc(b.begin_interval_time),
           to_char(b.begin_interval_time, 'hh24')
)

SELECT TRUNC(begin_snap) snap_date,
       max (DECODE (hora, '00', &_COLUMN_ALIAS, null)) "h0",
       max (DECODE (hora, '01', &_COLUMN_ALIAS, null)) "h1",
       max (DECODE (hora, '02', &_COLUMN_ALIAS, null)) "h2",
       max (DECODE (hora, '03', &_COLUMN_ALIAS, null)) "h3",
       max (DECODE (hora, '04', &_COLUMN_ALIAS, null)) "h4",
       max (DECODE (hora, '05', &_COLUMN_ALIAS, null)) "h5",
       max (DECODE (hora, '06', &_COLUMN_ALIAS, null)) "h6",
       max (DECODE (hora, '07', &_COLUMN_ALIAS, null)) "h7",
       max (DECODE (hora, '08', &_COLUMN_ALIAS, null)) "h8",
       max (DECODE (hora, '09', &_COLUMN_ALIAS, null)) "h9",
       max (DECODE (hora, '10', &_COLUMN_ALIAS, null)) "h10",
       max (DECODE (hora, '11', &_COLUMN_ALIAS, null)) "h11",
       max (DECODE (hora, '12', &_COLUMN_ALIAS, null)) "h12",
       max (DECODE (hora, '13', &_COLUMN_ALIAS, null)) "h13",
       max (DECODE (hora, '14', &_COLUMN_ALIAS, null)) "h14",
       max (DECODE (hora, '15', &_COLUMN_ALIAS, null)) "h15",
       max (DECODE (hora, '16', &_COLUMN_ALIAS, null)) "h16",
       max (DECODE (hora, '17', &_COLUMN_ALIAS, null)) "h17",
       max (DECODE (hora, '18', &_COLUMN_ALIAS, null)) "h18",
       max (DECODE (hora, '19', &_COLUMN_ALIAS, null)) "h19",
       max (DECODE (hora, '20', &_COLUMN_ALIAS, null)) "h20",
       max (DECODE (hora, '21', &_COLUMN_ALIAS, null)) "h21",
       max (DECODE (hora, '22', &_COLUMN_ALIAS, null)) "h22",
       max (DECODE (hora, '23', &_COLUMN_ALIAS, null)) "h23"
 FROM awr
GROUP BY TRUNC(begin_snap)
order by 1;