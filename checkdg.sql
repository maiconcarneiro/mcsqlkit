SET FEEDBACK OFF

PROMPT
PROMPT ############################### SCN do Controlfile ############################################
PROMPT
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD/MM/YYYY HH24:MI:SS';
SET LINES 400
COL CURRENT_SCN           format 99999999999999999999
COL CHECKPOINT_CHANGE#    format 99999999999999999999
COL CONTROLFILE_CHANGE#   format 99999999999999999999
SELECT CURRENT_SCN,
       CHECKPOINT_CHANGE#,
       CONTROLFILE_CHANGE#
 FROM V$DATABASE;

PROMPT
PROMPT ################################# Processos do Data Guard ####################################
PROMPT
set pagesize 500
set linesize 300
col process format a15
col status format a15
col group# format 999
col sequence# format 99999999
SELECT process, status, group#, thread#, sequence#
FROM v$managed_standby
order by process, group#, thread#, sequence#;

PROMPT
PROMPT ################################# Status do Data Guard #######################################
PROMPT
set linesize 300
col name format a25
col value format a25
col unit format a30
col time_computed format a20
select NAME, VALUE, UNIT, DATUM_TIME, TIME_COMPUTED FROM V$DATAGUARD_STATS;
SET FEEDBACK ON


PROMPT
PROMPT ################################ Checkpoint do Standby #######################################
PROMPT
col dtcoleta format a20
col min_time format a20
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') as dtcoleta,
max(SEQUENCE#) sequence,
to_char(max(FIRST_TIME),'dd/mm/yyyy hh24:mi:ss') min_time
from v$log_history;

PROMPT
PROMPT ############################### Checkpoint dos Datafiles #####################################
PROMPT
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
select checkpoint_time, count(*)
from v$datafile_header d
group by checkpoint_time
order by 1 desc;
