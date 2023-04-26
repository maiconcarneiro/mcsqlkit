-- Author: Maicon Carneiro (dibiei.com)
SET SQLFORMAT
SET LINES 400
SET PAGES 100

COL OWNER FORMAT A30
COL NAME FORMAT A30
COL OBJECT_TYPE FORMAT A15
COL COLUMN_NAME FORMAT A40
COL COLUMN_POSITION FORMAT 999

SELECT OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION 
FROM dba_part_key_columns 
WHERE NAME = '&1';

COL TABLESPACE_NAME FORMAT A20
COL TABLE_OWNER FORMAT A20
COL TABLE_NAME FORMAT A30
COL PARTITION_NAME FORMAT A20
COL PARTITION_POSITION HEADING POS FORMAT 999
COL HIGH_VALUE FORMAT A40 TRUNC
COL NUM_ROWS FORMAT 999,999,999,999,999
COL LAST_ANALYZED FORMAT A20
COL STALE_STATS HEADING STALE FORMAT 10
SELECT
    p.tablespace_name,
    p.table_owner,
    p.table_name,
    p.PARTITION_POSITION,
    p.partition_name,
    p.high_value,
    p.num_rows,
    p.last_analyzed,
    s.stale_stats
FROM dba_tab_partitions P
LEFT JOIN DBA_TAB_STATISTICS S ON (P.TABLE_OWNER = S.OWNER AND P.TABLE_NAME = S.TABLE_NAME AND P.PARTITION_NAME = S.PARTITION_NAME)
WHERE p.TABLE_NAME = '&1'
ORDER BY p.PARTITION_POSITION;


