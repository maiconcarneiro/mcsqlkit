
set pages 50
set lines 400
col owner format a20
col table_name format a30
col tbsize format 999,999,999,999
col idxsize format 999,999,999,999
col lobsize format 999,999,999,999
col total format 999,999,999,999
SELECT OWNER, TABLE_NAME, 
       SUM(TABSIZE)/1024/1024   AS TBSIZE, 
       SUM(IDXSIZE)/1024/1024   AS IDXSIZE, 
       SUM(LOBSIZE)/1024/1024       AS LOBSIZE,
       SUM(TABSIZE+IDXSIZE+LOBSIZE)/1024/1024 AS TOTAL
FROM (

SELECT S.OWNER, S.SEGMENT_NAME AS TABLE_NAME, BYTES AS TABSIZE, 0 AS IDXSIZE, 0 AS LOBSIZE
  FROM DBA_SEGMENTS S 
 WHERE OWNER = '&1'
   AND SEGMENT_NAME = '&2'
   AND SEGMENT_TYPE IN ('TABLE','TABLE PARTITION','TABLE SUBPARTITION')
   
   
UNION ALL

SELECT I.TABLE_OWNER AS OWNER, I.TABLE_NAME, 0 AS TABSIZE, BYTES AS IDXSIZE, 0 AS LOBSIZE
  FROM DBA_INDEXES I, DBA_SEGMENTS S 
 WHERE I.INDEX_NAME=S.SEGMENT_NAME
   AND I.OWNER = S.OWNER
   AND I.OWNER = '&1'
   AND I.TABLE_NAME = '&2'
   AND SEGMENT_TYPE IN ('INDEX','INDEX PARTITION','INDEX SUBPARTITION')

UNION ALL

select l.owner, l.table_name, 0 as tabsize, 0 as idxsize, sum(s.bytes) as lobsize
from dba_lobs l
join dba_tables t on l.owner = t.owner and l.table_name = t.table_name
join dba_segments s on l.owner = s.owner and l.segment_name = s.segment_name
where l.owner = '&1'
and l.table_name = '&2'
and s.segment_type in ('LOB PARTITION','LOBSEGMENT','LOBINDEX')
group by l.owner, l.table_name

)
GROUP BY OWNER, TABLE_NAME;


col index_name format a30
SELECT I.INDEX_NAME, SUM(BYTES)/1024/1024 AS IDXSIZE
  FROM DBA_INDEXES I, DBA_SEGMENTS S 
 WHERE I.INDEX_NAME=S.SEGMENT_NAME
   AND I.OWNER = S.OWNER
   AND I.OWNER = '&1'
   AND I.TABLE_NAME = '&2'
   AND SEGMENT_TYPE IN ('INDEX','INDEX PARTITION','INDEX SUBPARTITION')
GROUP BY I.INDEX_NAME;