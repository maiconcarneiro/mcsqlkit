/*
 Script to show the AWR configuration for the current Database (support non-CDB & CDB/PDB)
 SQL> @awrconfig
 Maicon Carneiro | dibiei.blog
 Last updated: 25/10/2024
*/

set verify off;
set feedback off;
set lines 400
col dbid format 99999999999999
col snap_interval format a30
col retention format a30
col topnsql format a10
col src_dbname format a30
col tablespace_name format a20
col registration_type format a30
col most_recent_snap_id heading 'Most Recent|Snap ID' format 999999
alter session set nls_timestamp_format='dd/mm/yyyy hh24:mi:ss';

-- check the release version of the database
-- 12cR1+ include the CON_ID column in the views
column FILER_LINE new_value vFILER_LINE
column NEW_COLS   new_value vNEW_COLS
set termout off;
select (case when VERSION < '12.1'
           then 'and dbid = (select dbid from v$database)'
           else 'and con_id = sys_context(''USERENV'',''CON_ID'')'
        end)  as FILER_LINE,
       (case when VERSION < '12.1'
           then 'dbid'
           else 'dbid,con_id'
        end) as NEW_COLS
 from v$instance;
set termout on;
set feedback on;


select snap_interval, 
       retention, 
       topnsql,
       &vNEW_COLS
  from dba_hist_wr_control
 where 1=1
 &vFILER_LINE -- dynamic filter for 11gR2- or 12cR1+
 ;