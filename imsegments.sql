set lines 400
col owner format a20
col segment_name         heading 'Segment | name'          format a25
col segment_full_name    heading 'Segment | Full name'     format a35
col partition_name       heading 'Partition | Name'        format a20
col segment_type         heading 'Segment | Type'          format a17
col populate_status      heading 'Populate | Status'       format a15
col segment_size_mb      heading 'Segment | Size (MB)'     format 999,999,999.99
col inmmeory_size_mb     heading 'In-Memory| Size (MB)'    format 999,999,999.99
col mbytes_not_populated heading 'Mbytes | not populated'  format 999,999,999.99
col inmemory_priority    heading 'In-Memory | Priority'    format a15
col inmemory_compression heading 'In-Memory | Compression' format a20
SELECT inst_id, 
       owner || '.' || segment_name as segment_full_name, 
       partition_name, 
       segment_type, 
       populate_status,
       round(bytes/1024/1024,2) segment_size_mb,
       round(inmemory_size/1024/1024,2) inmmeory_size_mb,
       round(bytes_not_populated/1024/1024,2) mbytes_not_populated,
       inmemory_priority,
       inmemory_compression
  FROM GV$IM_SEGMENTS
ORDER BY OWNER, SEGMENT_NAME;