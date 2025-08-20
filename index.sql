  /*
 Script to list columns of all indexes for a specific table
 Syntax: @index <SCHEMA> <TABLE>
  
  Examples:
   @index SOE ORDERS
   @index sh sales

 Author: Maicon Carneiro | dibiei.blog
*/

PROMP
PROMP Report..: Column list of indexes
PROMP Schema..: &1     
PROMP Table...: &2

SET PAGES 30
SET LIN 1000
COL INDEX_NAME    heading 'Index|Name'         FORMAT A30
COL LAST_ANALYZED heading 'Last|Analyzed'      FORMAT a20
COL INDEX_COLUMNS heading 'Index|Columns list' FORMAT A130

SELECT i.index_name, 
       to_char(max((
        select max(last_analyzed)
          from dba_ind_statistics s
         where i.index_owner = s.owner 
         and i.index_name  = s.index_name 
         and i.table_owner = s.table_owner 
         and i.table_name  = s.table_name 
       )) , 'DD/MM/YYYY HH24:MI:SS') as last_analyzed,
       LISTAGG(i.column_name, ', ') WITHIN GROUP (ORDER BY i.column_position) AS INDEX_COLUMNS
  FROM dba_ind_columns i
 WHERE 1=1 
   AND i.table_owner = upper('&1')
   AND i.table_name  = upper('&2')
GROUP BY i.index_name;

PROMP