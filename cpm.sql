-- query para comparar o tempo de execucao das querys das sessoes ativas vs historico do AWR
set verify off
COL CN FOR 99999
set lines 1000
col sql_text for a20
col username for a15
col "EXE_AVG" for 9999999999.00000
col "CPU_AVG" for 9999999999.00000
col "EXE_AVG_AWR" for 9999999999.0000000000
col "X_VEZES" for 999999.000
col X_VEZES for a50

spool compara_online.txt
 
select status, sql_id, min(exe_avg) exe_avg, min(cpu_avg) cpu_avg, phv, EXE_AVG_AWR, PHV_AWR,
(case when PHV = PHV_AWR then 'PHV IGUAL' else 'PHV DIFERENTE' end) PHV_STATUS ,
(case when status = 'PIOR' then to_char(min(exe_avg)/EXE_AVG_AWR,'999.99')||' x PIOR' else to_char(EXE_AVG_AWR/decode(min(exe_avg),0,1,min(exe_avg)),'999.99')||' x MELHOR' end) X_VEZES from
(
select distinct vsql.executions,
(case when decode(vsql.executions,0,0,vsql.elapsed_time/vsql.executions)/1000000 < SS.min_exe_avg then 'MELHOR' else 'PIOR' end) STATUS,
vs.sql_id,
decode(vsql.executions,0,0,vsql.elapsed_time/vsql.executions)/1000000 "EXE_AVG",
decode(vsql.executions,0,0,vsql.cpu_time/vsql.executions)/1000000 "CPU_AVG",
vsql.plan_hash_value phv,
SS.min_exe_avg "EXE_AVG_AWR",
SS.PHV "PHV_AWR",
vs.username,
vs.sql_child_number CN
/*vsql.executions,
vs.osuser,
vsql.optimizer_mode OM */
from
gv$session vs, gv$sql vsql,
(
select sql_id, phv , min(exe_avg) min_exe_avg , ROW_NUMBER( ) OVER (PARTITION BY sql_id ORDER BY min(exe_avg)) as rn
from ( select ss.sql_id, ss.plan_hash_value phv,
(sum(ss.elapsed_time_delta)/1000000)/sum(ss.executions_delta) exe_avg
from dba_hist_sqlstat ss,
dba_hist_snapshot s
where ss.dbid = s.dbid
and ss.instance_number = s.instance_number
and ss.snap_id = s.snap_id
and ss.executions_delta > 0
group by ss.sql_id, ss.plan_hash_value)
group by sql_id, phv
) ss
where vs.sql_id = vsql.sql_id
and vs.sql_child_number = vsql.child_number
and vs.inst_id = vsql.inst_id
and vs.sql_id = ss.sql_id
and vs.module = '&1'
and vs.type='USER'
--and vs.module not like 'sqlplus%'
and ss.rn = 1
)
group by status, sql_id, phv, EXE_AVG_AWR, PHV_AWR
order by 1,8,3
/

spool off
