set lines 400
set pages 50
SET FEEDBACK OFF
alter session set nls_date_format='dd/mm Dy';

SET SQLFORMAT
set verify off

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

-- get instance name
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- report summary
PROMP
PROMP Report....: History of SYSSTAT Statistic - per Second (STATSPACK)
PROMP Statistic.: &1
PROMP Days......: D-&2
PROMP Instance..: &VNODE
PROMP

SET FEEDBACK ON

with statspack as (
select TRUNC(begin_snap) begin_snap,
       TO_CHAR(begin_snap,'HH24') as snap_hour,
       round(sum(value_delta/number_factor) / greatest(sum(elapsed_secs),1) ,2) as value_per_sec
  from (
  select  /*+ MATERIALIZE */ s.dbid,
         s.instance_number,
         s.snap_id, 
         m.name,
         LAG(s.snap_time, 1, null) OVER (PARTITION BY m.name, s.startup_time, s.instance_number ORDER BY s.snap_id) as begin_snap,
         round((s.snap_time 
               - LAG(s.snap_time, 1, null) OVER (PARTITION BY m.name, s.startup_time, s.instance_number ORDER BY s.snap_id)
              ) * 24*60*60,2) elapsed_secs,
         (value - LAG(value, 1, null) OVER (PARTITION BY m.name, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS value_delta,
         (case when m.name like '%bytes%' then 1024*1024 else 1000 end) as number_factor -- convert bytes to mbytes
    from STATS$SNAPSHOT s
    join STATS$SYSSTAT m on (s.snap_id = m.snap_id and s.dbid = m.dbid and s.instance_number = m.instance_number)
   where m.name = '&1'
     and s.snap_time >= trunc(sysdate)-&2
	 and (&3 = 0 or m.instance_number = &3)
  )
group by TRUNC(begin_snap), 
         TO_CHAR(begin_snap,'HH24')
)
SELECT TRUNC(begin_snap) snap_date,
 SUM (DECODE (snap_hour, '00', value_per_sec, null)) "h0",
 SUM (DECODE (snap_hour, '01', value_per_sec, null)) "h1",
 SUM (DECODE (snap_hour, '02', value_per_sec, null)) "h2",
 SUM (DECODE (snap_hour, '03', value_per_sec, null)) "h3",
 SUM (DECODE (snap_hour, '04', value_per_sec, null)) "h4",
 SUM (DECODE (snap_hour, '05', value_per_sec, null)) "h5",
 SUM (DECODE (snap_hour, '06', value_per_sec, null)) "h6",
 SUM (DECODE (snap_hour, '07', value_per_sec, null)) "h7",
 SUM (DECODE (snap_hour, '08', value_per_sec, null)) "h8",
 SUM (DECODE (snap_hour, '09', value_per_sec, null)) "h9",
 SUM (DECODE (snap_hour, '10', value_per_sec, null)) "h10",
 SUM (DECODE (snap_hour, '11', value_per_sec, null)) "h11",
 SUM (DECODE (snap_hour, '12', value_per_sec, null)) "h12",
 SUM (DECODE (snap_hour, '13', value_per_sec, null)) "h13",
 SUM (DECODE (snap_hour, '14', value_per_sec, null)) "h14",
 SUM (DECODE (snap_hour, '15', value_per_sec, null)) "h15",
 SUM (DECODE (snap_hour, '16', value_per_sec, null)) "h16",
 SUM (DECODE (snap_hour, '17', value_per_sec, null)) "h17",
 SUM (DECODE (snap_hour, '18', value_per_sec, null)) "h18",
 SUM (DECODE (snap_hour, '19', value_per_sec, null)) "h19",
 SUM (DECODE (snap_hour, '20', value_per_sec, null)) "h20",
 SUM (DECODE (snap_hour, '21', value_per_sec, null)) "h21",
 SUM (DECODE (snap_hour, '22', value_per_sec, null)) "h22",
 SUM (DECODE (snap_hour, '23', value_per_sec, null)) "h23"
FROM statspack
GROUP BY TRUNC(begin_snap)
order by 1;