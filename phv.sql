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
            and s.BEGIN_INTERVAL_TIME between trunc(sysdate)-&2  and trunc(sysdate)+1
            and ss.sql_id = '&1'
        group by ss.sql_id, ss.plan_hash_value)
        group by sql_id, phv
 /
