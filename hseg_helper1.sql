
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
define COL_NUM_FORMAT='999,999' -- define the format used in numeric columns
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
select s.snap_id, 
       s.begin_interval_time as begin_snap,
       o.obj#,
       o.dataobj#,
       o.tablespace_name,
       o.object_type,
       o.owner,
       o.object_name,
       o.subobject_name,
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
group by s.snap_id, 
         s.begin_interval_time,
         o.tablespace_name,
         o.owner,
         o.object_name, 
         o.subobject_name,
         o.object_type,
         o.obj#,
         o.dataobj#
)
SELECT TRUNC(begin_snap) snap_date,
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '00', value, null)) "h0",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '01', value, null)) "h1",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '02', value, null)) "h2",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '03', value, null)) "h3",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '04', value, null)) "h4",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '05', value, null)) "h5",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '06', value, null)) "h6",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '07', value, null)) "h7",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '08', value, null)) "h8",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '09', value, null)) "h9",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '10', value, null)) "h10",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '11', value, null)) "h11",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '12', value, null)) "h12",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '13', value, null)) "h13",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '14', value, null)) "h14",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '15', value, null)) "h15",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '16', value, null)) "h16",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '17', value, null)) "h17",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '18', value, null)) "h18",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '19', value, null)) "h19",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '20', value, null)) "h20",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '21', value, null)) "h21",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '22', value, null)) "h22",
 SUM (DECODE (TO_CHAR (begin_snap, 'hh24'), '23', value, null)) "h23"
FROM awr
GROUP BY TRUNC(begin_snap)
order by 1
