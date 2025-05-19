
-- obtem o nome da instancia
@_query_dbid

-- resumo do relatorio
PROMP
PROMP Metric....: Top Segments by "&_AWR_TOPSEG_DESCRIPTION"
PROMP Snaps.....: &1 &2 
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

set lines 400
set pages 10
col tablespace_name heading 'Tablespace Name' format a20
col owner heading 'Owner' format a20
col object_name heading 'Object Name' format a30
col subobject_name heading 'Subobject Name' format a20
col object_type heading 'Object Type' format a15
col obj# heading 'Obj#' format 9999999999
col dataobj# heading 'Dataobj#' format 9999999999
col pct_total heading '% of Capture' format 999.99
col value heading '&_AWR_TOPSEG_DESCRIPTION' format 999,999,999

with total as (
 SELECT sum(value) as total_value
   FROM (
      SELECT stat_name
            ,value - LAG(value, 1, value) OVER (PARTITION BY stat_name ORDER BY snap_id) value
        FROM dba_hist_sysstat
       WHERE stat_name = '&_AWR_TOPSEG_STAT_NAME'
        AND snap_id >= &1
        AND snap_id <= &2
   ORDER BY snap_id, stat_name
    )
),
awr as (
select o.obj#,
       o.dataobj#,
       o.tablespace_name,
       o.object_type,
       o.owner,
       o.object_name,
       o.subobject_name,
       sum(h.&_AWR_TOPSEG_COLUMN) as value
from dba_hist_seg_stat h
join dba_hist_seg_stat_obj o on (h.dbid = o.dbid and h.ts# = o.ts# and h.obj# = o.obj# and h.dataobj# = o.dataobj#)
where h.snap_id >  &1 
  and h.snap_id <= &2
  and h.&_AWR_TOPSEG_COLUMN > 0
  and h.dbid = (&_DBID)
group by o.tablespace_name,
         o.owner,
         o.object_name, 
         o.subobject_name,
         o.object_type,
         o.obj#,
         o.dataobj#
)
select * from (
   select w.*,
          round(w.value / t.total_value * 100,2) as pct_total
     from awr w, total t
 order by value desc
) where rownum <= 5;