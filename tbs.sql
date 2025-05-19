set sqlformat
set lines 132
set pages 105
set pause off
set echo off
set feedb on
column tablespace_name      heading 'Tablespace Name' format a30
column TOTAL_ALLOC_GB       heading '[Maxsize] | Total (GB)'     format 9,999,990.00
column TOTAL_APHYS_ALLOC_GB heading '[Current]| Allocated (GB)'  format 9,999,990.00
column USED_GB              heading 'Used (GB)'             format 9,999,990.00
column FREE_GB              heading 'FREE (GB)'             format 9,999,990.00
column USED_PERC            heading "% USED"                format 990.00
select a.tablespace_name,
       a.bytes_alloc/(1024*1024*1024) TOTAL_ALLOC_GB,
       a.physical_bytes/(1024*1024*1024) TOTAL_APHYS_ALLOC_GB,
       nvl(b.tot_used,0)/(1024*1024*1024) USED_GB,
       (a.bytes_alloc-nvl(b.tot_used,0)) /(1024*1024*1024) FREE_GB,
       (nvl(b.tot_used,0)/a.bytes_alloc)*100 USED_PERC
from ( select tablespace_name,
       sum(bytes) physical_bytes,
       sum(decode(autoextensible,'NO',bytes,'YES',maxbytes)) bytes_alloc
       from dba_data_files
       group by tablespace_name ) a,
     ( select tablespace_name, sum(bytes) tot_used
       from dba_segments
       group by tablespace_name ) b
where a.tablespace_name = b.tablespace_name (+)
--and   a.tablespace_name like 'UNDO%'
order by 1;