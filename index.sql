-- Author: Maicon Carneiro (dibiei.com)
  SET LIN 1000
  COL INDEX_NAME FORMAT A40
  COL LAST_ANALYZED FORMAT A20
  COL COLUNAS FORMAT A130
  SELECT i.index_name, 
         to_char(s.last_analyzed,'dd/mm/yyyy hh24:mi:ss') as last_analyzed, 
         LISTAGG(column_name, ', ') WITHIN GROUP (ORDER BY column_position) AS COLUNAS
    FROM dba_ind_columns i
	LEFT JOIN dba_ind_statistics s on (i.index_name = s.index_name and i.table_name = s.table_name)
   WHERE i.table_name=upper('&1')
     --AND table_owner='SYS'
GROUP BY i.index_name, s.last_analyzed;
