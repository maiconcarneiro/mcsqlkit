set linesize 300
set pagesize 500
col sid format 99999
col target format a30
col start_time format a20
col elapsed format 99999.99
col min_remaining format 99999.99
col work format 999.00
col message format a80 trunc
select sid,
       target,
       to_char(start_time,'dd/mm/yyyy hh24:mi:ss') start_time,
       elapsed_seconds/60 elapsed,
       round(time_remaining/60,2) "min_remaining",
       round(sofar/totalwork*100,2) as work,
       message
from gv$session_longops 
where time_remaining > 0;
