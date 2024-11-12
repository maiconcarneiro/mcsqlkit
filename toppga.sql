set lines 400
col sql_id format a20
col pga_max format 999,999,999.99 heading "PGA Usage |Max (MB)"

set feedback off
VAR INSTID NUMBER;
VAR SNAP1 NUMBER;
VAR SNAP2 NUMBER;

BEGIN
 :SNAP1  := &1;
 :SNAP2  := &2;
 :INSTID := &3;
END;
/
set feedback on

select *
from (select sql_id, max(pga_sum) pga_max
        from (select h.sample_time, h.sql_id, round(sum(nvl(h.pga_allocated, 0))/1024/1024,2) pga_sum
                from dba_hist_active_sess_history h
               where 1=1 
	             and (:INSTID = 0 or h.instance_number = :INSTID)
	             and h.snap_id >  :SNAP1 -- O TOP 10 no AWR em HTML desconsidera o snapshot 
	             and h.snap_id <= :SNAP2
            group by sample_time, sql_id
		    )
       group by sql_id
       order by pga_max desc)
where rownum <= 20;