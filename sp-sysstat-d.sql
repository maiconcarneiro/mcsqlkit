set lines 400
set pages 40
SET FEEDBACK OFF
alter session set nls_date_format='dd/mm Dy';

SET SQLFORMAT
set verify off

col snap_time heading 'Snap Time'  format a18
col name heading 'Statistic' format a35
col value_delta heading 'Total' format 999,999,999,999,999
col value_per_sec heading 'per Second' format 999,999,999,999.9
col value_per_transaction  heading 'per Transaction'  format 999,999,999,999.9
col total_transactions heading 'Transactions' format 999,999,999,999

-- get instance name
column NODE new_value VNODE 
SET termout off
SELECT CASE WHEN &3 = 0 THEN 'Cluster' ELSE instance_name || ' / ' || host_name END AS NODE FROM GV$INSTANCE WHERE (&3 = 0 or inst_id = &3);
SET termout ON

-- report summary
PROMP
PROMP Report....: History of SYSSTAT Statistic per Day (STATSPACK)
PROMP Statistic.: &1
PROMP Days......: D-&2
PROMP Instance..: &VNODE
PROMP

SET FEEDBACK ON

with transactions as (
select /*+ MATERIALIZE */ snap_id, instance_number, dbid, sum(value_delta) as total_transactions
 from (
  select s.snap_id, 
         s.instance_number,
         s.dbid,
         round((s.snap_time 
               - LAG(s.snap_time, 1, null) OVER (PARTITION BY m.name, s.startup_time, s.instance_number ORDER BY s.snap_id)
              ) * 24*60*60,2) as elapsed_secs,
         (value - LAG(value, 1, null) OVER (PARTITION BY m.name, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS value_delta
    from STATS$SNAPSHOT s
    join STATS$SYSSTAT m on (s.snap_id = m.snap_id and s.dbid = m.dbid and s.instance_number = m.instance_number)
   where m.name in ('user rollbacks','user commits')
     and s.snap_time >= trunc(sysdate)-&2
     and (&3 = 0 or m.instance_number = &3)
    )
where value_delta is not null
group by snap_id, instance_number, dbid
),
statspack as (
  select s.dbid,
         s.instance_number,
         s.snap_id,
         m.name,
         LAG(s.snap_time, 1, null) OVER (PARTITION BY m.name, s.startup_time, s.instance_number ORDER BY s.snap_id) as begin_interval_time,
         s.snap_time end_interval_time,
         round((s.snap_time 
               - LAG(s.snap_time, 1, null) OVER (PARTITION BY m.name, s.startup_time, s.instance_number ORDER BY s.snap_id)
              ) * 24*60*60,2) elapsed_secs,
         value,
         (value - LAG(value, 1, null) OVER (PARTITION BY m.name, s.startup_time, s.instance_number ORDER BY s.snap_id)) AS value_delta
    from STATS$SNAPSHOT s
    join STATS$SYSSTAT m on (s.snap_id = m.snap_id and s.dbid = m.dbid and s.instance_number = m.instance_number)
   where m.name = '&1'
     and s.snap_time >= trunc(sysdate)-&2
	 and (&3 = 0 or m.instance_number = &3)
)
select  trunc(begin_interval_time) as snap_time
       ,name
       ,sum(value_delta) as value_delta
       ,round(sum(value_delta) / greatest(sum(elapsed_secs),1) ,2) as value_per_sec
       ,round(sum(value_delta) / greatest(sum(total_transactions),1) ,2) as value_per_transaction
       --,sum(total_transactions) total_transactions
  from statspack s
  join transactions t on (s.snap_id = t.snap_id and s.dbid = t.dbid and s.instance_number = t.instance_number)
 where begin_interval_time is not null
group by trunc(begin_interval_time), name
order by snap_time;