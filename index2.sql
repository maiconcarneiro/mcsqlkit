  SET LIN 1000
  COL INDEX_NAME FORMAT A40
  COL LAST_ANALYZED FORMAT A20
  COL COLUNAS FORMAT A130
  SELECT i.index_name, 
         LISTAGG(column_name, ', ') WITHIN GROUP (ORDER BY column_position) AS COLUNAS
    FROM dba_ind_columns i
   WHERE i.table_name=upper('&1')
     AND table_owner=upper('&2')
GROUP BY i.index_name;
