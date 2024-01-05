set linesize 200
col dbid format 99999999999999
col snap_interval format a30
col retention format a30
col topnsql format a10
col src_dbname format a30
select * from dba_hist_wr_control;
