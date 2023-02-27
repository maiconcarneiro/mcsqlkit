-- Author: Maicon Carneiro (dibiei.com)
  set pagesize 5000
  col x_melhor format 999999999999999.9999
  set lines 400  
with atual as (
     select sql_id, 
               phv , 
               min(exe_avg) min_exe_avg
        from ( 
        select ss.sql_id, ss.plan_hash_value phv,
                (sum(ss.elapsed_time_delta)/1000000)/sum(ss.executions_delta) exe_avg
            from dba_hist_sqlstat ss, dba_hist_snapshot s
        where ss.dbid = s.dbid
            and ss.instance_number = s.instance_number
            and ss.snap_id = s.snap_id
            and ss.executions_delta > 0
            and s.BEGIN_INTERVAL_TIME >= to_date('18/09/2022 00:00:00','dd/mm/yyyy hh24:mi:ss')
        group by ss.sql_id, ss.plan_hash_value
        )
        group by sql_id, phv
  )
  select a.sql_id, 
         a.phv, 
         a.min_exe_avg as avg_secs_atual, 
         h.min_exe_avg as avg_secs_hist,
         (case when a.min_exe_avg >= h.min_exe_avg 
               then a.min_exe_avg / h.min_exe_avg
               else h.min_exe_avg / a.min_exe_avg
          end) x_melhor,
         (case when a.min_exe_avg <= h.min_exe_avg then 'Melhor' else 'Pior' end) as status
  from atual a
  join (
        select sql_id, 
               phv , 
               min(exe_avg) min_exe_avg
        from ( 
        select ss.sql_id, ss.plan_hash_value phv,
                (sum(ss.elapsed_time_delta)/1000000)/sum(ss.executions_delta) exe_avg
            from dba_hist_sqlstat ss, dba_hist_snapshot s
        where ss.dbid = s.dbid
            and ss.instance_number = s.instance_number
            and ss.snap_id = s.snap_id
            and ss.executions_delta > 0
            and s.BEGIN_INTERVAL_TIME <= to_date('17/09/2022 23:59:59','dd/mm/yyyy hh24:mi:ss')
        group by ss.sql_id, ss.plan_hash_value)
        group by sql_id, phv
     ) h on a.sql_id = h.sql_id and a.phv = h.phv
  order by status, x_melhor desc;
