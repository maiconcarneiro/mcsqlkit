
set LIN 1000
set feedback off
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD/MM/YYYY HH24:MI:SS';
set feedback on
COL Inicio FORMAT A20
COL Final FORMAT A20
COL SAMPLE_TIME FORMAT A20
COL EVENT FORMAT A40
COL P1TEXT FORMAT A15
COL P2TEXT FORMAT A15
COL P3TEXT FORMAT A15
COL CNT FORMAT 999,999
COL SQL_OPNAME FORMAT A15
select /*+ RULE */ * from (
select min(SAMPLE_TIME) as inicio, max(SAMPLE_TIME) as final, sql_id, event, p1,p2,p3,
--p1text,p2text,p3text, 
ASH.SQL_OPNAME, count(*) as CNT
, COUNT(DISTINCT(SESSION_ID||'.'||INSTANCE_NUMBER)) AS SESSIONS
from DBA_HIST_ACTIVE_SESS_HISTORY ash
where 1=1
and dbid = (select dbid from v$database)
and snap_id between &1 and &1+1
and ASH.EVENT ='enq: TX - row lock contention'
and sql_id in ('6v5ccrqv13gas')
group by sql_id, event, p1,p2,p3,p1text,p2text,p3text,ASH.SQL_OPNAME
order by cnt desc
)
where rownum <= 10;
