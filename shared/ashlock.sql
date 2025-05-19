accept bd prompt "BEGIN DATE [sysdate-1]: " default "sysdate-1"
accept ed prompt "END DATE   [sysdate]  : " default "sysdate"
accept hb prompt "HOURS TO LOOK BACK FOR BLOCKING SESSION INFO [1] (use -1 to match SAMPLE_TIME): " default "1"
 
col BLOCKING_SESSION for a14
col BLOCKING_USER for a15 TRUNC
col BLOCKING_MODULE for a15 TRUNC
col BLOCKED_SESSION for a14
col BLOCKED_USER for a15 TRUNC
col BLOCKED_MODULE for a15 TRUNC
col BLOCKED_OBJECT for a30 TRUNC
col EVENT for a30 TRUNC
col WAIT_CLASS for a12 TRUNC
col BLOCKING_LAST_ACTIVE for a30
break on BLOCKING_SESSION skip 1
 
WITH
dbahist0 as (
    select /*+ MATERIALIZE PARALLEL(a 1) */
        SAMPLE_TIME, DBID, INSTANCE_NUMBER, SESSION_ID, SESSION_SERIAL#, USER_ID, MODULE,
        BLOCKING_SESSION, BLOCKING_SESSION_SERIAL#, BLOCKING_INST_ID, BLOCKING_SESSION_STATUS,
        CURRENT_OBJ#, SQL_ID, 
        nvl(a.EVENT,'On CPU') as EVENT,
        nvl(a.WAIT_CLASS,'On CPU') as WAIT_CLASS
    from DBA_HIST_ACTIVE_SESS_HISTORY a
    -- Looking back &hb hours before the time window to try finding blocking session info if they are INACTIVE when blocking
    where SAMPLE_TIME between &bd - &hb/24 and &ed
    and DBID = (select DBID from v$database)
),
dbahist as (
    select a.*
    from dbahist0 a
    -- Now refiltering the dates to keep only the real time window
    where SAMPLE_TIME between &bd and &ed
    -- Only blocked sessions
    and BLOCKING_SESSION is not null
    and BLOCKING_SESSION_STATUS = 'VALID'
    -- I only want to see events related to applications activity, like 'row lock contention', 
    --    but not instance-related, like 'latch free' or 'log file sync'. Remove if you want to see all.
    and wait_class = 'Application'
    -- I don't want to see activity from SYS. Remove if you want to see all.
    and user_id != 0
),
blocking as (
    select DBID, INSTANCE_NUMBER,
        SESSION_ID, SESSION_SERIAL#, USER_ID, max(MODULE) as MODULE, max(SAMPLE_TIME) LAST_ACTIVE
    from dbahist0 b
    group by DBID, INSTANCE_NUMBER, SESSION_ID, SESSION_SERIAL#, b.USER_ID
),
q as (
    select cast(a.SAMPLE_TIME as date) SAMPLE_TIME,
        lpad(a.BLOCKING_SESSION || ',' || a.BLOCKING_SESSION_SERIAL# || ',@' || a.BLOCKING_INST_ID, 14, ' ') as BLOCKING_SESSION,
        coalesce(blocking.MODULE,blocking2.MODULE) as BLOCKING_MODULE, 
        coalesce(blocking.USER_ID,blocking2.USER_ID) as BLOCKING_USER_ID, 
        lpad(a.SESSION_ID || ',' || a.SESSION_SERIAL# || ',@' || a.INSTANCE_NUMBER, 14, ' ') as BLOCKED_SESSION, 
        a.MODULE as BLOCKED_MODULE, a.USER_ID as BLOCKED_USER_ID, a.CURRENT_OBJ#,
        a.SQL_ID as BLOCKED_SQLID, a.EVENT, a.WAIT_CLASS, blocking.LAST_ACTIVE
    from dbahist a
    left join blocking
        on '&hb' != '-1'
        and a.DBID = blocking.DBID
        and a.BLOCKING_INST_ID = blocking.INSTANCE_NUMBER
        and a.BLOCKING_SESSION = blocking.SESSION_ID
        and a.BLOCKING_SESSION_SERIAL# = blocking.SESSION_SERIAL#
    left join dbahist0 blocking2
        on '&hb' = '-1'
        and a.DBID = blocking2.DBID
        and a.BLOCKING_INST_ID = blocking2.INSTANCE_NUMBER
        and a.BLOCKING_SESSION = blocking2.SESSION_ID
        and a.BLOCKING_SESSION_SERIAL# = blocking2.SESSION_SERIAL#
        and a.SAMPLE_TIME = blocking2.SAMPLE_TIME
)
select
    BLOCKING_SESSION, nvl(ub.USERNAME,'***NOT FOUND***') as BLOCKING_USER, nvl(BLOCKING_MODULE,'***NOT FOUND***') as BLOCKING_MODULE, 
    BLOCKED_SESSION, u.USERNAME as BLOCKED_USER, BLOCKED_MODULE, BLOCKED_SQLID, 
    o.OWNER || '.' || o.OBJECT_NAME as BLOCKED_OBJECT,
    EVENT, WAIT_CLASS,
    count(1) QTY, min(SAMPLE_TIME) MIN_TIME, max(SAMPLE_TIME) MAX_TIME, LAST_ACTIVE as BLOCKING_LAST_ACTIVE
from q
left join dba_users u on u.USER_ID = q.BLOCKED_USER_ID
left join dba_users ub on ub.USER_ID = q.BLOCKING_USER_ID
left join dba_objects o on o.OBJECT_ID = q.CURRENT_OBJ#
group by 
    BLOCKING_SESSION, ub.USERNAME, BLOCKING_MODULE, LAST_ACTIVE,
    BLOCKED_SESSION, u.USERNAME, BLOCKED_MODULE,
    BLOCKED_SQLID, o.OWNER, o.OBJECT_NAME, EVENT, WAIT_CLASS
order by BLOCKING_SESSION, BLOCKED_SESSION 
/