-- validate supported columns
PROMP
@topseg_helper_validate

-- get instance name
@_query_dbid

-- resumo do relatorio
PROMP Report....: Top Segments by "&_AWR_TOPSEG_DESCRIPTION" (STATSPACK)
PROMP Statistic.: &&_AWR_TOPSEG_STAT_NAME
PROMP Snaps.....: &1 &2
PROMP Instance..: &VNODE
PROMP Con. Name.: &VCNAME
PROMP

set verify off
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
col value heading '&_AWR_TOPSEG_DESCRIPTION' format 999,999,999,999
set feedback on;

with total as (
 SELECT sum(value) as total_value
   FROM (
      SELECT name
            ,value - LAG(value, 1, value) OVER (PARTITION BY name ORDER BY snap_id) value
        FROM STATS$SYSSTAT
       WHERE name = '&&_AWR_TOPSEG_STAT_NAME'
        AND snap_id between &1 and &2
   ORDER BY snap_id, name
    )
),
sp_seg_stat as (
 select h.dbid,
        s.instance_number,
        s.snap_id, 
        h.obj#,
        h.dataobj#,
        h.ts#,
        LAG(s.snap_time, 1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id) as begin_interval_time,
        s.snap_time as end_interval_time,
        (logical_reads                 - LAG(logical_reads,                 1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS logical_reads_delta,
        (buffer_busy_waits             - LAG(buffer_busy_waits,             1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS buffer_busy_waits_delta,
        (db_block_changes              - LAG(db_block_changes,              1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS db_block_changes_delta,
        (physical_reads                - LAG(physical_reads,                1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS physical_reads_delta,
        (physical_writes               - LAG(physical_writes,               1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS physical_writes_delta,
        (direct_physical_reads         - LAG(direct_physical_reads,         1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS direct_physical_reads_delta,
        (direct_physical_writes        - LAG(direct_physical_writes,        1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS direct_physical_writes_delta,
        (gc_cr_blocks_received         - LAG(gc_cr_blocks_received,         1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS gc_cr_blocks_received_delta,
        (gc_current_blocks_received    - LAG(gc_current_blocks_received,    1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS gc_current_blocks_received_delta,
        (gc_buffer_busy                - LAG(gc_buffer_busy,                1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS gc_buffer_busy_delta,
        (itl_waits                     - LAG(itl_waits,                     1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS itl_waits_delta,
        (row_lock_waits                - LAG(row_lock_waits,                1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS row_lock_waits_delta,
        (global_cache_cr_blocks_served - LAG(global_cache_cr_blocks_served, 1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS global_cache_cr_blocks_served_delta,
        (global_cache_cu_blocks_served - LAG(global_cache_cu_blocks_served, 1, null) OVER (PARTITION BY h.obj#, s.dbid, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS global_cache_cu_blocks_served_delta,
        0 as physical_read_requests_delta,
        0 as physical_reads_direct_delta,
        0 as physical_write_requests_delta,
        0 as physical_writes_direct_delta,
        0 as table_scans_delta
    from STATS$SNAPSHOT s
    join STATS$SEG_STAT h on (s.snap_id = h.snap_id and s.dbid = h.dbid and s.instance_number = h.instance_number)
   where 1=1
     and h.snap_id between &1 and &2
order by  h.obj#, s.dbid, s.instance_number, s.snap_id
),
statspack as (
select o.obj#,
       o.dataobj#,
       o.tablespace_name,
       o.object_type,
       o.owner,
       o.object_name,
       o.subobject_name,
       sum(h.&_AWR_TOPSEG_COLUMN) as value
from sp_seg_stat h
join STATS$SEG_STAT_OBJ o on (h.dbid = o.dbid and h.ts# = o.ts# and h.obj# = o.obj# and h.dataobj# = o.dataobj#)
where 1=1
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
     from statspack w, total t
 order by value desc
) where rownum <= 5;