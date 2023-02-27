-- Author: Maicon Carneiro (dibiei.com)
SET SQLFORMAT
SET LINES 400
SET FEEDBACK OFF 
SET VERIFY OFF
SET TERMOUT OFF
SET HEADING OFF
undef str_in_statement
COLUMN temp_in_statement new_value str_in_statement
SELECT DISTINCT LISTAGG(inst_id,',')
         WITHIN GROUP (ORDER BY inst_id) AS temp_in_statement 
  FROM (SELECT DISTINCT inst_id FROM gv$sgastat);

SET FEEDBACK ON 
SET TERMOUT ON
SET HEADING ON

col metric_name heading "Metric Name" format a40
col 1 heading "Node 1" format 999,999,999,999.99
col 2 heading "Node 2" format 999,999,999,999.99
col 3 heading "Node 3" format 999,999,999,999.99
col 4 heading "Node 4" format 999,999,999,999.99
col 5 heading "Node 1" format 999,999,999,999.99
col 6 heading "Node 2" format 999,999,999,999.99
col 7 heading "Node 3" format 999,999,999,999.99
col 8 heading "Node 4" format 999,999,999,999.99

select * from (
 select name as metric_name, inst_id, round(value/decode(unit,'bytes',1024*1024,1),2) as metric_value from GV$PGASTAT order by 1,2
)
pivot 
(
   max(metric_value)
   for inst_id in (&str_in_statement)
)
order by 1
/