
-- obtem o nome da instancia
@_query_dbid

-- resumo do relatorio
PROMP
PROMP Metric....: Segment Stats in AWR (&_AWR_TOPSEG_DESCRIPTION)
PROMP Object....: &1 &2
PROMP Qt. Days..: &3
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

set feedback off
alter session set nls_date_format='dd/mm Dy';
set sqlformat
set pages 999 lines 400
col snap_date heading "Date" format a10
define COL_NUM_FORMAT='A8' -- define the format used in numeric columns
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

with awr as (
select o.obj#,
       o.dataobj#,
       trunc(s.begin_interval_time) as begin_snap,
       TO_CHAR (s.begin_interval_time, 'hh24') as snap_hour,
       sum(h.&_AWR_TOPSEG_COLUMN) as value
from dba_hist_snapshot s
join dba_hist_seg_stat h on (s.snap_id = h.snap_id and s.dbid = h.dbid and s.instance_number = h.instance_number)
join dba_hist_seg_stat_obj o on (h.dbid = o.dbid and h.ts# = o.ts# and h.obj# = o.obj# and h.dataobj# = o.dataobj#)
where 1=1
  and s.end_interval_time >= sysdate-&3
  and h.&_AWR_TOPSEG_COLUMN > 0
  and o.owner = '&1'
  and o.object_name = '&2'
  and h.dbid = (&_DBID)
group by o.obj#,
       o.dataobj#,
       trunc(s.begin_interval_time),
       TO_CHAR (s.begin_interval_time, 'hh24')
), 
matrix as (
SELECT TRUNC(begin_snap) snap_date,
 MAX (DECODE (snap_hour, '00', value, null)) h0,
 MAX (DECODE (snap_hour, '01', value, null)) h1,
 MAX (DECODE (snap_hour, '02', value, null)) h2,
 MAX (DECODE (snap_hour, '03', value, null)) h3,
 MAX (DECODE (snap_hour, '04', value, null)) h4,
 MAX (DECODE (snap_hour, '05', value, null)) h5,
 MAX (DECODE (snap_hour, '06', value, null)) h6,
 MAX (DECODE (snap_hour, '07', value, null)) h7,
 MAX (DECODE (snap_hour, '08', value, null)) h8,
 MAX (DECODE (snap_hour, '09', value, null)) h9,
 MAX (DECODE (snap_hour, '10', value, null)) h10,
 MAX (DECODE (snap_hour, '11', value, null)) h11,
 MAX (DECODE (snap_hour, '12', value, null)) h12,
 MAX (DECODE (snap_hour, '13', value, null)) h13,
 MAX (DECODE (snap_hour, '14', value, null)) h14,
 MAX (DECODE (snap_hour, '15', value, null)) h15,
 MAX (DECODE (snap_hour, '16', value, null)) h16,
 MAX (DECODE (snap_hour, '17', value, null)) h17,
 MAX (DECODE (snap_hour, '18', value, null)) h18,
 MAX (DECODE (snap_hour, '19', value, null)) h19,
 MAX (DECODE (snap_hour, '20', value, null)) h20,
 MAX (DECODE (snap_hour, '21', value, null)) h21,
 MAX (DECODE (snap_hour, '22', value, null)) h22,
 SUM (DECODE (snap_hour, '23', value, null)) h23
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