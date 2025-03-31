set lines 400
col populate_status heading 'Populate | Status'  format a15
col alloc_mbytes    heading 'Allocated (MB)'     format 999,999,999.99
col used_mbytes     heading 'Used (MB)'          format 999,999,999.99
SELECT inst_id,
       pool, 
       populate_status,
       round(alloc_bytes/1024/1024,2) alloc_mbytes, 
       round(used_bytes/1024/1024,2) used_mbytes
  FROM GV$INMEMORY_AREA;