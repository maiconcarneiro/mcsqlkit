with session_io as (
select/*+ materialize */ 
      inst_id,
      sid,
      physical_reads as value
 from GV$SESS_IO
)
select rownum, x.*
from (
select inst_id, 
       sid,
       value,
       round(value / (select sum(value) from session_io) * 100, 2) as pct_total
from session_io
order by value desc
) x 
where rownum <= 10;